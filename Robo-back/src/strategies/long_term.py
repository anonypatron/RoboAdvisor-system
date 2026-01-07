import pandas as pd
import numpy as np
from src.strategies.base import BaseStrategy

class GoldenCrossStrategy(BaseStrategy):
    """
    장기 투자용 골든 크로스 전략
    - 50일 이동평균선(Short SMA)
    - 200일 이동평균선(Long SMA)
    """
    
    def __init__(self, short_window=50, long_window=200):
        self.short_window = short_window
        self.long_window = long_window

    def add_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """이동평균선 계산"""
        df = df.copy()
        # 종가(close) 기준 이동평균선 계산
        df['sma_short'] = df['close'].rolling(window=self.short_window).mean()
        df['sma_long'] = df['close'].rolling(window=self.long_window).mean()
        return df

    def generate_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        """매매 신호 생성 (1: 매수, -1: 매도, 0: 관망)"""
        df = self.add_indicators(df)
        
        # 신호 초기화
        df['signal'] = 0
        
        # 골든 크로스 조건: 
        # 단기 이평선이 장기 이평선보다 높으면 '보유(1)' 상태로 간주
        # 실제 매매는 이 상태가 0 -> 1로 바뀔 때(크로스) 발생
        df.loc[df['sma_short'] > df['sma_long'], 'signal'] = 1
        
        # position 컬럼 생성: 어제와 오늘의 신호 차이를 계산
        # 1.0 (0 -> 1): 매수 타이밍 (Golden Cross)
        # -1.0 (1 -> 0): 매도 타이밍 (Dead Cross)
        df['position'] = df['signal'].diff()
        
        return df
