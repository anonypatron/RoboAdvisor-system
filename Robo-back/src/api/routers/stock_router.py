from __future__ import annotations

from datetime import datetime
from typing import List

from fastapi import APIRouter, HTTPException

from src.api.schemas.stock_schemas import CandleData, StockInfoResponse
from src.infrastructure.external.yfinance_client import YFinanceClient

router = APIRouter()
_yf = YFinanceClient()


@router.get("/{ticker}/history", response_model=List[CandleData])
def get_stock_history(ticker: str, period: str = "5y"):
    data = _yf.get_history(ticker, period)
    if not data:
        raise HTTPException(status_code=404, detail="No data found")
    return data


@router.get("/{ticker}/info", response_model=StockInfoResponse)
def get_stock_info(ticker: str):
    return _yf.get_info(ticker)
