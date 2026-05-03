from __future__ import annotations

import datetime
from dataclasses import dataclass, field

from src.domain.backtest.trade_log import TradeAction, TradeLog


@dataclass(frozen=True)
class BacktestResult:
    ticker: str
    strategy_name: str
    initial_cash: float
    final_asset: float
    total_return_pct: float
    mdd: float
    win_rate: float
    num_trades: int
    trade_logs: tuple[TradeLog, ...] = field(default_factory=tuple)
    daily_snapshots: tuple[tuple[datetime.date, float], ...] = field(default_factory=tuple)

    @staticmethod
    def build(
        ticker: str,
        strategy_name: str,
        initial_cash: float,
        final_asset: float,
        trade_logs: list[TradeLog],
        daily_snapshots: list[tuple[datetime.date, float]],
    ) -> BacktestResult:
        return BacktestResult(
            ticker=ticker,
            strategy_name=strategy_name,
            initial_cash=initial_cash,
            final_asset=final_asset,
            total_return_pct=round((final_asset - initial_cash) / initial_cash * 100, 4),
            mdd=round(_calc_mdd(daily_snapshots), 4),
            win_rate=round(_calc_win_rate(trade_logs), 4),
            num_trades=len(trade_logs),
            trade_logs=tuple(trade_logs),
            daily_snapshots=tuple(daily_snapshots),
        )


def _calc_mdd(snapshots: list[tuple[datetime.date, float]]) -> float:
    if not snapshots:
        return 0.0
    peak = snapshots[0][1]
    mdd = 0.0
    for _, value in snapshots:
        peak = max(peak, value)
        drawdown = (peak - value) / peak if peak > 0 else 0.0
        mdd = max(mdd, drawdown)
    return mdd * 100


def _calc_win_rate(trade_logs: list[TradeLog]) -> float:
    sells = [log for log in trade_logs if log.action == TradeAction.SELL]
    if not sells:
        return 0.0
    wins = sum(1 for log in sells if log.profit > 0)
    return wins / len(sells) * 100
