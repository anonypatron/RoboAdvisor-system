from sqlalchemy import create_engine, Column, String, Float, Date, BigInteger, ForeignKey, Integer, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from dotenv import load_dotenv

import os
import datetime

load_dotenv()

DB_URL = os.getenv("DB_URL")
if not DB_URL:
    raise ValueError("DB_URL is not set in .env file")

engine = create_engine(DB_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class StockPrice(Base):
    __tablename__ = "stock_prices"

    ticker = Column(String(10), primary_key=True, index=True)
    date = Column(Date, primary_key=True, index=True)
    
    open = Column(Float)
    high = Column(Float)
    low = Column(Float)
    close = Column(Float)
    adj_close = Column(Float)
    volume = Column(BigInteger)

class Position(Base):
    __tablename__ = "positions"
    
    ticker = Column(String(10), primary_key=True, index=True)
    quantity = Column(Integer, default=0)
    average_price = Column(Float, default=0.0)
    current_price = Column(Float, default=0.0)

class TradeLog(Base):
    __tablename__ = "trade_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    ticker = Column(String(10))
    action = Column(String(4))
    quantity = Column(Integer)
    price = Column(Float)
    total_amount = Column(Float)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

def init_db():
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully.")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
