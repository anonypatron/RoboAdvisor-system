from __future__ import annotations

import datetime

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import SignalType, TradeSignal


def to_dataframe(data: list[MarketData]) -> pd.DataFrame:
    records = [{"date": d.date, "close": d.close, "volume": d.volume} for d in data]
    return pd.DataFrame(records).set_index("date").sort_index()


def collect_signals(df: pd.DataFrame, ticker: str, strategy_name: str) -> list[TradeSignal]:
    result: list[TradeSignal] = []
    for idx, row in df[df["signal"].notna()].iterrows():
        date = idx.date() if isinstance(idx, datetime.datetime) else idx
        signal_type = SignalType.BUY if row["signal"] == "BUY" else SignalType.SELL
        result.append(TradeSignal(
            ticker=ticker,
            date=date,
            signal=signal_type,
            price=float(row["close"]),
            strategy_name=strategy_name,
        ))
    return result
