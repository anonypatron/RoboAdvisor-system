from __future__ import annotations

import datetime
from dataclasses import dataclass


@dataclass(frozen=True)
class MarketData:
    ticker: str
    date: datetime.date
    open: float
    high: float
    low: float
    close: float
    volume: int
