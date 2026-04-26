from __future__ import annotations

from typing import Dict, List

import pandas as pd
from sqlalchemy.orm import Session

from src.core.database import StockPrice
from src.strategies.base import BaseStrategy


class RoboAdvisor:
    def __init__(self, strategy: BaseStrategy):
        self.strategy = strategy

    def set_strategy(self, strategy: BaseStrategy) -> None:
        self.strategy = strategy

    def get_data(self, db: Session, ticker: str) -> pd.DataFrame:
        query = db.query(StockPrice).filter(StockPrice.ticker == ticker).statement
        df = pd.read_sql(query, db.bind)
        if not df.empty:
            df = df.sort_values("date")
        return df

    def screen_market(
        self,
        db: Session,
        tickers: List[str],
        lookback_days: int = 300,
    ) -> List[Dict]:
        buy_candidates: List[Dict] = []

        for ticker in tickers:
            df = self.get_data(db, ticker)
            if len(df) < lookback_days:
                continue

            result_df = self.strategy.generate_signals(df)
            latest = result_df.iloc[-1]

            if latest["position"] == 1:
                buy_candidates.append(
                    {
                        "ticker": ticker,
                        "date": latest["date"],
                        "close": float(latest["close"]),
                        "signal_type": "BUY",
                    }
                )

        return buy_candidates
