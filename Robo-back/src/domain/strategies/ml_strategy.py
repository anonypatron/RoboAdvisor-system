from __future__ import annotations

from typing import Callable

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import SignalType, TradeSignal
from src.domain.strategies._strategy_utils import to_dataframe
from src.domain.strategies.ml_feature_spec import FEATURE_COLS
from src.domain.strategies.strategy import Strategy

_MIN_WARMUP_ROWS = 35


class MLStrategy(Strategy):
    def __init__(
        self,
        model,
        scaler,
        feature_fn: Callable[[pd.DataFrame], pd.DataFrame],
        strategy_name: str = "MLStrategy",
        buy_threshold: float = 0.6,
        sell_threshold: float = 0.4,
        cooldown_days: int = 10,
    ) -> None:
        self._model = model
        self._scaler = scaler
        self._feature_fn = feature_fn
        self._strategy_name = strategy_name
        self._buy_threshold = buy_threshold
        self._sell_threshold = sell_threshold
        self._cooldown_days = cooldown_days

    @property
    def name(self) -> str:
        return self._strategy_name

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if len(data) < _MIN_WARMUP_ROWS:
            return []
        df = self._feature_fn(to_dataframe(data)).dropna(subset=FEATURE_COLS)
        if df.empty:
            return []
        X = self._scaler.transform(df[FEATURE_COLS])
        raw_probas = self._model.predict_proba(X)[:, 1]
        probas = pd.Series(raw_probas, index=df.index).rolling(3, min_periods=1).mean().values
        return self._to_signals(df, data[0].ticker, probas)

    def _to_signals(self, df: pd.DataFrame, ticker: str, probas) -> list[TradeSignal]:
        signals = []
        in_position = False
        last_signal_idx = -self._cooldown_days
        for i, (idx, proba) in enumerate(zip(df.index, probas)):
            if i - last_signal_idx < self._cooldown_days:
                continue
            date = idx.date() if hasattr(idx, "date") else idx
            price = float(df.at[idx, "close"])
            if proba > self._buy_threshold and not in_position:
                signals.append(TradeSignal(ticker=ticker, date=date, signal=SignalType.BUY,
                                           price=price, strategy_name=self._strategy_name))
                in_position = True
                last_signal_idx = i
            elif proba < self._sell_threshold and in_position:
                signals.append(TradeSignal(ticker=ticker, date=date, signal=SignalType.SELL,
                                           price=price, strategy_name=self._strategy_name))
                in_position = False
                last_signal_idx = i
        return signals
