from __future__ import annotations

import datetime

from sqlalchemy.orm import Session

from src.core.database import RecommendationResult
from src.domain.entities import Portfolio, Holding
from src.domain.entities.trade_signal import TradeSignal, SignalType
from src.domain.repositories.trade_repository import TradeRepository
from src.trader.portfolio import PortfolioManager


class TradeRepositoryImpl(TradeRepository):
    def __init__(self, db: Session):
        self._db = db
        self._pm = PortfolioManager(db)

    def get_portfolio(self) -> Portfolio:
        data = self._pm.get_dashboard_data()
        holdings = [
            Holding(
                ticker=h["ticker"],
                quantity=h["qty"],
                average_price=h["avg_price"],
                current_price=h["current_price"],
            )
            for h in data["holdings"]
        ]
        return Portfolio(
            cash_balance=data["cash_balance"],
            holdings=holdings,
            initial_cash=self._pm.initial_cash,
        )

    def buy(self, ticker: str, price: float, amount: float) -> bool:
        return self._pm.buy(ticker, price, amount)

    def sell(self, ticker: str, price: float, quantity: int) -> bool:
        return self._pm.sell(ticker, price, quantity)

    def get_recommendations(self) -> list[dict]:
        rows = self._db.query(RecommendationResult).all()
        return [
            {
                "ticker": r.ticker,
                "date": r.date,
                "close": r.close_price,
                "signal_type": r.signal_type,
            }
            for r in rows
        ]

    def save_recommendations(self, signals: list[TradeSignal]) -> None:
        for signal in signals:
            if signal.signal != SignalType.BUY:
                continue
            self._db.add(
                RecommendationResult(
                    ticker=signal.ticker,
                    date=signal.date,
                    close_price=signal.price,
                    signal_type=signal.strategy_name,
                )
            )
        self._db.commit()
