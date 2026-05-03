from __future__ import annotations

from pydantic import BaseModel


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
    holdings: list[HoldingResponse]
