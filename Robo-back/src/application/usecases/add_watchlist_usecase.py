from __future__ import annotations

from src.domain.repositories.watchlist_repository import WatchlistRepository


class AddWatchlistUseCase:
    def __init__(self, watchlist_repo: WatchlistRepository):
        self._repo = watchlist_repo

    def execute(self, ticker: str) -> dict:
        added = self._repo.add(ticker)
        return {"message": "Added" if added else "Already in watchlist"}
