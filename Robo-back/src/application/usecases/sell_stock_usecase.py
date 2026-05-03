from __future__ import annotations

from dataclasses import dataclass

from src.domain.repositories.stock_repository import StockRepository
from src.domain.repositories.trade_repository import TradeRepository


@dataclass
class SellStockInput:
    ticker: str
    quantity: int


@dataclass
class SellStockOutput:
    success: bool
    price: float
    message: str


class SellStockUseCase:
    def __init__(self, stock_repo: StockRepository, trade_repo: TradeRepository):
        self._stock_repo = stock_repo
        self._trade_repo = trade_repo

    def execute(self, inp: SellStockInput) -> SellStockOutput:
        price = self._stock_repo.get_latest_price(inp.ticker)
        if price is None:
            return SellStockOutput(success=False, price=0.0, message="Ticker not found")

        success = self._trade_repo.sell(inp.ticker, price, inp.quantity)
        if not success:
            return SellStockOutput(
                success=False,
                price=price,
                message="Insufficient holdings or invalid sell quantity",
            )

        return SellStockOutput(
            success=True,
            price=price,
            message=f"{inp.ticker} sell order executed",
        )
