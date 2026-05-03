from fastapi import APIRouter, Depends

from src.api.routers.deps import get_recommendations_usecase
from src.application.usecases import GetRecommendationsUseCase

router = APIRouter()


@router.get("")
def get_recommendations(usecase: GetRecommendationsUseCase = Depends(get_recommendations_usecase)):
    return usecase.execute()
