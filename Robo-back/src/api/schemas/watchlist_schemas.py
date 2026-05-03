from pydantic import BaseModel


class WatchlistRequest(BaseModel):
    ticker: str
