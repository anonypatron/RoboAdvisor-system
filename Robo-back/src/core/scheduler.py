import logging

from sqlalchemy.orm import Session

from src.core.advisor import RoboAdvisor
from src.core.database import RecommendationResult, SessionLocal, StockPrice
from src.strategies.advanced import GoldenCrossVolumeStrategy

logger = logging.getLogger(__name__)
advisor = RoboAdvisor(GoldenCrossVolumeStrategy(vol_ratio=1.5))


def update_daily_recommendations() -> None:
    logger.info("추천 종목 일일 스캔 시작")
    db: Session = SessionLocal()

    try:
        tickers = [row[0] for row in db.query(StockPrice.ticker).distinct().all()]
        if not tickers:
            logger.warning("stock_prices 테이블에 데이터가 없어 추천 생성을 건너뜁니다.")
            return

        results = advisor.screen_market(db, tickers)
        logger.info("추천 후보 %s건 생성", len(results))

        db.query(RecommendationResult).delete()

        for item in results:
            db.add(
                RecommendationResult(
                    ticker=item["ticker"],
                    date=item["date"],
                    close_price=item["close"],
                    signal_type="Golden Cross + Volume",
                )
            )

        db.commit()
        logger.info("추천 결과 저장 완료")
    except Exception:
        logger.exception("추천 스케줄 실행 중 오류 발생")
        db.rollback()
        raise
    finally:
        db.close()
