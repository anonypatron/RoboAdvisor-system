from __future__ import annotations

from src.domain.entities import Portfolio
from src.domain.repositories.trade_repository import TradeRepository


class GetDashboardUseCase:
    def __init__(self, trade_repo: TradeRepository):
        self._trade_repo = trade_repo

    def execute(self) -> Portfolio:
        return self._trade_repo.get_portfolio()
