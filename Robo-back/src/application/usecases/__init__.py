from src.application.usecases.add_watchlist_usecase import AddWatchlistUseCase
from src.application.usecases.buy_stock_usecase import BuyStockInput, BuyStockUseCase
from src.application.usecases.get_dashboard_usecase import GetDashboardUseCase
from src.application.usecases.get_recommendations_usecase import GetRecommendationsUseCase
from src.application.usecases.get_watchlist_usecase import GetWatchlistUseCase
from src.application.usecases.remove_watchlist_usecase import RemoveWatchlistUseCase
from src.application.usecases.search_stocks_usecase import SearchStocksUseCase
from src.application.usecases.sell_stock_usecase import SellStockInput, SellStockUseCase
from src.application.usecases.run_backtest_comparison_usecase import (
    BuyAndHoldStrategy,
    compare_results,
    run_all_strategies,
    run_single_strategy,
)

__all__ = [
    "GetDashboardUseCase",
    "BuyStockUseCase",
    "BuyStockInput",
    "SellStockUseCase",
    "SellStockInput",
    "GetRecommendationsUseCase",
    "GetWatchlistUseCase",
    "AddWatchlistUseCase",
    "RemoveWatchlistUseCase",
    "SearchStocksUseCase",
    "run_single_strategy",
    "run_all_strategies",
    "compare_results",
    "BuyAndHoldStrategy",
]
