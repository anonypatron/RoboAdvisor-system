from __future__ import annotations

from sqlalchemy.orm import Session

from src.core.database import Watchlist
from src.domain.repositories.watchlist_repository import WatchlistRepository


class WatchlistRepositoryImpl(WatchlistRepository):
    def __init__(self, db: Session):
        self._db = db

    def get_all(self) -> list[str]:
        return [r.ticker for r in self._db.query(Watchlist).all()]

    def add(self, ticker: str) -> bool:
        exists = self._db.query(Watchlist).filter(Watchlist.ticker == ticker).first()
        if exists:
            return False
        self._db.add(Watchlist(ticker=ticker))
        self._db.commit()
        return True

    def remove(self, ticker: str) -> None:
        item = self._db.query(Watchlist).filter(Watchlist.ticker == ticker).first()
        if item:
            self._db.delete(item)
            self._db.commit()
