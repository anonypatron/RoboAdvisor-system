import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasources/remote/robo_remote_data_source.dart';
import '../data/repositories/market_repository_impl.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/watchlist_repository_impl.dart';
import '../domain/repositories/market_repository.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/watchlist_repository.dart';
import '../domain/usecases/buy_stock_usecase.dart';
import '../domain/usecases/fetch_recommendations_usecase.dart';
import '../domain/usecases/get_watchlist_usecase.dart';
import '../domain/usecases/load_dashboard_usecase.dart';
import '../domain/usecases/load_stock_detail_usecase.dart';
import '../domain/usecases/search_stocks_usecase.dart';
import '../domain/usecases/sell_stock_usecase.dart';
import '../domain/usecases/toggle_watchlist_usecase.dart';
import '../features/dashboard/presentation/dashboard_view_model.dart';
import '../features/recommendation/presentation/recommendation_view_model.dart';
import '../features/search/presentation/search_view_model.dart';
import '../features/settings/presentation/settings_view_model.dart';

class AppProviders {
  const AppProviders._();

  static List<SingleChildWidget> get items {
    return <SingleChildWidget>[
      // Infrastructure
      Provider<http.Client>(create: (_) => http.Client()),
      Provider<RoboRemoteDataSource>(
        create: (BuildContext context) =>
            RoboRemoteDataSource(client: context.read<http.Client>()),
      ),

      // Repositories
      Provider<PortfolioRepository>(
        create: (BuildContext context) => PortfolioRepositoryImpl(
          remoteDataSource: context.read<RoboRemoteDataSource>(),
        ),
      ),
      Provider<MarketRepository>(
        create: (BuildContext context) => MarketRepositoryImpl(
          remoteDataSource: context.read<RoboRemoteDataSource>(),
        ),
      ),
      Provider<WatchlistRepository>(
        create: (BuildContext context) => WatchlistRepositoryImpl(
          remoteDataSource: context.read<RoboRemoteDataSource>(),
        ),
      ),
      Provider<SettingsRepository>(
        create: (BuildContext context) => SettingsRepositoryImpl(
          remoteDataSource: context.read<RoboRemoteDataSource>(),
        ),
      ),

      // UseCases — portfolio
      Provider<LoadDashboardUseCase>(
        create: (BuildContext context) =>
            LoadDashboardUseCase(context.read<PortfolioRepository>()),
      ),
      Provider<BuyStockUseCase>(
        create: (BuildContext context) =>
            BuyStockUseCase(context.read<PortfolioRepository>()),
      ),
      Provider<SellStockUseCase>(
        create: (BuildContext context) =>
            SellStockUseCase(context.read<PortfolioRepository>()),
      ),

      // UseCases — market
      Provider<FetchRecommendationsUseCase>(
        create: (BuildContext context) =>
            FetchRecommendationsUseCase(context.read<MarketRepository>()),
      ),
      Provider<SearchStocksUseCase>(
        create: (BuildContext context) =>
            SearchStocksUseCase(context.read<MarketRepository>()),
      ),
      Provider<LoadStockDetailUseCase>(
        create: (BuildContext context) =>
            LoadStockDetailUseCase(context.read<MarketRepository>()),
      ),

      // UseCases — watchlist
      Provider<GetWatchlistUseCase>(
        create: (BuildContext context) =>
            GetWatchlistUseCase(context.read<WatchlistRepository>()),
      ),
      Provider<ToggleWatchlistUseCase>(
        create: (BuildContext context) =>
            ToggleWatchlistUseCase(context.read<WatchlistRepository>()),
      ),

      // ViewModels
      ChangeNotifierProvider<DashboardViewModel>(
        create: (BuildContext context) => DashboardViewModel(
          loadDashboard: context.read<LoadDashboardUseCase>(),
          buyStock: context.read<BuyStockUseCase>(),
          sellStock: context.read<SellStockUseCase>(),
        ),
      ),
      ChangeNotifierProvider<RecommendationViewModel>(
        create: (BuildContext context) => RecommendationViewModel(
          fetchRecommendations: context.read<FetchRecommendationsUseCase>(),
        ),
      ),
      ChangeNotifierProvider<SearchViewModel>(
        create: (BuildContext context) => SearchViewModel(
          getWatchlist: context.read<GetWatchlistUseCase>(),
          searchStocks: context.read<SearchStocksUseCase>(),
          toggleWatchlist: context.read<ToggleWatchlistUseCase>(),
        ),
      ),
      ChangeNotifierProvider<SettingsViewModel>(
        create: (BuildContext context) =>
            SettingsViewModel(repository: context.read<SettingsRepository>())
              ..load(),
      ),
    ];
  }
}
