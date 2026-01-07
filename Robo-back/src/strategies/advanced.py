import pandas as pd
import numpy as np
from src.strategies.base import BaseStrategy

class GoldenCrossVolumeStrategy(BaseStrategy):
    """
    [복합 전략]
    1. 이동평균선 골든 크로스 (50일선이 200일선 돌파)
    2. 거래량 급증 (20일 평균 거래량 대비 1.5배 이상)
    -> 두 조건이 동시에 만족할 때만 매수
    """
    
    def __init__(self, short_window=50, long_window=200, vol_window=20, vol_ratio=1.5):
        self.short_window = short_window
        self.long_window = long_window
        self.vol_window = vol_window
        self.vol_ratio = vol_ratio

    def add_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        # 1. 가격 이평선
        df['sma_short'] = df['close'].rolling(window=self.short_window).mean()
        df['sma_long'] = df['close'].rolling(window=self.long_window).mean()
        
        # 2. 거래량 이평선 (평소 거래량 기준)
        df['vol_ma'] = df['volume'].rolling(window=self.vol_window).mean()
        
        return df

    def generate_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        df = self.add_indicators(df)
        df['signal'] = 0

        # --- 조건 정의 ---
        
        # 조건 1: 골든 크로스 발생 (어제는 숏<롱, 오늘은 숏>롱)
        # shift(1)은 '어제 데이터'를 의미합니다.
        bullish_cross = (
            (df['sma_short'] > df['sma_long']) & 
            (df['sma_short'].shift(1) <= df['sma_long'].shift(1))
        )

        # 조건 2: 거래량 폭발 (오늘 거래량 > 평소 거래량 * 1.5배)
        vol_spike = (df['volume'] > df['vol_ma'] * self.vol_ratio)

        # --- 최종 신호 결합 (AND 연산) ---
        # 두 조건이 모두 True인 날만 1로 설정
        buy_condition = bullish_cross & vol_spike
        
        df.loc[buy_condition, 'signal'] = 1
        
        # 매도 로직 (단순화: 데드 크로스 나면 매도)
        bearish_cross = (df['sma_short'] < df['sma_long'])
        df.loc[bearish_cross, 'signal'] = 0
        
        df['position'] = df['signal'].diff()
        
        return df
