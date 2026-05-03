from __future__ import annotations

from sqlalchemy.orm import Session

from src.core.database import StockPrice
from src.domain.entities import MarketData
from src.domain.repositories.stock_repository import StockRepository


class StockRepositoryImpl(StockRepository):
    def __init__(self, db: Session):
        self._db = db

    def get_history(self, ticker: str) -> list[MarketData]:
        rows = (
            self._db.query(StockPrice)
            .filter(StockPrice.ticker == ticker)
            .order_by(StockPrice.date.asc())
            .all()
        )
        return [
            MarketData(
                ticker=row.ticker,
                date=row.date,
                open=float(row.open),
                high=float(row.high),
                low=float(row.low),
                close=float(row.close),
                volume=int(row.volume),
            )
            for row in rows
        ]

    def get_latest_price(self, ticker: str) -> float | None:
        row = (
            self._db.query(StockPrice.close)
            .filter(StockPrice.ticker == ticker)
            .order_by(StockPrice.date.desc())
            .first()
        )
        return float(row[0]) if row else None

    def search(self, query: str, limit: int = 10) -> list[str]:
        rows = (
            self._db.query(StockPrice.ticker)
            .filter(StockPrice.ticker.ilike(f"%{query}%"))
            .distinct()
            .limit(limit)
            .all()
        )
        return [r[0] for r in rows]

    def get_all_tickers(self) -> list[str]:
        rows = self._db.query(StockPrice.ticker).distinct().all()
        return [r[0] for r in rows]
