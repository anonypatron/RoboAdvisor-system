"""Adapts legacy pandas-based strategies to the domain Strategy interface."""
from __future__ import annotations

import pandas as pd

from src.domain.entities import MarketData, TradeSignal, SignalType
from src.domain.strategies.strategy import Strategy
from src.strategies.base import BaseStrategy


class LegacyStrategyAdapter(Strategy):
    """Wraps a BaseStrategy and converts domain entities to/from pandas."""

    def __init__(self, legacy: BaseStrategy, strategy_name: str):
        self._legacy = legacy
        self._name = strategy_name

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if not data:
            return []

        df = pd.DataFrame(
            [
                {
                    "date": d.date,
                    "open": d.open,
                    "high": d.high,
                    "low": d.low,
                    "close": d.close,
                    "volume": d.volume,
                }
                for d in data
            ]
        )

        result = self._legacy.generate_signals(df)
        latest = result.iloc[-1]

        position_change = latest.get("position", 0)
        if position_change == 1:
            signal_type = SignalType.BUY
        elif position_change == -1:
            signal_type = SignalType.SELL
        else:
            signal_type = SignalType.HOLD

        return [
            TradeSignal(
                ticker=data[-1].ticker,
                date=latest["date"],
                signal=signal_type,
                price=float(latest["close"]),
                strategy_name=self._name,
            )
        ]
