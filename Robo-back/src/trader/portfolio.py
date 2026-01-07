from sqlalchemy.orm import Session
from sqlalchemy import func
from src.core.database import SessionLocal, Position, TradeLog, StockPrice

class PortfolioManager:
    def __init__(self, initial_cash=10000.0):
        self.db: Session = SessionLocal()
        self.initial_cash = initial_cash

    def get_balance(self):
        """
        [수정] TradeLog(매매일지)를 기반으로 현재 현금을 정확히 계산
        """
        # 1. 총 매수 금액 합계 (돈 나감)
        total_bought = self.db.query(func.sum(TradeLog.total_amount))\
            .filter(TradeLog.action == "BUY").scalar() or 0.0
            
        # 2. 총 매도 금액 합계 (돈 들어옴)
        total_sold = self.db.query(func.sum(TradeLog.total_amount))\
            .filter(TradeLog.action == "SELL").scalar() or 0.0
            
        # 3. 현재 현금 = 초기자금 - 산돈 + 판돈
        current_cash = self.initial_cash - total_bought + total_sold
        return current_cash

    def buy(self, ticker: str, price: float, amount_invest: float):
        current_cash = self.get_balance() 
        
        if current_cash < amount_invest:
            print(f"❌ [잔고부족] 현금: ${current_cash:.2f} / 필요: ${amount_invest:.2f}")
            return False

        quantity = int(amount_invest / price)
        if quantity == 0:
            return False

        real_cost = quantity * price
        
        # 1. 보유 종목(Position) 업데이트
        position = self.db.query(Position).filter(Position.ticker == ticker).first()
        if not position:
            position = Position(ticker=ticker, quantity=0, average_price=0.0)
            self.db.add(position)
        
        total_qty = position.quantity + quantity
        total_cost = (position.quantity * position.average_price) + real_cost
        position.average_price = total_cost / total_qty
        position.quantity = total_qty
        position.current_price = price 
        
        # 2. 거래 기록(Log) 저장 (이게 저장되어야 get_balance가 변함)
        trade = TradeLog(
            ticker=ticker,
            action="BUY",
            quantity=quantity,
            price=price,
            total_amount=real_cost
        )
        self.db.add(trade)
        self.db.commit()
        
        print(f"✅ [매수체결] {ticker} {quantity}주 @ ${price:.2f}")
        return True

    def get_dashboard_data(self):
        positions = self.db.query(Position).all()
        holdings = []
        total_stock_value = 0.0
        
        for p in positions:
            current_val = p.quantity * p.current_price
            profit = 0.0
            if p.average_price > 0:
                profit = (p.current_price - p.average_price) / p.average_price * 100
            
            total_stock_value += current_val
            
            holdings.append({
                "ticker": p.ticker,
                "qty": p.quantity,
                "avg_price": round(p.average_price, 2),
                "return_pct": round(profit, 2)
            })
            
        current_cash = self.get_balance()
        total_asset = current_cash + total_stock_value
        
        return {
            "total_asset": round(total_asset, 2),
            "cash_balance": round(current_cash, 2),
            "stock_value": round(total_stock_value, 2),
            "holdings": holdings
        }
