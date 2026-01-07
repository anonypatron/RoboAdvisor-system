import pandas as pd
from typing import List, Dict
from src.strategies.base import BaseStrategy
from src.core.database import SessionLocal, StockPrice

class RoboAdvisor:
    """
    [Context] 전략을 주입받아 실행하는 로보어드바이저 본체
    """
    def __init__(self, strategy: BaseStrategy):
        self.strategy = strategy
        self.db = SessionLocal()

    def set_strategy(self, strategy: BaseStrategy):
        """실행 중에 전략을 교체할 수 있습니다."""
        self.strategy = strategy

    def get_data(self, ticker: str) -> pd.DataFrame:
        """DB에서 특정 종목의 데이터를 가져옵니다."""
        query = self.db.query(StockPrice).filter(StockPrice.ticker == ticker).statement
        df = pd.read_sql(query, self.db.bind)
        if not df.empty:
            df = df.sort_values('date')
        return df

    def screen_market(self, tickers: List[str], lookback_days=300) -> List[Dict]:
        """
        주어진 티커 리스트를 모두 검사하여
        현재 시점에 '매수 신호'가 뜬 종목을 찾습니다.
        """
        buy_candidates = []
        total = len(tickers)
        
        print(f"🕵️ Scanning {total} tickers with {self.strategy.__class__.__name__}...")

        for idx, ticker in enumerate(tickers):
            if idx % 50 == 0:
                print(f"   Progress: {idx}/{total}...")

            df = self.get_data(ticker)
            
            if len(df) < lookback_days:
                continue

            result_df = self.strategy.generate_signals(df)
            latest = result_df.iloc[-1]
            
            # 조건 1: 현재 보유 신호(signal=1) 상태인가?
            # 조건 2: 오늘 막 매수 신호(position=1)가 떴는가? (선택 가능)
            if latest['position'] == 1: 
                buy_candidates.append({
                    'ticker': ticker,
                    'date': latest['date'],
                    'close': latest['close'],
                    'signal_type': 'BUY'
                })
        
        return buy_candidates
