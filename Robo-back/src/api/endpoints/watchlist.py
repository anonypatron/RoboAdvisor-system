from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from src.core.database import get_db, Watchlist, StockPrice

router = APIRouter()

class WatchlistRequest(BaseModel):
    ticker: str

@router.get("")
def get_watchlist(db: Session = Depends(get_db)):
    """관심 종목 리스트 조회"""
    return [r.ticker for r in db.query(Watchlist).all()]

@router.post("")
def add_to_watchlist(req: WatchlistRequest, db: Session = Depends(get_db)):
    """관심 종목 추가"""
    exists = db.query(Watchlist).filter(Watchlist.ticker == req.ticker).first()
    if exists:
        return {"message": "Already in watchlist"}
    db.add(Watchlist(ticker=req.ticker))
    db.commit()
    return {"message": "Added"}

@router.delete("/{ticker}")
def remove_from_watchlist(ticker: str, db: Session = Depends(get_db)):
    """관심 종목 삭제"""
    item = db.query(Watchlist).filter(Watchlist.ticker == ticker).first()
    if item:
        db.delete(item)
        db.commit()
    return {"message": "Removed"}

@router.get("/search")
def search_stocks(q: str, db: Session = Depends(get_db)):
    """종목 검색 (DB에 있는 종목 중에서)"""
    # 대소문자 구분 없이 검색
    results = db.query(StockPrice.ticker).filter(StockPrice.ticker.ilike(f"%{q}%")).distinct().limit(10).all()
    return [r[0] for r in results]
