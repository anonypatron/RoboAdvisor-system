from abc import ABC, abstractmethod
import pandas as pd

class BaseStrategy(ABC):
    """
    모든 투자 전략의 부모 클래스 (인터페이스)
    """
    
    @abstractmethod
    def generate_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        주가 데이터(df)를 받아 매수/매도 신호를 추가해서 반환해야 합니다.
        """
        pass
    
    def add_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        보조지표(이평선, RSI 등)를 계산하는 공통 메서드
        """
        return df
