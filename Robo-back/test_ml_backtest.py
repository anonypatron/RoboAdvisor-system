"""End-to-end ML backtest: AAPL 5년 데이터 → feature 생성 → 모델 학습 → 백테스트 비교."""
import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from src.infrastructure.external.market_data_provider import fetch_market_data
from src.infrastructure.external.ml_feature_builder import build_features
from src.infrastructure.external.ml_model_trainer import train
from src.infrastructure.external.technical_indicators import add_technical_indicators
from src.domain.strategies.ml_strategy import MLStrategy
from src.application.usecases.run_backtest_comparison_usecase import (
    run_single_strategy,
    run_all_strategies,
    compare_results,
)

TICKER = "AAPL"
INITIAL_CASH = 1_000_000.0


def step1_fetch():
    print("=" * 40)
    print("[1단계] 데이터 수집")
    data = fetch_market_data(TICKER)
    print(f"  ticker : {TICKER}")
    print(f"  rows   : {len(data)}")
    print(f"  from   : {data[0].date}")
    print(f"  to     : {data[-1].date}")
    return data


def step2_features(data):
    print("=" * 40)
    print("[2단계] Feature 생성 (12 features)")
    df = build_features(data)
    print(f"  샘플 수 : {len(df)}")
    print(f"  features: {[c for c in df.columns if c not in ('label', 'close')]}")
    print(f"  label 분포: 1={df['label'].sum()} / 0={(df['label']==0).sum()}")
    return df


def step3_train(df):
    print("=" * 40)
    print("[3단계] 모델 학습 (train 80% / test 20%)")

    logistic = train(df, model_type="logistic")
    print(f"\n  [Logistic Regression]")
    print(f"  Accuracy : {logistic.accuracy:.3f}")
    print(f"  Precision: {logistic.precision:.3f}")
    _print_importance(logistic.feature_importance)

    xgb = train(df, model_type="xgboost")
    print(f"\n  [XGBoost]")
    print(f"  Accuracy : {xgb.accuracy:.3f}")
    print(f"  Precision: {xgb.precision:.3f}")
    _print_importance(xgb.feature_importance)

    return logistic, xgb


def _print_importance(importance: dict) -> None:
    top5 = sorted(importance.items(), key=lambda x: x[1], reverse=True)[:5]
    print(f"  Top-5 feature importance:")
    for name, score in top5:
        print(f"    {name:<14} {score:.4f}")


def step4_backtest(data, logistic_result, xgb_result):
    print("=" * 40)
    print("[4단계] 백테스트 비교 (전통 전략 + ML Logistic + ML XGBoost)")

    ml_logistic = MLStrategy(
        model=logistic_result.model, scaler=logistic_result.scaler,
        feature_fn=add_technical_indicators,
        strategy_name="ML(Logistic)",
        buy_threshold=0.55, sell_threshold=0.45, cooldown_days=3,
    )
    ml_xgb = MLStrategy(
        model=xgb_result.model, scaler=xgb_result.scaler,
        feature_fn=add_technical_indicators,
        strategy_name="ML(XGBoost)",
        buy_threshold=0.6, sell_threshold=0.4, cooldown_days=20,
    )

    traditional = run_all_strategies(data, INITIAL_CASH)
    ml_log_result = run_single_strategy(data, ml_logistic, INITIAL_CASH)
    ml_xgb_result = run_single_strategy(data, ml_xgb, INITIAL_CASH)

    compare_results(traditional + [ml_log_result, ml_xgb_result])


if __name__ == "__main__":
    data = step1_fetch()
    df = step2_features(data)
    logistic_result, xgb_result = step3_train(df)
    step4_backtest(data, logistic_result, xgb_result)
