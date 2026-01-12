import datetime
from sqlalchemy.orm import Session
from src.core.database import SessionLocal, StockPrice, RecommendationResult
from src.core.advisor import RoboAdvisor
from src.strategies.advanced import GoldenCrossVolumeStrategy

advisor = RoboAdvisor(GoldenCrossVolumeStrategy(vol_ratio=1.5))

def update_daily_recommendations():
    """
    [배치 작업] 
    1. S&P 500 전 종목 스캔
    2. 매수 신호 종목 발굴
    3. DB 결과 테이블 갱신 (기존 데이터 지우고 새로 저장)
    """
    print("⏰ [Scheduler] Daily Market Scan Started...")
    db: Session = SessionLocal()
    
    try:
        tickers = [r[0] for r in db.query(StockPrice.ticker).distinct().all()]
        if not tickers:
            print("⚠️ No data found in DB.")
            return

        results = advisor.screen_market(tickers)
        print(f"✅ Analysis Complete. Found {len(results)} candidates.")

        db.query(RecommendationResult).delete()
        
        for item in results:
            rec = RecommendationResult(
                ticker=item['ticker'],
                date=item['date'], # 이미 datetime.date 객체임
                close_price=item['close'],
                signal_type="Golden Cross + Volume" # 지금은 전략이 하나지만 나중에 확장 가능
            )
            db.add(rec)
        
        db.commit()
        print("💾 [Scheduler] Results saved to DB.")
        
    except Exception as e:
        print(f"❌ [Scheduler] Error: {e}")
        db.rollback()
    finally:
        db.close()
