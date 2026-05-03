from __future__ import annotations

from src.domain.backtest.backtest_engine import BacktestEngine
from src.domain.backtest.backtest_result import BacktestResult
from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import SignalType, TradeSignal
from src.domain.strategies.ma_cross_strategy import MovingAverageCrossStrategy
from src.domain.strategies.momentum_strategy import MomentumStrategy
from src.domain.strategies.rsi_strategy import RSIStrategy
from src.domain.strategies.strategy import Strategy

_COMMISSION_RATE = 0.001

_ENGINE = BacktestEngine()


class BuyAndHoldStrategy(Strategy):
    """첫 거래일 매수 → 마지막 거래일 매도 기준선 전략."""

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        if len(data) < 2:
            return []
        ordered = sorted(data, key=lambda d: d.date)
        # 시그널 날짜 기준으로 다음 날 체결 → 마지막 날 매도 체결을 위해 끝에서 두 번째 날 SELL
        return [
            TradeSignal(
                ticker=ordered[0].ticker,
                date=ordered[0].date,
                signal=SignalType.BUY,
                price=ordered[0].close,
                strategy_name="BuyAndHold",
            ),
            TradeSignal(
                ticker=ordered[-2].ticker,
                date=ordered[-2].date,
                signal=SignalType.SELL,
                price=ordered[-2].close,
                strategy_name="BuyAndHold",
            ),
        ]


def run_single_strategy(
    data: list[MarketData],
    strategy: Strategy,
    initial_cash: float,
) -> BacktestResult:
    return _ENGINE.run(
        data=data,
        strategy=strategy,
        initial_cash=initial_cash,
        commission_rate=_COMMISSION_RATE,
    )


def run_all_strategies(
    data: list[MarketData],
    initial_cash: float,
) -> list[BacktestResult]:
    strategies: list[Strategy] = [
        MovingAverageCrossStrategy(),
        RSIStrategy(),
        MomentumStrategy(),
        BuyAndHoldStrategy(),
    ]
    return [run_single_strategy(data, s, initial_cash) for s in strategies]


def compare_results(results: list[BacktestResult]) -> None:
    sorted_results = sorted(results, key=lambda r: (-r.total_return_pct, r.mdd))
    for r in sorted_results:
        print(f"Strategy: {r.strategy_name}")
        print(f"Return: {r.total_return_pct:.1f}%")
        print(f"MDD: {r.mdd:.1f}%")
        print(f"Win Rate: {r.win_rate:.1f}%")
        print(f"Trades: {r.num_trades}")
        print("-" * 25)
