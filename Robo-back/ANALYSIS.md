# 시스템 현황 분석 및 로드맵

작성일: 2026-05-03  
기준: AAPL 5년 백테스트 실행 결과 + 전체 코드베이스 검토

---

## 1. 현재 상태 분석

### 1-1. 시스템 구조

**Clean Architecture 준수 여부: 70점**

구조 자체는 올바르게 설계되어 있다. domain → application → infrastructure 방향성은 지켜지고 있으며, domain 엔티티는 frozen dataclass로 불변성을 보장한다. 그러나 다음 두 가지 위반이 존재한다.

**위반 1 — FEATURE_COLS 이중 정의**

```
infrastructure/external/ml_feature_builder.py  → FEATURE_COLS (진짜)
domain/strategies/ml_strategy.py               → _FEATURE_COLS (복사본)
```

`ml_strategy.py`의 `_build_features()`는 `ml_feature_builder._add_features()`와 로직이 동일하다. feature 추가 시 두 파일을 동시에 수정해야 하며, 실수 시 학습/추론 간 feature 불일치가 발생한다. 이것은 잠재적 버그 원인이다.

**위반 2 — 전략 이름 하드코딩 (수정됨)**

`BacktestEngine`이 `strategy.__class__.__name__`을 사용하던 문제는 이번 세션에서 `strategy.name` 프로퍼티로 해결되었다. 그러나 `BuyAndHoldStrategy`가 `run_backtest_comparison_usecase.py` 안에 정의되어 있다. 이것은 UseCase가 Domain 역할을 겸하는 설계 위반이다.

---

### 1-2. 백테스트 신뢰성

**Look-ahead bias: 방지됨**

시그널 날짜 D → 체결은 D+1의 종가. `BacktestEngine`의 `signal_map` + `next_day.close` 구조가 이를 보장한다.

**수수료: 현실적**

0.1% (편도)는 미국 주식 기준 합리적이다. 양방향 0.2%는 소형 계좌에서는 실제보다 낮을 수 있으나 백테스트 기준으로는 수용 가능하다.

**체결 방식의 한계:**

- 전량 매수/매도만 지원 (분할 매수 없음)
- 슬리피지 없음 — 종가로 100% 체결 가정
- 단일 종목만 지원 — 포트폴리오 백테스트 불가

**결과 해석의 신뢰도:**

| 항목 | 상태 | 이유 |
|------|------|------|
| 수익률 계산 | 신뢰 | 초기자산 대비 최종자산 |
| MDD 계산 | 신뢰 | 일별 스냅샷 기반 rolling peak |
| Win Rate | 주의 | 매도 기준이며 미청산 포지션은 제외 |
| Sharpe Ratio | 없음 | 리스크 조정 수익률 지표 미구현 |

---

### 1-3. 전략 성능

```
BuyAndHold  : +124.5%  MDD 33.4%  Trades   2
ML(Logistic): + 73.3%  MDD 34.4%  Trades  21  Win 60%
RSI         : + 46.7%  MDD 30.2%  Trades  11  Win 100%
Momentum    : + 30.7%  MDD 24.5%  Trades  33  Win  50%
ML(XGBoost) : + 17.7%  MDD 29.6%  Trades  44  Win  46%
MA Cross    : +  6.7%  MDD 33.2%  Trades  57  Win  36%
```

**판단:**

- BuyAndHold를 이기는 전략이 없다. 이것은 AAPL 5년(2021~2026)이 강세장임을 고려하면 예상된 결과다.
- ML(Logistic)의 +73.3%는 전통 전략보다 우월하다. 그러나 이 결과는 단일 종목, 단일 기간에서만 검증된 것이다.
- ML(XGBoost)의 +17.7%는 RSI보다 낮다. 현재 파라미터(cooldown=20, 0.6/0.4 threshold) 조합이 최적이 아닐 가능성이 높다.
- RSI의 100% Win Rate는 과신하면 안 된다. 거래 횟수 11건에서의 통계적 의미는 낮다.

**과적합 위험:**

ML 모델은 80% 구간(2021~2025)으로 학습하고 20% 구간(2025~2026)으로 검증했다. 단일 분할은 walk-forward validation이 아니다. 현재 결과가 특정 기간 패턴에 맞춰진 것인지 판단 불가다.

---

### 1-4. ML 모델 상태

**Accuracy 낮은 원인 — 구조적 분석**

| 원인 | 분류 | 영향도 |
|------|------|--------|
| 일봉 방향 예측은 본질적으로 노이즈가 많음 | 데이터 한계 | 높음 |
| feature 전부가 기술적 지표 (가격/거래량 파생) | feature 한계 | 높음 |
| 단일 종목 학습 → 패턴 샘플 수 1,236개 | 데이터 한계 | 중간 |
| 레이블이 내일 종가 방향 (binary) → 너무 단순 | 설계 한계 | 중간 |
| walk-forward 미적용 → 검증 구간 단일 | 방법론 한계 | 중간 |
| 하이퍼파라미터 미최적화 | 구현 한계 | 낮음 |

feature 한계와 데이터 한계 모두 존재하지만, **근본 원인은 기술적 지표만으로 다음 날 주가 방향을 예측하는 것이 이론적으로 불가능에 가깝다는 점**이다. EMH(효율적 시장 가설)는 공개된 가격/거래량 데이터로 초과 수익을 낼 수 없다고 예측하며, 이것이 Accuracy 0.50±0.05의 구조적 원인이다.

**현재 ML이 쓸 수 있는 수준인가:**

| 기준 | 판단 |
|------|------|
| 단독 실전 투자 | 불가 |
| 백테스트 비교 연구용 | 가능 |
| 전통 전략과의 앙상블 구성요소 | 조건부 가능 |
| 포트폴리오 리스크 필터 역할 | 가능 |

---

## 2. 현재 단계 정의

**→ 1단계: 기능 구현 단계**

이유:

1. 단일 종목(AAPL)에서만 검증됨
2. Walk-forward validation 미적용 — 백테스트 결과의 통계적 신뢰도 미보장
3. Sharpe Ratio, Sortino Ratio 등 리스크 조정 지표 없음
4. 파라미터 민감도 분석 없음 (cooldown 5 vs 10 vs 20의 성능 변화 미측정)
5. 테스트 코드 없음 — 코드 수정 시 회귀 탐지 불가

기능 구현은 완료되었으나 그 결과를 믿을 수 있는 검증 체계가 없다.

---

## 3. 문제점 정리

### Critical — 반드시 해결

**C1. FEATURE_COLS 이중 정의**
- 파일: `ml_feature_builder.py` vs `ml_strategy.py`
- 위험: 학습 feature와 추론 feature가 달라지면 모델이 쓰레기 예측을 내놓는다
- 해결: `ml_strategy._build_features()` 제거, `ml_feature_builder._add_features()` 직접 호출

**C2. Walk-forward Validation 없음**
- 현재: 단순 80/20 시간 분할 1회
- 위험: 백테스트 기간 특유의 패턴에 과적합된 결과를 신뢰할 수 없음
- 해결: 최소 5-fold walk-forward validation 구현

**C3. 단일 종목 검증**
- AAPL 한 종목에서만 테스트됨
- 위험: 전략이 AAPL의 특성(고성장 빅테크)에 맞춰진 것일 수 있음
- 해결: SPY, MSFT, GOOGL, NVDA 등 최소 5개 종목으로 검증

**C4. Sharpe Ratio 없음**
- 현재 지표: 수익률, MDD, Win Rate
- 위험: MDD가 비슷해도 일별 변동성이 다른 전략을 동등 비교 불가
- 해결: `backtest_result.py`에 Sharpe Ratio, Sortino Ratio 추가

---

### Improvement — 개선하면 좋음

**I1. BuyAndHoldStrategy 위치**
- 현재: `run_backtest_comparison_usecase.py` 내부
- 개선: `domain/strategies/buy_and_hold_strategy.py`로 이동

**I2. 전략 파라미터 하드코딩**
- MA 기간, RSI 기간, threshold 등이 코드에 박혀 있음
- 개선: 전략 생성자 파라미터로 노출 (이미 MLStrategy는 적용됨)

**I3. 백테스트 단일 종목 구조**
- `BacktestEngine.run()`이 단일 MarketData 리스트만 받음
- 개선: 멀티 종목 포트폴리오 백테스트 지원

**I4. yfinance 실패 처리 없음**
- 네트워크 오류 시 전체 파이프라인 크래시
- 개선: retry 로직 + 캐시 레이어

**I5. 슬리피지 모델 없음**
- 개선: 체결가를 `next_day.open` 또는 `next_day.high * 0.5 + next_day.close * 0.5`로 변경 옵션 추가

---

### Later — 지금 하지 않아도 됨

- 실시간 데이터 스트리밍
- 뉴스 감성 분석 feature
- 강화학습(RL) 전략
- GPU 학습
- 모델 서빙 (MLflow, Ray Serve 등)
- 세금 계산

---

## 4. 다음 단계 로드맵

### STEP 1 — 코드 품질 정리 (1~2일)

**목표:** 잠재 버그 제거 + 유지보수 가능한 구조

**작업:**
1. `ml_strategy.py`의 `_build_features()` 삭제  
   → `ml_feature_builder.add_features_to_df(df)` 형태로 분리 후 재사용
2. `_FEATURE_COLS` 삭제, `ml_feature_builder.FEATURE_COLS` 단일 소스로 통일
3. `BuyAndHoldStrategy`를 `domain/strategies/buy_and_hold_strategy.py`로 이동
4. `BacktestResult`에 `sharpe_ratio: float` 필드 추가  
   → 계산식: `(연환산 수익률 - rf) / 연환산 변동성`, rf=0 가정

**결과:** feature 불일치 버그 원천 제거, 리스크 조정 수익률 비교 가능

---

### STEP 2 — 백테스트 신뢰성 확보 (3~5일)

**목표:** 결과를 믿을 수 있는 검증 체계 구축

**작업:**
1. Walk-forward Validation 구현  
   파일: `infrastructure/external/ml_model_trainer.py`
   ```
   전체 기간을 N개 윈도우로 분할
   각 윈도우: train 기간으로 학습 → test 기간으로 예측 → 결과 누적
   최종: 각 윈도우 accuracy 평균 + 표준편차 출력
   ```
2. 멀티 종목 백테스트 스크립트 작성  
   파일: `test_multi_ticker_backtest.py`  
   대상: AAPL, MSFT, GOOGL, SPY, NVDA  
   출력: 종목별 성능 + 평균 성능

3. 파라미터 민감도 테스트  
   파일: `test_parameter_sensitivity.py`  
   대상: MLStrategy의 buy_threshold(0.55/0.60/0.65), cooldown_days(5/10/15/20)  
   출력: 파라미터 조합별 Sharpe Ratio 히트맵

**결과:** "이 전략이 AAPL에서만 통하는 것인지" vs "일반적으로 동작하는지" 판단 가능

---

### STEP 3 — ML 전략 개선 (3~5일)

**목표:** Accuracy 개선이 아닌, 실용적 성능(Sharpe, MDD) 개선

**작업:**
1. 레이블 변경: 내일 방향 → N일 후 수익률 상위/하위  
   ```python
   # 현재
   label = (close.shift(-1) > close).astype(int)
   
   # 변경: 다음 5영업일 수익률이 상위 40%이면 1
   future_return = close.shift(-5) / close - 1
   label = (future_return > future_return.rolling(60).quantile(0.6)).astype(int)
   ```
2. 앙상블 전략 구현  
   파일: `domain/strategies/ensemble_strategy.py`  
   ```python
   class EnsembleStrategy(Strategy):
       # ML 신호 + RSI 신호가 모두 BUY일 때만 진입
       # ML 단독 신호보다 False Positive 감소 목적
   ```
3. 멀티 종목 학습  
   AAPL, MSFT, GOOGL, NVDA 데이터를 합쳐 단일 모델 학습  
   → 샘플 수 1,236 → 4,944+ 으로 증가, 과적합 감소

**결과:** Sharpe Ratio 기준 ML 전략의 실용 가능성 판단

---

### STEP 4 — 포트폴리오 백테스트 (5~7일)

**목표:** 단일 종목 매매에서 포트폴리오 운용으로 확장

**작업:**
1. `PortfolioBacktestEngine` 구현  
   ```
   입력: {ticker: list[MarketData]} 딕셔너리
   동작: 각 종목별 신호 생성 → 비중 기반 자금 배분 → 포트폴리오 수익률
   비중 정책: 균등 배분(1/N) 우선 구현
   ```
2. 리밸런싱 로직 추가  
   ```
   월간 리밸런싱: 매월 마지막 거래일에 목표 비중으로 조정
   드리프트 허용: 비중 이탈 5% 이상 시 즉시 리밸런싱
   ```
3. 포트폴리오 지표 추가  
   - 포트폴리오 수익률 vs 각 종목 개별 수익률
   - 상관계수 기반 다각화 효과 측정

**결과:** "단일 종목 전략"에서 "실제 투자 시뮬레이션"으로 격상

---

### STEP 5 — API 완성 및 연동 (3~5일)

**목표:** 백테스트 결과를 앱에서 조회 가능하게

**작업:**
1. 백테스트 결과 API 엔드포인트  
   `POST /api/backtest` → 종목, 기간, 전략 선택 → BacktestResult 반환
2. 전략 추천 API 개선  
   현재 추천 로직을 백테스트 결과 기반으로 교체
3. Flutter 연동  
   백테스트 결과 화면 추가 (수익률 차트, 전략 비교 테이블)

**결과:** 사용자가 앱에서 전략 성능 확인 가능

---

## 5. 핵심 판단 사항

### ML을 계속 개선할지 vs 중단할지

**계속 개선, 단 목표를 바꿔야 한다.**

Accuracy 0.55 달성을 목표로 하면 안 된다. 기술적 지표만으로는 달성 불가능에 가깝다. 대신 **Sharpe Ratio 기준 ML 전략의 리스크 대비 수익률**을 목표로 삼아야 한다. ML(Logistic)이 RSI보다 높은 수익률과 비슷한 MDD를 보인 것은 의미 있는 신호다. 멀티 종목 학습과 레이블 개선 후 재평가 필요.

---

### 앙상블 전략 필요 여부

**필요하다, STEP 3에서 구현.**

현재 ML 단독 신호는 노이즈가 많다. ML + RSI 앙상블은:
- ML이 방향을 잡고
- RSI가 과매수/과매도 필터 역할

두 신호가 일치할 때만 진입하면 거래 횟수 감소 + False Positive 감소 효과가 있다. 구현 비용 대비 효과가 크다.

---

### 멀티 종목 학습 필요 여부

**필요하다, STEP 3에서 구현.**

현재 1,236개 샘플은 부족하다. AAPL 특성에 과적합된 모델일 가능성이 높다. 5개 종목을 합치면 6,000+ 샘플로 모델 일반화에 도움이 된다. 단, 종목별 특성 차이를 흡수하기 위해 `ticker` one-hot encoding 또는 정규화 전략이 필요하다.

---

### 백테스트 확장 필요 여부

**필요하다, 가장 우선순위가 높다.**

현재 백테스트는:
- 단일 종목
- 단일 기간 (5년)
- 전량 매수/매도
- 슬리피지 없음

이 조건에서 나온 결과를 실전 근거로 쓸 수 없다. STEP 2(멀티 종목 검증) → STEP 4(포트폴리오 백테스트) 순서로 반드시 확장해야 한다.

---

### 실전 투자로 갈 수 있는 수준인지

**현재 불가. 최소 3개 조건 충족 후 재판단.**

| 조건 | 현재 상태 |
|------|----------|
| Walk-forward validation 완료 | ✗ |
| 최소 5개 종목에서 동일한 성능 재현 | ✗ |
| Sharpe Ratio > 1.0 달성 | 측정 불가 (지표 없음) |
| 슬리피지/실제 수수료 반영 | ✗ |
| 최대 손실 시나리오(2022 하락장) 검증 | 미검증 |

이 5가지 중 하나라도 충족되지 않으면 실전 투자 근거 없음. 현재는 0/5.

---

## 요약

| 항목 | 상태 |
|------|------|
| 현재 단계 | 기능 구현 완료, 검증 미완료 |
| 가장 긴급한 작업 | Walk-forward validation + 멀티 종목 검증 |
| ML 전략 방향 | 계속, 단 목표를 Accuracy → Sharpe Ratio로 전환 |
| 실전 투자 가능 여부 | 불가 |
| 다음 구현 우선순위 | STEP 1 → STEP 2 → STEP 3 순서 |
