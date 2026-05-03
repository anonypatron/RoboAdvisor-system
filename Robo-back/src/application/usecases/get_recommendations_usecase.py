from __future__ import annotations

from src.domain.repositories.trade_repository import TradeRepository


class GetRecommendationsUseCase:
    def __init__(self, trade_repo: TradeRepository):
        self._trade_repo = trade_repo

    def execute(self) -> list[dict]:
        return self._trade_repo.get_recommendations()
