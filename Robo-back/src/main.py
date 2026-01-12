from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from apscheduler.schedulers.background import BackgroundScheduler

from src.core.database import init_db
from src.api.endpoints import dashboard, trade, recommendation, stock, watchlist
from src.core.scheduler import update_daily_recommendations

import datetime

# 시작하기
# 1. 데이터 수집하기
# uv run python -m src.data_loader.collector

# 2. api endpoint 열기
# uv run python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

# --- 스케줄러 설정 --- 
scheduler = BackgroundScheduler()

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()

    scheduler.add_job(update_daily_recommendations, 'date', run_date=datetime.datetime.now() + datetime.timedelta(seconds=5))
    scheduler.start()
    print("Scheduler Started!")
    yield
    
    scheduler.shutdown()
    print("Scheduler Shutdown")

app = FastAPI(
    title="Robo-Advisor API",
    description="Robo-Advisor Backend for Flutter App",
    version="1.0.0",
    lifespan=lifespan,
)

init_db()
@app.get("/")
def read_root():
    return {"status": "ok", "message": "QuantRobo Server v2 Running 🚀"}

app.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])
app.include_router(trade.router, prefix="/trade", tags=["Trade"])
app.include_router(recommendation.router, prefix="/recommendations", tags=["Recommendation"])
app.include_router(stock.router, prefix="/stock", tags=["Stock Info"])
app.include_router(watchlist.router, prefix="/watchlist", tags=["Watchlist"])
