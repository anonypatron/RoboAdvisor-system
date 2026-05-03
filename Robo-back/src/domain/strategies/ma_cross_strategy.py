from __future__ import annotations

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import TradeSignal
from src.domain.strategies._strategy_utils import collect_signals, to_dataframe
from src.domain.strategies.strategy import Strategy


class MovingAverageCrossStrategy(Strategy):
    def __init__(self, short_window: int = 10, long_window: int = 20) -> None:
        self.short_window = short_window
        self.long_window = long_window

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if not data:
            return []
        df = self._add_signals(to_dataframe(data))
        return collect_signals(df, data[0].ticker, self.__class__.__name__)

    def _add_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df["ma_short"] = df["close"].rolling(self.short_window).mean()
        df["ma_long"] = df["close"].rolling(self.long_window).mean()
        prev_short = df["ma_short"].shift(1)
        prev_long = df["ma_long"].shift(1)

        df["signal"] = None
        df.loc[(prev_short <= prev_long) & (df["ma_short"] > df["ma_long"]), "signal"] = "BUY"
        df.loc[(prev_short >= prev_long) & (df["ma_short"] < df["ma_long"]), "signal"] = "SELL"
        return df
