import pandas as pd
import numpy as np
from src.strategies.base import BaseStrategy

class RsiStrategy(BaseStrategy):
    """
    단기 투자용 RSI 역추세 전략
    - RSI < 30 : 매수 (과매도 구간)
    - RSI > 70 : 매도 (과매수 구간)
    """
    
    def __init__(self, period=14, buy_threshold=30, sell_threshold=70):
        self.period = period
        self.buy_threshold = buy_threshold
        self.sell_threshold = sell_threshold

    def _calculate_rsi(self, series: pd.Series) -> pd.Series:
        """RSI 지표 계산 로직 (라이브러리 없이 직접 구현)"""
        delta = series.diff()
        
        # 상승분(gain)과 하락분(loss) 분리
        gain = (delta.where(delta > 0, 0)).fillna(0)
        loss = (-delta.where(delta < 0, 0)).fillna(0)
        
        # Wilder의 이동평균 방식 (RSI 표준)
        avg_gain = gain.rolling(window=self.period, min_periods=self.period).mean()
        avg_loss = loss.rolling(window=self.period, min_periods=self.period).mean()
        
        rs = avg_gain / avg_loss
        rsi = 100 - (100 / (1 + rs))
        
        # 초기값 보정 (선택사항이나 정교함을 위해)
        return rsi

    def add_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['rsi'] = self._calculate_rsi(df['close'])
        return df

    def generate_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        df = self.add_indicators(df)
        df['signal'] = 0
        
        # 1. 매수 신호: RSI가 30 미만일 때
        # (일단 간단하게 30 미만이면 보유로 설정)
        df.loc[df['rsi'] < self.buy_threshold, 'signal'] = 1
        
        # 2. 매도 신호: RSI가 70 초과일 때 (signal을 0으로 만듦 -> 매도)
        # 이미 0으로 초기화 되어 있으므로, RSI > 70 이거나 포지션이 없는 경우 0 유지
        
        # 주식은 샀으면 팔기 전까지 들고 있어야 함.
        # RSI < 30 이면 매수 -> 이후 RSI > 70 될 때까지 홀딩
        current_position = 0 # 0: 현금보유, 1: 주식보유
        signals = []
        
        for rsi in df['rsi']:
            if pd.isna(rsi):
                signals.append(0)
                continue
            
            if current_position == 0:
                if rsi < self.buy_threshold:
                    current_position = 1 # 매수
            else:
                if rsi > self.sell_threshold:
                    current_position = 0 # 매도
            
            signals.append(current_position)
            
        df['signal'] = signals
        
        # 포지션 변화(매매 시점) 포착
        df['position'] = df['signal'].diff()
        
        return df
