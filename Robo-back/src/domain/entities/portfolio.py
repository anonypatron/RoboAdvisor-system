from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Holding:
    ticker: str
    quantity: int
    average_price: float
    current_price: float

    @property
    def market_value(self) -> float:
        return round(self.quantity * self.current_price, 2)

    @property
    def cost_basis(self) -> float:
        return round(self.quantity * self.average_price, 2)

    @property
    def profit_amount(self) -> float:
        return round(self.market_value - self.cost_basis, 2)

    @property
    def return_pct(self) -> float:
        if self.cost_basis <= 0:
            return 0.0
        return round(self.profit_amount / self.cost_basis * 100, 2)


@dataclass(frozen=True)
class Portfolio:
    cash_balance: float
    holdings: list[Holding] = field(default_factory=list)
    initial_cash: float = 10000.0

    @property
    def stock_value(self) -> float:
        return round(sum(h.market_value for h in self.holdings), 2)

    @property
    def total_asset(self) -> float:
        return round(self.cash_balance + self.stock_value, 2)

    @property
    def total_profit(self) -> float:
        return round(self.total_asset - self.initial_cash, 2)

    @property
    def total_return_rate(self) -> float:
        if self.initial_cash <= 0:
            return 0.0
        return round(self.total_profit / self.initial_cash * 100, 2)
