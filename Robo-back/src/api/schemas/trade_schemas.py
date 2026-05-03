from pydantic import BaseModel


class TradeRequest(BaseModel):
    ticker: str
    amount: float


class SellRequest(BaseModel):
    ticker: str
    quantity: int


class TradeResponse(BaseModel):
    status: str
    message: str
    price: float
