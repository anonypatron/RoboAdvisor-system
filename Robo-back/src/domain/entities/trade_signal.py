from __future__ import annotations

import datetime
from dataclasses import dataclass
from enum import Enum


class SignalType(str, Enum):
    BUY = "BUY"
    SELL = "SELL"
    HOLD = "HOLD"


@dataclass(frozen=True)
class TradeSignal:
    ticker: str
    date: datetime.date
    signal: SignalType
    price: float
    strategy_name: str
