import logging
import os
from contextlib import asynccontextmanager
from zoneinfo import ZoneInfo

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI

from src.api.endpoints import dashboard, recommendation, stock, trade, watchlist
from src.core.database import init_db
from src.core.scheduler import update_daily_recommendations

# uv run python -m uvicorn src.main:app --reload
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
logger = logging.getLogger(__name__)

SCHEDULER_TIMEZONE = os.getenv("SCHEDULER_TIMEZONE", "Asia/Seoul")
SCHEDULE_HOUR = int(os.getenv("RECOMMENDATION_SCHEDULE_HOUR", "8"))
SCHEDULE_MINUTE = int(os.getenv("RECOMMENDATION_SCHEDULE_MINUTE", "0"))

scheduler = BackgroundScheduler(timezone=ZoneInfo(SCHEDULER_TIMEZONE))


def configure_scheduler() -> None:
    scheduler.add_job(
        update_daily_recommendations,
        trigger="cron",
        hour=SCHEDULE_HOUR,
        minute=SCHEDULE_MINUTE,
        id="daily_recommendation_update",
        replace_existing=True,
        max_instances=1,
        coalesce=True,
    )

    job = scheduler.get_job("daily_recommendation_update")
    logger.info(
        "추천 스케줄 등록 완료: timezone=%s pending=%s",
        SCHEDULER_TIMEZONE,
        job.pending if job else None,
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    configure_scheduler()
    scheduler.start()
    job = scheduler.get_job("daily_recommendation_update")
    logger.info(
        "스케줄러 시작: next_run=%s",
        getattr(job, "next_run_time", None) if job else None,
    )

    try:
        yield
    finally:
        scheduler.shutdown(wait=False)
        logger.info("스케줄러 종료")


app = FastAPI(
    title="Robo-Advisor API",
    description="Robo-Advisor Backend for Flutter App",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/")
def read_root():
    return {"status": "ok", "message": "QuantRobo Server v2 Running"}


app.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])
app.include_router(trade.router, prefix="/trade", tags=["Trade"])
app.include_router(recommendation.router, prefix="/recommendations", tags=["Recommendation"])
app.include_router(stock.router, prefix="/stock", tags=["Stock Info"])
app.include_router(watchlist.router, prefix="/watchlist", tags=["Watchlist"])
