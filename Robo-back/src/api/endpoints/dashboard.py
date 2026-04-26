from typing import List

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from src.core.database import get_db
from src.trader.portfolio import PortfolioManager

router = APIRouter()


class HoldingResponse(BaseModel):
    ticker: str
    qty: int
    avg_price: float
    current_price: float
    market_value: float
    profit_amount: float
    return_pct: float


class DashboardResponse(BaseModel):
    total_asset: float
    cash_balance: float
    stock_value: float
    total_profit: float
    total_return_rate: float
    holdings: List[HoldingResponse]


@router.get("", response_model=DashboardResponse)
def get_dashboard(db: Session = Depends(get_db)):
    portfolio_manager = PortfolioManager(db)
    return portfolio_manager.get_dashboard_data()
