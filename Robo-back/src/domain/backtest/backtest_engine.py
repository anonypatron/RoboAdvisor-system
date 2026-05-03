from __future__ import annotations

from src.domain.backtest.backtest_result import BacktestResult
from src.domain.backtest.portfolio_tracker import PortfolioTracker
from src.domain.backtest.trade_executor import TradeExecutor
from src.domain.backtest.trade_log import TradeLog
from src.domain.entities import MarketData
from src.domain.entities.trade_signal import SignalType, TradeSignal
from src.domain.strategies.strategy import Strategy


class BacktestEngine:
    def run(
        self,
        data: list[MarketData],
        strategy: Strategy,
        initial_cash: float,
        commission_rate: float = 0.001,
    ) -> BacktestResult:
        if not data:
            return BacktestResult.build("", strategy.__class__.__name__, initial_cash, initial_cash, [], [])

        sorted_data = sorted(data, key=lambda d: d.date)
        signals = strategy.generate(sorted_data)

        # 같은 날짜에 복수 시그널이 있으면 마지막 기준 적용
        signal_map: dict[object, TradeSignal] = {
            s.date: s
            for s in signals
            if s.signal in (SignalType.BUY, SignalType.SELL)
        }

        tracker = PortfolioTracker(initial_cash=initial_cash)
        executor = TradeExecutor(commission_rate=commission_rate)
        trade_logs: list[TradeLog] = []

        for i, market in enumerate(sorted_data):
            prices = {market.ticker: market.close}

            # 1) snapshot 먼저 기록
            tracker.record_snapshot(market.date, prices)

            # 2) 시그널 체결: 다음 날 close 기준 (look-ahead 방지)
            signal = signal_map.get(market.date)
            if signal is None or i + 1 >= len(sorted_data):
                continue

            next_day = sorted_data[i + 1]
            execution_signal = TradeSignal(
                ticker=signal.ticker,
                date=next_day.date,
                signal=signal.signal,
                price=next_day.close,
                strategy_name=signal.strategy_name,
            )

            new_cash, new_holdings, log = executor.execute(
                execution_signal, tracker.cash, tracker.holdings
            )
            if log:
                tracker.cash = new_cash
                tracker.holdings = new_holdings
                trade_logs.append(log)

        ticker = sorted_data[0].ticker
        final_prices = {ticker: sorted_data[-1].close}

        return BacktestResult.build(
            ticker=ticker,
            strategy_name=strategy.name,
            initial_cash=initial_cash,
            final_asset=tracker.total_asset(final_prices),
            trade_logs=trade_logs,
            daily_snapshots=tracker.snapshots,
        )
