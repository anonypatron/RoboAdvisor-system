from __future__ import annotations

from abc import ABC, abstractmethod


class WatchlistRepository(ABC):
    @abstractmethod
    def get_all(self) -> list[str]:
        ...

    @abstractmethod
    def add(self, ticker: str) -> bool:
        ...

    @abstractmethod
    def remove(self, ticker: str) -> None:
        ...
