# 📊 투자 전략 명세서 (Strategy Specifications)

## 1. 단기 전략: RSI Mean Reversion
- **코드 파일**: `src/strategies/short_term.py`
- **대상**: S&P 500 구성 종목 중 거래량 상위 50위
- **매수 조건 (Buy Signal)**:
    - RSI(14) < 30 (과매도 구간)
    - 주가가 20일 이동평균선 위에 위치 (상승 추세)
- **매도 조건 (Sell Signal)**:
    - RSI(14) > 70 (과매수 구간)
    - 또는 매수 후 수익률 +3% 도달 시
- **손절 조건 (Stop Loss)**:
    - 매수 후 -2% 하락 시 즉시 시장가 매도

## 2. 장기 전략: Q.V. (Quality + Value)
- **코드 파일**: `src/strategies/long_term.py`
- **대상**: S&P 500 전 종목
- **로직**:
    - PER < 업종 평균
    - ROE > 15% 이상
    - 위 조건 만족 시 월 1회 리밸런싱
    