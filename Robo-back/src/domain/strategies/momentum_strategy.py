from __future__ import annotations

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import TradeSignal
from src.domain.strategies._strategy_utils import collect_signals, to_dataframe
from src.domain.strategies.strategy import Strategy


class MomentumStrategy(Strategy):
    def __init__(self, lookback: int = 20, threshold: float = 0.05) -> None:
        self.lookback = lookback
        self.threshold = threshold

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if not data:
            return []
        df = self._add_signals(to_dataframe(data))
        return collect_signals(df, data[0].ticker, self.__class__.__name__)

    def _add_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        past_close = df["close"].shift(self.lookback)
        df["returns"] = (df["close"] - past_close) / past_close
        df["signal"] = None
        df.loc[df["returns"] > self.threshold, "signal"] = "BUY"
        df.loc[df["returns"] < -self.threshold, "signal"] = "SELL"
        return df
