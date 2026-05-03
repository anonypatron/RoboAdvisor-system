from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score
from sklearn.preprocessing import StandardScaler

from src.domain.strategies.ml_feature_spec import FEATURE_COLS


@dataclass
class TrainResult:
    model: object
    scaler: StandardScaler
    accuracy: float
    precision: float
    model_name: str
    feature_importance: dict[str, float] = field(default_factory=dict)


def train(df: pd.DataFrame, model_type: str = "logistic") -> TrainResult:
    train_df, test_df = _time_split(df)
    scaler = StandardScaler()
    X_train = scaler.fit_transform(train_df[FEATURE_COLS])
    X_test = scaler.transform(test_df[FEATURE_COLS])
    model = _build_model(model_type)
    model.fit(X_train, train_df["label"])
    y_pred = model.predict(X_test)
    return TrainResult(
        model=model,
        scaler=scaler,
        accuracy=float(accuracy_score(test_df["label"], y_pred)),
        precision=float(precision_score(test_df["label"], y_pred, zero_division=0)),
        model_name=model_type,
        feature_importance=_extract_importance(model, model_type),
    )


def _time_split(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    n = int(len(df) * 0.8)
    return df.iloc[:n], df.iloc[n:]


def _build_model(model_type: str) -> object:
    if model_type == "xgboost":
        from xgboost import XGBClassifier
        return XGBClassifier(n_estimators=200, max_depth=4, learning_rate=0.05,
                             random_state=42, eval_metric="logloss")
    return LogisticRegression(max_iter=1000, random_state=42, C=0.1)


def _extract_importance(model: object, model_type: str) -> dict[str, float]:
    if model_type == "xgboost":
        importances = model.feature_importances_
    else:
        importances = np.abs(model.coef_[0])
    total = importances.sum()
    normalized = importances / total if total > 0 else importances
    return dict(zip(FEATURE_COLS, [float(v) for v in normalized]))
