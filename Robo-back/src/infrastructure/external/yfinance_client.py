"""yfinance wrapper — the only place in the codebase that imports yfinance."""
from __future__ import annotations

import datetime

import yfinance as yf

from src.domain.entities import MarketData


class YFinanceClient:
    def get_history(self, ticker: str, period: str = "5y") -> list[dict]:
        df = yf.Ticker(ticker).history(period=period)
        if df.empty:
            return []

        result = []
        for index, row in df.iterrows():
            result.append(
                {
                    "date": index,
                    "open": float(row["Open"]),
                    "high": float(row["High"]),
                    "low": float(row["Low"]),
                    "close": float(row["Close"]),
                    "volume": float(row["Volume"]),
                }
            )
        result.reverse()
        return result

    def get_info(self, ticker: str) -> dict:
        info = yf.Ticker(ticker).info
        return {
            "ticker": ticker,
            "name": info.get("shortName", ticker),
            "sector": info.get("sector", "Unknown"),
            "pe_ratio": float(info.get("trailingPE") or 0.0),
            "market_cap": float(info.get("marketCap") or 0.0),
            "current_price": float(info.get("currentPrice") or 0.0),
        }
