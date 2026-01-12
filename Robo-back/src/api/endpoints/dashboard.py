from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.trader.portfolio import PortfolioManager
from pydantic import BaseModel
from typing import List

router = APIRouter()
pm = PortfolioManager()

class DashboardResponse(BaseModel):
    total_asset: float
    cash_balance: float
    stock_value: float
    holdings: List[dict]

@router.get("", response_model=DashboardResponse)
def get_dashboard(db: Session = Depends(get_db)):
    data = pm.get_dashboard_data()
    return data
