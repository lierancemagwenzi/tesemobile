// --- PriceModel (Required Dependency) ---
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/home/models/earnings_stats_model.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';

class PriceModel {
  final double amount;
  final String currency;

  PriceModel({required this.amount, required this.currency});

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

// ------------------------------------------

class UserStatsModel {
  final double totalEarnings;

  final int? videos;
  final int? views;
  final int? channels;
  final int? playlists;

  List<Channel>? topChannels;
  List<Playlist>? topPlaylists;
  List<Video>? topVideos;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double todayEarnings;
  final List<PriceModel> balances;
  final int notificationCount;
  final List<double>
  earnings; // Assuming this is a historical earnings chart data
  final List<AmountStatsModel>? amountStats;

  final List<TransactionModel>? transactions;

  // NEW FIELD: List of unique currency strings
  final List<String>? uniqueCurrencies;
  UserStatsModel({
    required this.totalEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.todayEarnings,
    required this.balances,
    required this.notificationCount,
    required this.earnings,
    this.amountStats,
    this.uniqueCurrencies,
    this.transactions,
    this.videos,
    this.views,
    this.channels,
    this.playlists,
    this.topChannels,
    this.topPlaylists,
    this.topVideos,
  });

  // Factory constructor to create a UserStatsModel from a JSON Map
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    // Deserialize the 'balances' list using the PriceModel
    final balancesList = (json['balances'] as List<dynamic>)
        .map((item) => PriceModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // Deserialize the 'earnings' list (assuming it holds numbers/doubles)
    // final earningsList = (json['earnings'] as List<dynamic>)
    //     .map((item) => (item as num).toDouble())
    //     .toList();

    final List<AmountStatsModel>? parsedAmountStats =
        (json['amountStats'] as List<dynamic>?)
            ?.map(
              (item) => AmountStatsModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    final List<Channel>? topChannels = (json['top_channels'] as List<dynamic>?)
        ?.map((item) => Channel.fromJson(item as Map<String, dynamic>))
        .toList();

    final List<Playlist>? topPlaylists =
        (json['top_playlists'] as List<dynamic>?)
            ?.map((item) => Playlist.fromJson(item as Map<String, dynamic>))
            .toList();

    final List<Video>? topVideos = (json['top_videos'] as List<dynamic>?)
        ?.map((item) => Video.fromJson(item as Map<String, dynamic>))
        .toList();

    final List<TransactionModel>? transactions =
        (json['transactions'] as List<dynamic>?)
            ?.map(
              (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    // final List<TransactionModel> transactions = [];

    // VITAL: Safely parse the list of strings
    final List<String>? parsedUniqueCurrencies =
        (json['unique_currencies'] as List<dynamic>?)
            ?.map(
              (e) => e.toString(),
            ) // Ensure each item is treated as a String
            .toList();
    return UserStatsModel(
      // Use num.toDouble() to safely handle integers that should be doubles
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      weeklyEarnings: (json['weekly_earnings'] as num).toDouble(),
      monthlyEarnings: (json['monthly_earnings'] as num).toDouble(),
      todayEarnings: (json['today_earnings'] as num).toDouble(),
      amountStats: parsedAmountStats,
      uniqueCurrencies: parsedUniqueCurrencies,
      topPlaylists: topPlaylists,
      topChannels: topChannels,
      topVideos: topVideos,
      balances: balancesList,
      notificationCount: json['notification_count'] as int,
      earnings: [],
      transactions: transactions,
      videos: (json['video_count'] as num).toInt(),
      channels: (json['total_channels'] as num).toInt(),
      playlists: (json['total_playlists'] as num).toInt(),
      views: (json['total_views'] as num).toInt(),
    );
  }
}
