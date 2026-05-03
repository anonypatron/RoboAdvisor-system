from fastapi import APIRouter, Depends

from src.api.routers.deps import get_dashboard_usecase
from src.api.schemas.dashboard_schemas import DashboardResponse, HoldingResponse
from src.application.usecases import GetDashboardUseCase

router = APIRouter()


@router.get("", response_model=DashboardResponse)
def get_dashboard(usecase: GetDashboardUseCase = Depends(get_dashboard_usecase)):
    portfolio = usecase.execute()
    return DashboardResponse(
        total_asset=portfolio.total_asset,
        cash_balance=portfolio.cash_balance,
        stock_value=portfolio.stock_value,
        total_profit=portfolio.total_profit,
        total_return_rate=portfolio.total_return_rate,
        holdings=[
            HoldingResponse(
                ticker=h.ticker,
                qty=h.quantity,
                avg_price=round(h.average_price, 2),
                current_price=round(h.current_price, 2),
                market_value=h.market_value,
                profit_amount=h.profit_amount,
                return_pct=h.return_pct,
            )
            for h in portfolio.holdings
        ],
    )
