from __future__ import annotations

from src.domain.repositories.watchlist_repository import WatchlistRepository


class RemoveWatchlistUseCase:
    def __init__(self, watchlist_repo: WatchlistRepository):
        self._repo = watchlist_repo

    def execute(self, ticker: str) -> dict:
        self._repo.remove(ticker)
        return {"message": "Removed"}
