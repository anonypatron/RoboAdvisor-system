from __future__ import annotations

from src.domain.repositories.watchlist_repository import WatchlistRepository


class GetWatchlistUseCase:
    def __init__(self, watchlist_repo: WatchlistRepository):
        self._repo = watchlist_repo

    def execute(self) -> list[str]:
        return self._repo.get_all()
