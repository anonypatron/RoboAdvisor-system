# Robo Advisor

A full-stack robo-advisor system: S&P 500 market data → trading strategies → backtesting → portfolio management → Flutter mobile app.

```
yfinance ──► Strategy Engine ──► Backtest ──► FastAPI ──► Flutter App
                  │                                │
              ML Model                         PostgreSQL
```

---

## Architecture

This project follows **Clean Architecture** across both backend and frontend. Dependencies always point inward.

```
External (yfinance, DB, HTTP)
        │
   Infrastructure  ←── implements interfaces defined in domain
        │
   Application (UseCases)
        │
   Domain (Entities, Strategies, Backtest)  ←── no external dependencies allowed
```

### Backend Layer Responsibilities

| Layer | Location | Responsibility | Must NOT |
|-------|----------|----------------|----------|
| **api** | `src/api/routers/` | Transform request/response; call UseCases | Access DB; write business logic |
| **application** | `src/application/usecases/` | Orchestrate one feature unit | Contain domain logic; access DB directly |
| **domain** | `src/domain/` | Pure business logic; Strategy; Backtest | Import pandas, sklearn, SQLAlchemy |
| **infrastructure** | `src/infrastructure/` | DB access; yfinance; ML training | Contain business logic |

### Backend Data Flow

```
HTTP Request
    │
Router (schema validation only)
    │
UseCase (orchestration)
    ├── Repository (data access interface)
    │       └── RepositoryImpl (DB / external API)
    └── Domain Service (Strategy, BacktestEngine)
    │
HTTP Response (schema serialization)
```

### Frontend Layer Responsibilities

| Layer | Location | Responsibility | Must NOT |
|-------|----------|----------------|----------|
| **presentation** | `lib/features/*/presentation/` | Render state; handle user events | Contain business logic |
| **domain** | `lib/domain/` | Entity definitions; UseCase contracts; Repository interfaces | Import HTTP, Provider |
| **data** | `lib/data/` | API calls; DTO ↔ Entity mapping | Contain UI logic |

### Frontend Data Flow

```
Widget (event)
    │
ViewModel (state management, calls UseCase only)
    │
UseCase (lib/domain/usecases/)
    │
Repository interface (lib/domain/repositories/)
    │
RepositoryImpl (lib/data/repositories/)
    │
RemoteDataSource (lib/data/datasources/)
    │
FastAPI /v2/* endpoint
```

---

## Tech Stack

### Backend
| Component | Technology |
|-----------|------------|
| Runtime | Python (uv) |
| API Framework | FastAPI |
| Database | PostgreSQL (SQLAlchemy) |
| Market Data | yfinance |
| ML | scikit-learn, XGBoost |
| Data Processing | pandas, NumPy |
| Scheduler | APScheduler |

### Frontend
| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| State Management | Provider |
| Architecture | MVVM (Clean Architecture) |
| HTTP | http package |
| Charts | candlesticks |

---

## Project Structure

```
Robo-Advisor/
├── Robo-back/                     # Python + FastAPI backend
│   └── src/
│       ├── api/
│       │   ├── routers/           # Clean Architecture endpoints (/v2/*)
│       │   ├── endpoints/         # [LEGACY] to be removed
│       │   └── schemas/           # Pydantic request/response models
│       ├── application/
│       │   └── usecases/          # One file = one use case
│       ├── domain/
│       │   ├── entities/          # Pure data classes (no ORM, no JSON)
│       │   ├── strategies/        # Stateless strategy implementations
│       │   │   └── ml_feature_spec.py  # Single source: FEATURE_COLS
│       │   ├── backtest/          # BacktestEngine, BacktestResult, TradeLog
│       │   └── repositories/      # Abstract interfaces only
│       └── infrastructure/
│           ├── external/          # yfinance, ML training, technical indicators
│           └── repositories/      # DB implementations of domain interfaces
│
└── robo_app/                      # Flutter frontend
    └── lib/
        ├── app/                   # App root, Provider setup
        ├── core/                  # Colors, theme, shared widgets, formatters
        ├── data/                  # API calls, DTO models, repository implementations
        ├── domain/                # Entities, UseCase contracts, Repository interfaces
        ├── features/              # Feature-first screens (dashboard, search, etc.)
        ├── models/                # [LEGACY] to be migrated to data/domain
        ├── services/              # [LEGACY] to be migrated
        ├── viewmodels/            # [LEGACY] to be migrated to features/*/presentation/
        ├── views/                 # [LEGACY] to be migrated
        └── widgets/               # [LEGACY] to be migrated
```

---

## Setup

### Prerequisites

- Python 3.11+, `uv` package manager
- Flutter 3.10+
- PostgreSQL 14+

### Backend

```bash
cd Robo-back

# Install dependencies
uv sync

# Configure environment
cp .env.example .env
# Edit .env: DATABASE_URL, SCHEDULER_TIMEZONE, LOG_LEVEL

# Initialize database
uv run python -c "from src.core.database import init_db; init_db()"

# Start server
uv run uvicorn src.main:app --reload
```

API documentation: `http://localhost:8000/docs`

> **Note:** The server currently registers both legacy (`/`) and clean (`/v2/`) endpoint prefixes.
> New development should target `/v2/` routes only. Legacy routes will be removed.

### Frontend

```bash
cd robo_app

# Install dependencies
flutter pub get

# Configure environment
echo "API_URL=http://localhost:8000" > .env

# Run app
flutter run
```

### Run ML Backtest

```bash
cd Robo-back
uv run python test_ml_backtest.py
```

---

## Implemented Features

### Backend
| Feature | Status | Notes |
|---------|--------|-------|
| Portfolio dashboard | ✅ | Live asset calculation |
| Stock price & history | ✅ | Via yfinance |
| Buy / Sell trades | ✅ | Commission: 0.1% |
| Watchlist CRUD | ✅ | DB-backed |
| Daily recommendation scheduler | ✅ | APScheduler cron |
| MA Cross strategy | ✅ | Domain layer |
| RSI strategy | ✅ | Domain layer |
| Momentum strategy | ✅ | Domain layer |
| ML strategy (Logistic / XGBoost) | ✅ | Probability threshold + cooldown |
| Backtest engine | ✅ | Look-ahead prevention, commission |
| Strategy comparison | ✅ | Return, MDD, Win Rate |
| Feature engineering (12 features) | ✅ | MACD, Bollinger, RSI, MA, etc. |

### Frontend
| Screen | Status | Notes |
|--------|--------|-------|
| Dashboard | ✅ | Dark theme, premium design |
| Recommendations | ✅ | |
| Stock Detail + Chart | ✅ | Candlestick chart |
| Search + Watchlist | ✅ | |
| Settings | ✅ | |
| Buy / Sell modal | ✅ | |

---

## Backtest Results (AAPL, 5yr, $1M initial)

| Strategy | Return | MDD | Win Rate | Trades |
|----------|--------|-----|----------|--------|
| Buy & Hold | +124.5% | 33.4% | 100% | 2 |
| ML (Logistic) | +73.3% | 34.4% | 60% | 21 |
| RSI | +46.7% | 30.2% | 100% | 11 |
| Momentum | +30.7% | 24.5% | 50% | 33 |
| ML (XGBoost) | +17.7% | 29.6% | 46% | 44 |
| MA Cross | +6.7% | 33.2% | 36% | 57 |

> ⚠️ Validated on AAPL only. Sharpe Ratio not yet computed. Walk-forward validation pending.

---

## How to Contribute

### Adding a New Trading Strategy

1. **Create strategy file** in `src/domain/strategies/`

```python
# src/domain/strategies/my_strategy.py
from src.domain.strategies.strategy import Strategy
from src.domain.entities.market_data import MarketData
from src.domain.entities.trade_signal import SignalType, TradeSignal

class MyStrategy(Strategy):
    @property
    def name(self) -> str:
        return "MyStrategy"

    def generate(self, data: list[MarketData]) -> list[TradeSignal]:
        # Pure logic only. No DB, no external API, no pandas import.
        ...
```

**Rules:**
- Stateless: same input always produces same output
- No external library imports in domain layer
- Function length ≤ 20 lines; one function = one responsibility

2. **Export from `__init__.py`**:

```python
# src/domain/strategies/__init__.py
from src.domain.strategies.my_strategy import MyStrategy
```

3. **Test it**:

```python
# tests/domain/test_my_strategy.py
def test_generates_buy_signal_on_uptrend():
    data = [make_market_data(close=i) for i in range(1, 30)]
    signals = MyStrategy().generate(data)
    assert any(s.signal == SignalType.BUY for s in signals)
```

4. **Add to backtest comparison** in `test_ml_backtest.py` or via API endpoint.

---

### Adding a New API Endpoint

1. **Define schema** in `src/api/schemas/`:

```python
# src/api/schemas/backtest_schemas.py
from pydantic import BaseModel

class BacktestRequest(BaseModel):
    ticker: str
    strategy: str

class BacktestResponse(BaseModel):
    total_return_pct: float
    mdd: float
    win_rate: float
    sharpe_ratio: float
    num_trades: int
```

2. **Create UseCase** in `src/application/usecases/`:

```python
# src/application/usecases/run_backtest_usecase.py
class RunBacktestUseCase:
    def __init__(self, market_data_provider): ...

    def execute(self, ticker: str, strategy_name: str) -> BacktestResult:
        # Orchestrate: fetch data → run strategy → return result
        ...
```

3. **Register in router** `src/api/routers/`:

```python
# src/api/routers/backtest_router.py
@router.post("/", response_model=BacktestResponse)
def run_backtest(request: BacktestRequest, usecase=Depends(get_backtest_usecase)):
    result = usecase.execute(request.ticker, request.strategy)
    return BacktestResponse(...)
```

4. **Register router** in `src/main.py`:

```python
app.include_router(backtest_router.router, prefix="/v2/backtest", tags=["v2 Backtest"])
```

**Rule:** Router contains zero business logic. It validates input schema and delegates to UseCase.

---

### Adding a New Flutter Screen

1. **Create feature folder**:

```
lib/features/backtest/presentation/
├── backtest_state.dart
├── backtest_view_model.dart
├── screens/
│   └── backtest_screen.dart
└── widgets/
    └── backtest_result_card.dart
```

2. **Define state** (immutable, copyWith):

```dart
class BacktestState {
  const BacktestState({this.status = ViewStatus.initial, this.result});
  final ViewStatus status;
  final BacktestResultEntity? result;
  BacktestState copyWith({ViewStatus? status, BacktestResultEntity? result}) => ...;
}
```

3. **ViewModel calls UseCase only**:

```dart
class BacktestViewModel extends ChangeNotifier {
  BacktestViewModel({required RunBacktestUseCase runBacktest})
      : _runBacktest = runBacktest;

  Future<void> runBacktest(String ticker, String strategy) async {
    _state = _state.copyWith(status: ViewStatus.loading);
    notifyListeners();
    final result = await _runBacktest.execute(ticker, strategy);
    _state = _state.copyWith(status: ViewStatus.success, result: result);
    notifyListeners();
  }
}
```

4. **Screen uses Selector** (never reads business logic directly):

```dart
Selector<BacktestViewModel, BacktestState>(
  selector: (_, vm) => vm.state,
  builder: (context, state, _) => switch (state.status) {
    ViewStatus.loading => const _LoadingView(),
    ViewStatus.success => BacktestResultCard(result: state.result!),
    _ => const _EmptyView(),
  },
)
```

5. **Register ViewModel** in `lib/app/app_providers.dart`.

---

## Key Architecture Rules

### Backend (non-negotiable)

```
✅ Router → UseCase → Repository/Domain
❌ Router → DB direct
❌ Router → business logic
❌ Domain → external library (pandas, sklearn, etc.)
❌ Domain → DB access
❌ UseCase → DB direct (must use Repository)
```

### Frontend (non-negotiable)

```
✅ Widget → ViewModel → UseCase → Repository
❌ ViewModel → Repository direct
❌ Widget → business logic
❌ Domain → HTTP / Provider
```

---

## Development Status

**Current Phase: Validation** (features implemented; reliability unverified)

| Area | Status |
|------|--------|
| Backend Clean Architecture | 85% — dual router system pending cleanup |
| Backtest Engine | ✅ Complete |
| ML Strategy Pipeline | ✅ Complete |
| Backtest Validation (walk-forward) | ❌ Not implemented |
| Multi-ticker Validation | ❌ AAPL only |
| Risk Metrics (Sharpe Ratio) | ❌ Not implemented |
| Backend Test Suite | ❌ No tests exist |
| Legacy Endpoint Removal | ❌ Pending |
| Backtest API Endpoint | ❌ Not exposed via API |
| Flutter Legacy Cleanup | 🔄 In progress |

---

## Known Issues

See [ANALYSIS.md](./Robo-back/ANALYSIS.md) for full technical analysis.

**Top blockers:**
1. No Sharpe Ratio — strategy comparison uses return/MDD only; risk-adjusted metrics missing
2. No walk-forward validation — ML model reliability unverified
3. Dual router system — legacy `/` and clean `/v2/` endpoints both active
4. `BuyAndHoldStrategy` in wrong layer — defined in `application/usecases/`, should be in `domain/strategies/`
5. No test suite — regressions undetectable
