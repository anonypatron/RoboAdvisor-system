import pandas as pd
import yfinance as yf
import requests
from io import StringIO
from src.core.database import SessionLocal, StockPrice, engine
from sqlalchemy.dialects.postgresql import insert
import datetime

class DataLoader:
    def __init__(self):
        self.db = SessionLocal()

    def get_sp500_tickers(self):
        """위키백과에서 S&P 500 종목 리스트를 가져옵니다."""
        print("🔍 Fetching S&P 500 tickers...")
        url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            
            tables = pd.read_html(StringIO(response.text))
            
            df = tables[0]
            tickers = df['Symbol'].tolist()
            tickers = [t.replace('.', '-') for t in tickers]
            print(f"✅ Found {len(tickers)} tickers.")
            return tickers
            
        except Exception as e:
            print(f"❌ Error fetching tickers: {e}")
            return []

    def fetch_and_save_data(self, ticker, start_date="2020-01-01"):
        """특정 종목의 데이터를 가져와 DB에 저장합니다 (Upsert)."""
        print(f"📥 Downloading data for {ticker}...")
        
        try:
            df = yf.download(ticker, start=start_date, progress=False)
            if df.empty:
                print(f"⚠️ No data for {ticker}")
                return
            
            df = df.reset_index()
            if isinstance(df.columns, pd.MultiIndex):
                df.columns = df.columns.get_level_values(0)
            
            df.columns = df.columns.str.lower().str.replace(' ', '_')
            df['ticker'] = ticker
            
            records = df.to_dict(orient='records')
            
            stmt = insert(StockPrice).values(records)
            stmt = stmt.on_conflict_do_update(
                index_elements=['ticker', 'date'], # 중복 기준
                set_={
                    'open': stmt.excluded.open,
                    'high': stmt.excluded.high,
                    'low': stmt.excluded.low,
                    'close': stmt.excluded.close,
                    'adj_close': stmt.excluded.adj_close,
                    'volume': stmt.excluded.volume,
                }
            )
            
            with engine.connect() as conn:
                conn.execute(stmt)
                conn.commit()
                
            print(f"💾 Saved {len(records)} rows for {ticker}")

        except Exception as e:
            print(f"❌ Error fetching {ticker}: {e}")

    def run_daily_update(self):
        """전체 종목 업데이트 실행"""
        tickers = self.get_sp500_tickers()
        
        for ticker in tickers: 
            self.fetch_and_save_data(ticker)

if __name__ == "__main__":
    from src.core.database import init_db
    
    init_db()
    
    loader = DataLoader()
    loader.run_daily_update()
