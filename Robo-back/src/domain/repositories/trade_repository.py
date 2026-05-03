from __future__ import annotations

from abc import ABC, abstractmethod

from src.domain.entities import Portfolio, Holding
from src.domain.entities.trade_signal import TradeSignal


class TradeRepository(ABC):
    @abstractmethod
    def get_portfolio(self) -> Portfolio:
        ...

    @abstractmethod
    def buy(self, ticker: str, price: float, amount: float) -> bool:
        ...

    @abstractmethod
    def sell(self, ticker: str, price: float, quantity: int) -> bool:
        ...

    @abstractmethod
    def get_recommendations(self) -> list[dict]:
        ...

    @abstractmethod
    def save_recommendations(self, signals: list[TradeSignal]) -> None:
        ...
