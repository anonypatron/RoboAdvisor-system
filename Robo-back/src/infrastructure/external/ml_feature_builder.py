from __future__ import annotations

import pandas as pd

from src.domain.entities.market_data import MarketData
from src.domain.strategies.ml_feature_spec import FEATURE_COLS
from src.infrastructure.external.technical_indicators import add_technical_indicators

__all__ = ["FEATURE_COLS", "build_features"]


def build_features(data: list[MarketData]) -> pd.DataFrame:
    df = _to_dataframe(data)
    df = add_technical_indicators(df)
    df["label"] = (df["close"].shift(-1) > df["close"]).astype(int)
    valid = df.dropna(subset=FEATURE_COLS + ["label"])
    return valid[FEATURE_COLS + ["label", "close"]]


def _to_dataframe(data: list[MarketData]) -> pd.DataFrame:
    records = [{"date": d.date, "close": d.close, "volume": d.volume} for d in data]
    return pd.DataFrame(records).set_index("date").sort_index()
