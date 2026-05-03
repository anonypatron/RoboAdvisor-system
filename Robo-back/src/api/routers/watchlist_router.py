from fastapi import APIRouter, Depends

from src.api.routers.deps import (
    get_add_watchlist_usecase,
    get_remove_watchlist_usecase,
    get_search_usecase,
    get_watchlist_usecase,
)
from src.api.schemas.watchlist_schemas import WatchlistRequest
from src.application.usecases import (
    AddWatchlistUseCase,
    GetWatchlistUseCase,
    RemoveWatchlistUseCase,
    SearchStocksUseCase,
)

router = APIRouter()


@router.get("")
def get_watchlist(usecase: GetWatchlistUseCase = Depends(get_watchlist_usecase)):
    return usecase.execute()


@router.post("")
def add_to_watchlist(
    req: WatchlistRequest,
    usecase: AddWatchlistUseCase = Depends(get_add_watchlist_usecase),
):
    return usecase.execute(req.ticker)


@router.delete("/{ticker}")
def remove_from_watchlist(
    ticker: str,
    usecase: RemoveWatchlistUseCase = Depends(get_remove_watchlist_usecase),
):
    return usecase.execute(ticker)


@router.get("/search")
def search_stocks(
    q: str,
    usecase: SearchStocksUseCase = Depends(get_search_usecase),
):
    return usecase.execute(q)
