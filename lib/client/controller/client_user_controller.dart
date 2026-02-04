import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/models/search_result.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/models/transaction_history_model.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/content-creator/repository/repository.dart' as r;
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';

class ClientUserController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;

  bool loading = false;
  bool dataLoading = false;
  ClientDashboardModel? dashboardModel;
  LoadingStus loadingStus = LoadingStus.pending;
  Channel? channel;
  MediaResponse? mediaResponse;
  List<User> creators = [];
  List<Category> categories = [];
  List<Playlist> playlists = [];
  List<Channel> channels = [];
  List<Video> videos = [];
List<TransactionHistoryModel> transactions = [];
  Playlist? playlist;

  List<Category> the_categories = [];

  List<Video> likedVideos = [];

  SearchResult? searchResult;

  List<Video> watchedVideos = [];
  Category? category;
  VideoStatsModel? videoStatsModel;
  ClientUserController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> listenForDashboard() async {
    setState(() {
      loading = true;
    });
    final Stream<ClientDashboardModel?> stream = await get_client_dashboard();
    stream.listen(
      (ClientDashboardModel? notificationModel) {
        setState(() {
          dashboardModel = notificationModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForVideoStats(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<VideoStatsModel?> stream = await r.get_client_video_stats(id);

    stream.listen(
      (VideoStatsModel? employerModel) {
        setState(() {
          videoStatsModel = employerModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForChannel(int id) async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<Channel?> stream = await get_client_channel(id);
    stream.listen(
      (Channel? notificationModel) {
        setState(() {
          channel = notificationModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
          loadingStus = LoadingStus.failed;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
          loadingStus = LoadingStus.loaded;
        });
      },
    );
  }


    Future<void> listenForPlaylist(int id) async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<Playlist?> stream = await get_client_playlist(id);
    stream.listen(
      (Playlist? notificationModel) {
        setState(() {
          playlist = notificationModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
          loadingStus = LoadingStus.failed;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
          loadingStus = LoadingStus.loaded;
        });
      },
    );
  }

  Future<void> listenForPlaylistVideos(int id) async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<Video?> stream = await get_playlist_videos(id);
    stream.listen(
      (Video? notificationModel) {
        if (notificationModel != null) {
          videos.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

    Future<void> listenForTransactions() async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<TransactionHistoryModel?> stream = await get_client_transactions(1);
    stream.listen(
      (TransactionHistoryModel? notificationModel) {
        if (notificationModel != null) {
          transactions.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForChannelPlaylists(int id) async {
    setState(() {
      loading = true;
      playlists.clear();
    });
    final Stream<Playlist?> stream = await get_channel_playlists(id);
    stream.listen(
      (Playlist? notificationModel) {
        if (notificationModel != null) {
          playlists.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForCategoryChannels(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<Channel?> stream = await get_category_channels(id);
    stream.listen(
      (Channel? notificationModel) {
        if (notificationModel != null) {
          channels.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForCreatorChannels(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<Channel?> stream = await get_creator_channels(id);
    stream.listen(
      (Channel? notificationModel) {
        if (notificationModel != null) {
          channels.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForCategory(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<User?> stream = await get_category_creators(id);
    stream.listen(
      (User? notificationModel) {
        if (notificationModel != null) {
          creators.add(notificationModel);
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForCategories() async {
    setState(() {
      loading = true;
    });
    final Stream<Category?> stream = await get_categories();
    stream.listen(
      (Category? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            categories.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForDashboardCategories() async {
    setState(() {
      loading = true;
      the_categories = [];
    });
    final Stream<Category?> stream = await get__dashboard_categories();
    stream.listen(
      (Category? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            the_categories.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForDashboardVideos() async {
    setState(() {
      loading = true;
    });
    final Stream<Video?> stream = await get_dashboard_videos();
    stream.listen(
      (Video? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            videos.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForPurchasedVideos() async {
    setState(() {
      loading = true;
    });
    final Stream<Video?> stream = await get_purchased_videos();
    stream.listen(
      (Video? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            videos.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForLikedVideos() async {
    setState(() {
      loading = true;
      likedVideos.clear();
    });
    final Stream<Video?> stream = await get_liked_videos();
    stream.listen(
      (Video? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            likedVideos.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForWatchedVideos() async {
    setState(() {
      loading = true;
      watchedVideos.clear();
    });
    final Stream<Video?> stream = await get_watched_videos();
    stream.listen(
      (Video? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            watchedVideos.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForCreators() async {
    setState(() {
      loading = true;
    });
    final Stream<User?> stream = await get_all_creators();
    stream.listen(
      (User? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            creators.add(notificationModel);
          });
        }
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<MediaResponse?> getMedia(int id) async {
    setState(() {
      loading = true;
    });

    MediaResponse? res = await get_media(id);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<VideoStatsModel?> logLike(int id) async {
    setState(() {
      loading = true;
    });

    VideoStatsModel? res = await log_video_like(id);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<VideoStatsModel?> logView(int id) async {
    setState(() {
      loading = true;
    });

    VideoStatsModel? res = await log_video_view(id);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<PaymentResponseWrapper?> buyVideo(Map map) async {
    setState(() {
      loading = true;
    });

    PaymentResponseWrapper? res = await make_video_payment(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<SearchResult?> search(Map map) async {
    setState(() {
      loading = true;
    });

    SearchResult? res = await client_search(map);
    setState(() {
      loading = false;
      searchResult = res;
    });

    return res;
  }

  Future<PaymentResponseWrapper?> buyChannel(Map map) async {
    setState(() {
      loading = true;
    });

    PaymentResponseWrapper? res = await make_channel_payment(map);
    setState(() {
      loading = false;
    });

    return res;
  }

    Future<PaymentResponseWrapper?> buyPlaylist(Map map) async {
    setState(() {
      loading = true;
    });

    PaymentResponseWrapper? res = await make_playlist_payment(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  
}

enum LoadingStus { loading, loaded, failed, pending }
