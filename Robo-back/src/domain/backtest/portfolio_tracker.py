from __future__ import annotations

import datetime
from dataclasses import dataclass


@dataclass
class PortfolioTracker:
    initial_cash: float

    def __post_init__(self) -> None:
        self.cash: float = self.initial_cash
        self.holdings: dict[str, tuple[int, float]] = {}
        self.snapshots: list[tuple[datetime.date, float]] = []

    def total_asset(self, prices: dict[str, float]) -> float:
        stock_value = sum(
            qty * prices.get(ticker, avg_price)
            for ticker, (qty, avg_price) in self.holdings.items()
        )
        return self.cash + stock_value

    def record_snapshot(self, date: datetime.date, prices: dict[str, float]) -> None:
        self.snapshots.append((date, self.total_asset(prices)))
