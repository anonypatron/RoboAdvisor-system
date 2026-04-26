from datetime import datetime
from typing import List

import yfinance as yf
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()


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


@router.get("/{ticker}/history", response_model=List[CandleData])
def get_stock_history(ticker: str, period: str = "5y"):
    ticker_obj = yf.Ticker(ticker)
    df = ticker_obj.history(period=period)

    if df.empty:
        raise HTTPException(status_code=404, detail="No data found")

    data = []
    for index, row in df.iterrows():
        data.append(
            {
                "date": index,
                "open": float(row["Open"]),
                "high": float(row["High"]),
                "low": float(row["Low"]),
                "close": float(row["Close"]),
                "volume": float(row["Volume"]),
            }
        )

    data.reverse()
    return data


@router.get("/{ticker}/info", response_model=StockInfoResponse)
def get_stock_info(ticker: str):
    info = yf.Ticker(ticker).info

    return {
        "ticker": ticker,
        "name": info.get("shortName", ticker),
        "sector": info.get("sector", "Unknown"),
        "pe_ratio": float(info.get("trailingPE") or 0.0),
        "market_cap": float(info.get("marketCap") or 0.0),
        "current_price": float(info.get("currentPrice") or 0.0),
    }
