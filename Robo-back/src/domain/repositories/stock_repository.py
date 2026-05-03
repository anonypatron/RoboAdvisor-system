from __future__ import annotations

from abc import ABC, abstractmethod

from src.domain.entities import MarketData


class StockRepository(ABC):
    @abstractmethod
    def get_history(self, ticker: str) -> list[MarketData]:
        ...

    @abstractmethod
    def get_latest_price(self, ticker: str) -> float | None:
        ...

    @abstractmethod
    def search(self, query: str, limit: int = 10) -> list[str]:
        ...

    @abstractmethod
    def get_all_tickers(self) -> list[str]:
        ...
