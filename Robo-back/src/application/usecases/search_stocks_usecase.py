from __future__ import annotations

from src.domain.repositories.stock_repository import StockRepository


class SearchStocksUseCase:
    def __init__(self, stock_repo: StockRepository):
        self._repo = stock_repo

    def execute(self, query: str, limit: int = 10) -> list[str]:
        return self._repo.search(query, limit)
