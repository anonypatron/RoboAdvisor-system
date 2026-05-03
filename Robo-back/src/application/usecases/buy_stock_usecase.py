from __future__ import annotations

from dataclasses import dataclass

from src.domain.repositories.stock_repository import StockRepository
from src.domain.repositories.trade_repository import TradeRepository


@dataclass
class BuyStockInput:
    ticker: str
    amount: float


@dataclass
class BuyStockOutput:
    success: bool
    price: float
    message: str


class BuyStockUseCase:
    def __init__(self, stock_repo: StockRepository, trade_repo: TradeRepository):
        self._stock_repo = stock_repo
        self._trade_repo = trade_repo

    def execute(self, inp: BuyStockInput) -> BuyStockOutput:
        price = self._stock_repo.get_latest_price(inp.ticker)
        if price is None:
            return BuyStockOutput(success=False, price=0.0, message="Ticker not found")

        success = self._trade_repo.buy(inp.ticker, price, inp.amount)
        if not success:
            return BuyStockOutput(
                success=False,
                price=price,
                message="Insufficient cash balance or invalid order amount",
            )

        return BuyStockOutput(
            success=True,
            price=price,
            message=f"{inp.ticker} buy order executed",
        )
