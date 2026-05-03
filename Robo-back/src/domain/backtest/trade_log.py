from __future__ import annotations

import datetime
from dataclasses import dataclass
from enum import Enum


class TradeAction(str, Enum):
    BUY = "BUY"
    SELL = "SELL"


@dataclass(frozen=True)
class TradeLog:
    date: datetime.date
    ticker: str
    action: TradeAction
    price: float
    quantity: int
    cash_after: float
    profit: float
