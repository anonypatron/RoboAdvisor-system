from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from src.trader.portfolio import PortfolioManager
from src.core.advisor import RoboAdvisor
from src.strategies.advanced import GoldenCrossVolumeStrategy
from src.core.database import init_db

# 시작하기
# 1. 데이터 수집하기
# uv run python -m src.data_loader.collector

# 2. api endpoint 열기
# uv run python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

app = FastAPI(
    title="Robo-Advisor API",
    description="Robo-Advisor Backend for Flutter App",
    version="1.0.0"
)

pm = PortfolioManager(initial_cash=10000.0)
strategy = GoldenCrossVolumeStrategy(vol_ratio=1.5)
advisor = RoboAdvisor(strategy)

init_db()

class TradeRequest(BaseModel):
    ticker: str
    amount: float

class DashboardResponse(BaseModel):
    total_asset: float
    cash_balance: float
    stock_value: float
    holdings: List[dict]

@app.get("/")
def read_root():
    return {"status": "ok", "message": "QuantRobo Server is Running 🚀"}

@app.get("/dashboard", response_model=DashboardResponse)
def get_dashboard():
    """
    [Flutter] 대시보드 화면용 데이터 조회
    """
    data = pm.get_dashboard_data()
    return data

@app.post("/trade/buy")
def buy_stock(request: TradeRequest):
    """
    [Flutter] 매수 버튼 클릭 시 호출
    """
    # 현재가 조회 (실제로는 실시간 시세 API 필요하지만 여기선 DB 최신가로 대체)
    df = advisor.get_data(request.ticker)
    if df.empty:
        raise HTTPException(status_code=404, detail="Ticker not found")
    
    current_price = float(df.iloc[-1]['close'])
    
    success = pm.buy(request.ticker, current_price, request.amount)
    
    if not success:
        return {"status": "failed", "message": "잔고가 부족하거나 매수할 수 없습니다."}
    
    return {
        "status": "success", 
        "message": f"{request.ticker} 매수 성공!",
        "price": current_price
    }

@app.get("/recommendations")
def get_recommendations():
    """
    [Flutter] '오늘의 추천 종목' 화면용
    """
    # 테스트를 위해 일부 종목만 스캔 (실제론 전체 스캔 or 미리 저장된 결과 반환)
    tickers = ["MMM", "AOS", "ABT"] # DB에 있는 종목으로 수정 필요
    results = advisor.screen_market(tickers)
    return results
