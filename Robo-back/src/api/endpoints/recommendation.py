from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from src.core.database import get_db, StockPrice
from src.core.advisor import RoboAdvisor
from src.strategies.advanced import GoldenCrossVolumeStrategy
from src.core.database import RecommendationResult

router = APIRouter()
advisor = RoboAdvisor(GoldenCrossVolumeStrategy(vol_ratio=1.5))

@router.get("")
def get_recommendations(db: Session = Depends(get_db)):
    results = db.query(RecommendationResult).all()
    data = []

    for result in results:
        data.append({
            "ticker": result.ticker,
            "date": result.date,
            "close": result.close_price,
            "signal_type": result.signal_type,
        })

    return data
