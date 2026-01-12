from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime

import yfinance as yf

router = APIRouter()

class CandleData(BaseModel):
    date: datetime
    open: float
    high: float
    low: float
    close: float
    volume: float

@router.get("/{ticker}/history", response_model=List[CandleData])
def get_stock_history(ticker: str, period: str = "5y"):
    """
    [차트용 데이터] 특정 종목의 과거 데이터를 가져옵니다.
    period: 1mo, 3mo, 6mo, 1y, 2y, 5y, max
    """
    print(f"📈 Fetching history for {ticker} ({period})...")
    
    ticker_obj = yf.Ticker(ticker)
    df = ticker_obj.history(period=period)
    
    if df.empty:
        raise HTTPException(status_code=404, detail="No data found")
    
    data = []
    for index, row in df.iterrows():
        data.append({
            "date": index, # timestamp
            "open": row['Open'],
            "high": row['High'],
            "low": row['Low'],
            "close": row['Close'],
            "volume": row['Volume']
        })
    
    data.reverse()
    return data

@router.get("/{ticker}/info")
def get_stock_info(ticker: str):
    """
    종목 상세 정보 (AI 요약용 간단 정보)
    """
    t = yf.Ticker(ticker)
    info = t.info
    return {
        "name": info.get("shortName", ticker),
        "sector": info.get("sector", "Unknown"),
        "pe_ratio": info.get("trailingPE", 0),
        "market_cap": info.get("marketCap", 0),
        "current_price": info.get("currentPrice", 0)
    }
