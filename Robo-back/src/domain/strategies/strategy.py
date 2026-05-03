from __future__ import annotations

from abc import ABC, abstractmethod

from src.domain.entities import MarketData, TradeSignal


class Strategy(ABC):
    """Domain strategy interface — pandas dependency must not appear here."""

    @property
    def name(self) -> str:
        return self.__class__.__name__

    @abstractmethod
    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        ...
