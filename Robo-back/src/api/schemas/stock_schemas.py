from datetime import datetime

from pydantic import BaseModel


class CandleData(BaseModel):
    date: datetime
    open: float
    high: float
    low: float
    close: float
    volume: float


class StockInfoResponse(BaseModel):
    ticker: str
    name: str
    current_price: float
    pe_ratio: float
    market_cap: float
    sector: str
