# 📈 Robo (AI Robo-Advisor Backend)

파이썬 기반의 확장 가능한 퀀트 트레이딩 시스템 및 백엔드 서버입니다.
FastAPI를 통해 모바일 앱(Flutter)과 연동되며, 전략 패턴을 사용하여 다양한 투자 로직을 쉽게 교체할 수 있습니다.

## 🛠 Tech Stack
- **Language**: Python 3.10+
- **Manager**: uv (Package & Project Management)
- **Web Framework**: FastAPI
- **Database**: PostgreSQL (via Docker), SQLAlchemy (ORM)
- **Data**: yfinance (Yahoo Finance), Pandas, NumPy
- **Strategies**: Golden Cross, RSI, Volume Analysis

## 📂 Project Structure
```text
Robo/
├── src/
│   ├── main.py           # FastAPI 진입점 (API 서버)
│   ├── core/             # DB 연결, 로보어드바이저 엔진(Context)
│   ├── data_loader/      # 데이터 수집 (S&P500, Crawling)
│   ├── strategies/       # 투자 전략 모듈 (전략 패턴 적용)
│   └── trader/           # 포트폴리오 관리 및 주문(Mock)
├── docs/                 # 상세 문서
├── docker-compose.yml    # DB 실행 설정
└── pyproject.toml        # 의존성 관리