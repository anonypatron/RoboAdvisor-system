from __future__ import annotations

import datetime

from src.domain.entities.market_data import MarketData
from src.infrastructure.external.yfinance_client import YFinanceClient

_client = YFinanceClient()


def fetch_market_data(ticker: str) -> list[MarketData]:
    raw = _client.get_history(ticker)
    items = [_convert(ticker, r) for r in raw if _is_valid(r)]
    return sorted(items, key=lambda d: d.date)


def _convert(ticker: str, row: dict) -> MarketData:
    raw_date = row["date"]
    date: datetime.date = raw_date.date() if hasattr(raw_date, "date") else raw_date
    return MarketData(
        ticker=ticker,
        date=date,
        open=float(row["open"]),
        high=float(row["high"]),
        low=float(row["low"]),
        close=float(row["close"]),
        volume=int(row["volume"]),
    )


def _is_valid(row: dict) -> bool:
    return all(row.get(k) is not None for k in ("open", "high", "low", "close", "volume"))
