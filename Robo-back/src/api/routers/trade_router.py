from fastapi import APIRouter, Depends, HTTPException

from src.api.routers.deps import get_buy_usecase, get_sell_usecase
from src.api.schemas.trade_schemas import SellRequest, TradeRequest, TradeResponse
from src.application.usecases import BuyStockInput, BuyStockUseCase, SellStockInput, SellStockUseCase

router = APIRouter()


@router.post("/buy", response_model=TradeResponse)
def buy_stock(
    request: TradeRequest,
    usecase: BuyStockUseCase = Depends(get_buy_usecase),
):
    result = usecase.execute(BuyStockInput(ticker=request.ticker, amount=request.amount))
    if not result.success:
        status_code = 404 if result.message == "Ticker not found" else 400
        raise HTTPException(status_code=status_code, detail=result.message)
    return TradeResponse(status="success", message=result.message, price=result.price)


@router.post("/sell", response_model=TradeResponse)
def sell_stock(
    request: SellRequest,
    usecase: SellStockUseCase = Depends(get_sell_usecase),
):
    result = usecase.execute(SellStockInput(ticker=request.ticker, quantity=request.quantity))
    if not result.success:
        status_code = 404 if result.message == "Ticker not found" else 400
        raise HTTPException(status_code=status_code, detail=result.message)
    return TradeResponse(status="success", message=result.message, price=result.price)
