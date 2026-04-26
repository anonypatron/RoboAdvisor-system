from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from src.core.database import StockPrice, get_db
from src.trader.portfolio import PortfolioManager

router = APIRouter()


class TradeRequest(BaseModel):
    ticker: str
    amount: float


class SellRequest(BaseModel):
    ticker: str
    quantity: int


def get_latest_close_price(db: Session, ticker: str) -> float | None:
    latest_close_row = (
        db.query(StockPrice.close)
        .filter(StockPrice.ticker == ticker)
        .order_by(StockPrice.date.desc())
        .first()
    )
    if latest_close_row is None:
        return None
    return float(latest_close_row[0])


@router.post("/buy")
def buy_stock(request: TradeRequest, db: Session = Depends(get_db)):
    current_price = get_latest_close_price(db, request.ticker)
    if current_price is None:
        raise HTTPException(status_code=404, detail="Ticker not found")

    portfolio_manager = PortfolioManager(db)
    success = portfolio_manager.buy(request.ticker, current_price, request.amount)
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Insufficient cash balance or invalid order amount",
        )

    return {
        "status": "success",
        "message": f"{request.ticker} buy order executed",
        "price": current_price,
    }


@router.post("/sell")
def sell_stock(request: SellRequest, db: Session = Depends(get_db)):
    current_price = get_latest_close_price(db, request.ticker)
    if current_price is None:
        raise HTTPException(status_code=404, detail="Ticker not found")

    portfolio_manager = PortfolioManager(db)
    success = portfolio_manager.sell(request.ticker, current_price, request.quantity)
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Insufficient holdings or invalid sell quantity",
        )

    return {
        "status": "success",
        "message": f"{request.ticker} sell order executed",
        "price": current_price,
    }
