class AppFormatters {
  const AppFormatters._();

  static String currency(double value) => '\$${value.toStringAsFixed(2)}';

  static String signedCurrency(double value) {
    final String prefix = value > 0 ? '+' : '';
    return '$prefix${currency(value)}';
  }

  static String signedPercent(double value) {
    final String prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  static String compactCurrency(double value) {
    final double abs = value.abs();
    if (abs >= 1000000) return '\$${(value / 1000000).toStringAsFixed(2)}M';
    if (abs >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
    return currency(value);
  }

  static String marketCap(double value) {
    if (value >= 1000000000000) {
      return '${(value / 1000000000000).toStringAsFixed(2)}T';
    }
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    return value.toStringAsFixed(0);
  }
}
