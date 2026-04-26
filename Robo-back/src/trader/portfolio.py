from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import func
from sqlalchemy.orm import Session

from src.core.database import Position, StockPrice, TradeLog


@dataclass
class PositionMetrics:
    ticker: str
    quantity: int
    average_price: float
    current_price: float
    market_value: float
    profit_amount: float
    return_pct: float


class PortfolioManager:
    def __init__(self, db: Session, initial_cash: float = 10000.0):
        self.db = db
        self.initial_cash = initial_cash

    def get_balance(self) -> float:
        total_bought = (
            self.db.query(func.sum(TradeLog.total_amount))
            .filter(TradeLog.action == "BUY")
            .scalar()
            or 0.0
        )
        total_sold = (
            self.db.query(func.sum(TradeLog.total_amount))
            .filter(TradeLog.action == "SELL")
            .scalar()
            or 0.0
        )
        return round(self.initial_cash - total_bought + total_sold, 2)

    def get_latest_price(self, ticker: str) -> float | None:
        latest_close_row = (
            self.db.query(StockPrice.close)
            .filter(StockPrice.ticker == ticker)
            .order_by(StockPrice.date.desc())
            .first()
        )

        if latest_close_row is None:
            return None

        return float(latest_close_row[0])

    def buy(self, ticker: str, price: float, amount_invest: float) -> bool:
        current_cash = self.get_balance()
        if current_cash < amount_invest:
            return False

        quantity = int(amount_invest / price)
        if quantity <= 0:
            return False

        real_cost = quantity * price
        position = self.db.query(Position).filter(Position.ticker == ticker).first()

        if position is None:
            position = Position(
                ticker=ticker,
                quantity=0,
                average_price=0.0,
                current_price=price,
            )
            self.db.add(position)

        total_quantity = position.quantity + quantity
        total_cost = (position.quantity * position.average_price) + real_cost

        position.quantity = total_quantity
        position.average_price = total_cost / total_quantity
        position.current_price = price

        self.db.add(
            TradeLog(
                ticker=ticker,
                action="BUY",
                quantity=quantity,
                price=price,
                total_amount=real_cost,
            )
        )
        self.db.commit()
        return True

    def sell(self, ticker: str, price: float, quantity: int) -> bool:
        if quantity <= 0:
            return False

        position = self.db.query(Position).filter(Position.ticker == ticker).first()
        if position is None or position.quantity < quantity:
            return False

        proceeds = quantity * price
        position.quantity -= quantity
        position.current_price = price

        if position.quantity == 0:
            self.db.delete(position)

        self.db.add(
            TradeLog(
                ticker=ticker,
                action="SELL",
                quantity=quantity,
                price=price,
                total_amount=proceeds,
            )
        )
        self.db.commit()
        return True

    def _build_position_metrics(self, position: Position) -> PositionMetrics:
        current_price = self.get_latest_price(position.ticker) or float(position.current_price or 0.0)
        market_value = position.quantity * current_price
        cost_basis = position.quantity * position.average_price
        profit_amount = market_value - cost_basis
        return_pct = (profit_amount / cost_basis * 100) if cost_basis > 0 else 0.0

        position.current_price = current_price

        return PositionMetrics(
            ticker=position.ticker,
            quantity=position.quantity,
            average_price=round(position.average_price, 2),
            current_price=round(current_price, 2),
            market_value=round(market_value, 2),
            profit_amount=round(profit_amount, 2),
            return_pct=round(return_pct, 2),
        )

    def calculate_portfolio_value(self) -> dict:
        positions = self.db.query(Position).filter(Position.quantity > 0).all()
        cash_balance = self.get_balance()

        holdings: list[dict] = []
        total_stock_value = 0.0

        for position in positions:
            metrics = self._build_position_metrics(position)
            total_stock_value += metrics.market_value
            holdings.append(
                {
                    "ticker": metrics.ticker,
                    "qty": metrics.quantity,
                    "avg_price": metrics.average_price,
                    "current_price": metrics.current_price,
                    "market_value": metrics.market_value,
                    "profit_amount": metrics.profit_amount,
                    "return_pct": metrics.return_pct,
                }
            )

        self.db.commit()

        total_asset = round(cash_balance + total_stock_value, 2)
        total_profit = round(total_asset - self.initial_cash, 2)
        total_return_rate = round(
            (total_profit / self.initial_cash * 100) if self.initial_cash > 0 else 0.0,
            2,
        )

        return {
            "total_asset": total_asset,
            "cash_balance": round(cash_balance, 2),
            "stock_value": round(total_stock_value, 2),
            "total_profit": total_profit,
            "total_return_rate": total_return_rate,
            "holdings": holdings,
        }

    def get_dashboard_data(self) -> dict:
        return self.calculate_portfolio_value()
