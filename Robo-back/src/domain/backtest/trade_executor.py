from __future__ import annotations

import math
from typing import Optional

from src.domain.backtest.trade_log import TradeAction, TradeLog
from src.domain.entities.trade_signal import SignalType, TradeSignal


class TradeExecutor:
    def __init__(self, commission_rate: float = 0.001) -> None:
        self.commission_rate = commission_rate

    def execute(
        self,
        signal: TradeSignal,
        cash: float,
        holdings: dict[str, tuple[int, float]],
    ) -> tuple[float, dict[str, tuple[int, float]], Optional[TradeLog]]:
        if signal.signal == SignalType.BUY:
            return self._buy(signal, cash, holdings)
        if signal.signal == SignalType.SELL:
            return self._sell(signal, cash, holdings)
        return cash, holdings, None

    def _buy(
        self,
        signal: TradeSignal,
        cash: float,
        holdings: dict[str, tuple[int, float]],
    ) -> tuple[float, dict[str, tuple[int, float]], Optional[TradeLog]]:
        price = signal.price
        quantity = math.floor(cash / (price * (1 + self.commission_rate)))
        if quantity == 0:
            return cash, holdings, None

        new_cash = cash - price * quantity * (1 + self.commission_rate)
        updated = dict(holdings)

        if signal.ticker in updated:
            prev_qty, prev_avg = updated[signal.ticker]
            total_qty = prev_qty + quantity
            avg_price = (prev_avg * prev_qty + price * quantity) / total_qty
            updated[signal.ticker] = (total_qty, avg_price)
        else:
            updated[signal.ticker] = (quantity, price)

        return new_cash, updated, TradeLog(
            date=signal.date,
            ticker=signal.ticker,
            action=TradeAction.BUY,
            price=price,
            quantity=quantity,
            cash_after=new_cash,
            profit=0.0,
        )

    def _sell(
        self,
        signal: TradeSignal,
        cash: float,
        holdings: dict[str, tuple[int, float]],
    ) -> tuple[float, dict[str, tuple[int, float]], Optional[TradeLog]]:
        if signal.ticker not in holdings:
            return cash, holdings, None

        quantity, avg_price = holdings[signal.ticker]
        price = signal.price
        new_cash = cash + price * quantity * (1 - self.commission_rate)

        updated = dict(holdings)
        del updated[signal.ticker]

        return new_cash, updated, TradeLog(
            date=signal.date,
            ticker=signal.ticker,
            action=TradeAction.SELL,
            price=price,
            quantity=quantity,
            cash_after=new_cash,
            profit=(price - avg_price) * quantity,
        )
