from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.trader.portfolio import PortfolioManager
from src.core.advisor import RoboAdvisor
from src.strategies.advanced import GoldenCrossVolumeStrategy

router = APIRouter()
pm = PortfolioManager()
advisor = RoboAdvisor(GoldenCrossVolumeStrategy(vol_ratio=1.5))

class TradeRequest(BaseModel):
    ticker: str
    amount: float

class SellRequest(BaseModel):
    ticker: str
    quantity: int

@router.post("/buy")
def buy_stock(request: TradeRequest, db: Session = Depends(get_db)):
    # 1. 현재가 조회
    df = advisor.get_data(request.ticker)
    if df.empty:
        raise HTTPException(status_code=404, detail="Ticker not found")
    
    current_price = float(df.iloc[-1]['close'])
    
    # 2. 매수 실행
    success = pm.buy(request.ticker, current_price, request.amount)
    
    if not success:
        raise HTTPException(
            status_code=400,
            detail="잔고가 부족하거나 주문 수량이 0입니다.",
        )
    
    return {
        "status": "success", 
        "message": f"{request.ticker} 매수 성공!",
        "price": current_price
    }

@router.post("/sell")
def sell_stock(request: SellRequest, db: Session = Depends(get_db)):
    """
    매도 주문
    """
    df = advisor.get_data(request.ticker)
    if df.empty:
        raise HTTPException(
            status_code=404,
            detail="Ticker not found",
        )
    
    current_price = float(df.iloc[-1]['close'])

    success = pm.sell(request.ticker, current_price, request.quantity)

    if not success:
        raise HTTPException(
            status_code=400,
            detail="보유 수량 부족 또는 매도 실패",
        )
    
    return {
        "status": "success",
        "message": "매도 체결 완료",
        "price": current_price,
    }
