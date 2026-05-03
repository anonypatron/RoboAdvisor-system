"""FastAPI dependency injection helpers."""
from __future__ import annotations

from typing import Annotated

from fastapi import Depends
from sqlalchemy.orm import Session

from src.application.usecases import (
    AddWatchlistUseCase,
    BuyStockUseCase,
    GetDashboardUseCase,
    GetRecommendationsUseCase,
    GetWatchlistUseCase,
    RemoveWatchlistUseCase,
    SearchStocksUseCase,
    SellStockUseCase,
)
from src.core.database import get_db
from src.infrastructure.repositories import (
    StockRepositoryImpl,
    TradeRepositoryImpl,
    WatchlistRepositoryImpl,
)


def get_stock_repo(db: Session = Depends(get_db)) -> StockRepositoryImpl:
    return StockRepositoryImpl(db)


def get_trade_repo(db: Session = Depends(get_db)) -> TradeRepositoryImpl:
    return TradeRepositoryImpl(db)


def get_watchlist_repo(db: Session = Depends(get_db)) -> WatchlistRepositoryImpl:
    return WatchlistRepositoryImpl(db)


def get_dashboard_usecase(
    trade_repo: TradeRepositoryImpl = Depends(get_trade_repo),
) -> GetDashboardUseCase:
    return GetDashboardUseCase(trade_repo)


def get_buy_usecase(
    stock_repo: StockRepositoryImpl = Depends(get_stock_repo),
    trade_repo: TradeRepositoryImpl = Depends(get_trade_repo),
) -> BuyStockUseCase:
    return BuyStockUseCase(stock_repo, trade_repo)


def get_sell_usecase(
    stock_repo: StockRepositoryImpl = Depends(get_stock_repo),
    trade_repo: TradeRepositoryImpl = Depends(get_trade_repo),
) -> SellStockUseCase:
    return SellStockUseCase(stock_repo, trade_repo)


def get_recommendations_usecase(
    trade_repo: TradeRepositoryImpl = Depends(get_trade_repo),
) -> GetRecommendationsUseCase:
    return GetRecommendationsUseCase(trade_repo)


def get_watchlist_usecase(
    watchlist_repo: WatchlistRepositoryImpl = Depends(get_watchlist_repo),
) -> GetWatchlistUseCase:
    return GetWatchlistUseCase(watchlist_repo)


def get_add_watchlist_usecase(
    watchlist_repo: WatchlistRepositoryImpl = Depends(get_watchlist_repo),
) -> AddWatchlistUseCase:
    return AddWatchlistUseCase(watchlist_repo)


def get_remove_watchlist_usecase(
    watchlist_repo: WatchlistRepositoryImpl = Depends(get_watchlist_repo),
) -> RemoveWatchlistUseCase:
    return RemoveWatchlistUseCase(watchlist_repo)


def get_search_usecase(
    stock_repo: StockRepositoryImpl = Depends(get_stock_repo),
) -> SearchStocksUseCase:
    return SearchStocksUseCase(stock_repo)
