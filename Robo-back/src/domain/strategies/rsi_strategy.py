from __future__ import annotations

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import TradeSignal
from src.domain.strategies._strategy_utils import collect_signals, to_dataframe
from src.domain.strategies.strategy import Strategy


class RSIStrategy(Strategy):
    def __init__(self, period: int = 14, oversold: float = 30.0, overbought: float = 70.0) -> None:
        self.period = period
        self.oversold = oversold
        self.overbought = overbought

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if not data:
            return []
        df = self._add_signals(to_dataframe(data))
        return collect_signals(df, data[0].ticker, self.__class__.__name__)

    def _compute_rsi(self, close: pd.Series) -> pd.Series:
        delta = close.diff()
        gain = delta.clip(lower=0)
        loss = -delta.clip(upper=0)
        avg_gain = gain.ewm(alpha=1 / self.period, adjust=False).mean()
        avg_loss = loss.ewm(alpha=1 / self.period, adjust=False).mean()
        rs = avg_gain / avg_loss
        return 100 - (100 / (1 + rs))

    def _add_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df["rsi"] = self._compute_rsi(df["close"])
        df["signal"] = None
        df.loc[df["rsi"] < self.oversold, "signal"] = "BUY"
        df.loc[df["rsi"] > self.overbought, "signal"] = "SELL"
        return df
