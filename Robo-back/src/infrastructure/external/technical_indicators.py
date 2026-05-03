from __future__ import annotations

import pandas as pd


def add_technical_indicators(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df = _add_moving_averages(df)
    df = _add_rsi(df)
    df = _add_returns_and_volume(df)
    df = _add_macd(df)
    df = _add_bollinger(df)
    df = _add_volatility(df)
    return df


def _add_moving_averages(df: pd.DataFrame) -> pd.DataFrame:
    df["ma_5"] = df["close"].rolling(5).mean()
    df["ma_20"] = df["close"].rolling(20).mean()
    df["ma_ratio"] = df["ma_5"] / df["ma_20"]
    return df


def _add_rsi(df: pd.DataFrame) -> pd.DataFrame:
    delta = df["close"].diff()
    gain = delta.clip(lower=0).ewm(alpha=1 / 14, adjust=False).mean()
    loss = (-delta.clip(upper=0)).ewm(alpha=1 / 14, adjust=False).mean()
    df["rsi_14"] = 100 - (100 / (1 + gain / loss))
    return df


def _add_returns_and_volume(df: pd.DataFrame) -> pd.DataFrame:
    df["return_5d"] = df["close"].pct_change(5)
    df["return_20d"] = df["close"].pct_change(20)
    df["vol_ratio"] = df["volume"] / df["volume"].rolling(20).mean()
    return df


def _add_macd(df: pd.DataFrame) -> pd.DataFrame:
    ema12 = df["close"].ewm(span=12).mean()
    ema26 = df["close"].ewm(span=26).mean()
    df["macd"] = ema12 - ema26
    df["macd_signal"] = df["macd"].ewm(span=9).mean()
    df["macd_hist"] = df["macd"] - df["macd_signal"]
    return df


def _add_bollinger(df: pd.DataFrame) -> pd.DataFrame:
    std20 = df["close"].rolling(20).std()
    upper = df["ma_20"] + 2 * std20
    lower = df["ma_20"] - 2 * std20
    df["bb_pct"] = (df["close"] - lower) / (upper - lower)
    return df


def _add_volatility(df: pd.DataFrame) -> pd.DataFrame:
    df["volatility"] = df["close"].pct_change().rolling(20).std()
    return df
