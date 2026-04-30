import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/events/upcoming_events.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/client/models/home_dashboard_model.dart';
import 'package:smacredit/client/models/downloadlink.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/models/muic_search_result.dart';
import 'package:smacredit/client/models/music_dashboard_model.dart';
import 'package:smacredit/client/models/personal_playlist.dart';
import 'package:smacredit/client/models/search_result.dart';
import 'package:smacredit/client/models/viwers_model.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/models/transaction_history_model.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/content-creator/repository/repository.dart' as r;
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/payments/models/default_link.dart';
import 'package:smacredit/src/payments/repository/payments_repository.dart';

class ClientUserController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;

  bool loading = false;
  bool dataLoading = false;
  ClientDashboardModel? dashboardModel;
  ClientHomeDashboardModel? homeDashboard;
  LoadingStus loadingStus = LoadingStus.pending;
  Channel? channel;
  MusicDashboardResponse? musicDashboardResponse;
  TrendingMusicResponse? trendingData;
  MediaResponse? mediaResponse;
  GenreArtistResponse? genreArtistResponse;
  GenreAlbumResponse? genreAlbumResponse;
  ArtistSearchResponse? artistSearchResponse;
PlaylistSearchResponse? playlistSearchResponse;
  List<Playlist> playlists = [];

  ViewersModel? viewersModel;

MusicSearchResponse? musicSearchResponse;
  List<Video> videos = [];
  List<User> artists = [];
  List<User> creators = [];
  List<Category> categories = [];

  List<Channel> channels = [];

  List<TransactionHistoryModel> transactions = [];
  List<EventModel> events = [];
  List<Channel> subscribed_channels = [];
  List<Playlist> subscribed_playlists = [];
  Playlist? playlist;
  List<PersonalPlaylist> personal_playlists = [];
  List<Category> the_categories = [];
  List<User> trendingCreators = [];
  List<Video> likedVideos = [];

  DefaultLinkModel? defaultLinkModel;
  EventModel? eventModel;
  EventResponse? eventResponse;

  bool? isFollowingCreator;

  SearchResult? searchResult;

  List<Video> watchedVideos = [];
  Category? category;
  VideoStatsModel? videoStatsModel;
  EventDashboardResponse? eventDashboardResponse;
  ClientUserController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> listenForStreamViwers(String id) async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<ViewersModel?> stream = await get_viewers(id);
    stream.listen(
      (ViewersModel? notificationModel) {
        setState(() {
          viewersModel = notificationModel;
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
 Future<ArtistSearchResponse?> listenForArtists(
    {
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
      if (page == 1) {
        artists = [];
      }
    });

    ArtistSearchResponse? res = await all_music_artists(
      page: page,
      limit: limit,
    );
    setState(() {
      loading = false;
      artistSearchResponse = res;
        if (res != null && res.artists.isNotEmpty == true) {
        artists.addAll(res.artists);
      }
    });

    return res;
  }


  Future<ArtistSearchResponse?> searchMusicArtists(
    String search, {
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
      if (page == 1) {
        artists = [];
      }
    });

    ArtistSearchResponse? res = await search_music_artists(
      search,
      page: page,
      limit: limit,
    );
    setState(() {
      loading = false;
      artistSearchResponse = res;
        if (res != null && res.artists.isNotEmpty == true) {
        artists.addAll(res.artists);
      }
    });

    return res;
  }

  Future<MusicSearchResponse?> searchMusic(String search,{int?page=1,int?limit=10}) async {
    setState(() {
      loading = true;
       if (page == 1) {
        videos = [];
      }
    });
    MusicSearchResponse? res = await search_music(search,page: page,limit: limit);
    setState(() {
      loading = false;
      musicSearchResponse=res;
        if (res != null && res.tracks .isNotEmpty == true) {
        videos.addAll(res.tracks);
      }
    });

    return res;
  }

  Future<PlaylistSearchResponse?> searchMusicPlaylists(
    String search, {
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
      if (page == 1) {
        playlists = [];
      }
    });

    PlaylistSearchResponse? res = await search_music_playlist(search, page: page, limit: limit);
    setState(() {
      loading = false;
      playlistSearchResponse = res;
      if(res!=null&& res.playlists.isNotEmpty==true){
       playlists.addAll(res.playlists);
      }
    });

    return res;
  }

  Future<void> listenForTrendingMusic() async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<TrendingMusicResponse?> stream = await get_trending_music();
    stream.listen(
      (TrendingMusicResponse? notificationModel) {
        setState(() {
          trendingData = notificationModel;
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

  Future<void> listenForGenreAlbums(
    int id, {
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<GenreAlbumResponse?> stream = await get_genre_album_response(
      id,
      page: page,
      limit: limit,
    );
    stream.listen(
      (GenreAlbumResponse? notificationModel) {
        setState(() {
          genreAlbumResponse = notificationModel;
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

  Future<void> listenForGenreArtists(
    int id, {
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<GenreArtistResponse?> stream =
        await get_genre_artists_response(id, page: page, limit: limit);
    stream.listen(
      (GenreArtistResponse? notificationModel) {
        setState(() {
          genreArtistResponse = notificationModel;
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

  Future<void> listenForMusicDashboard() async {
    setState(() {
      loading = true;
      loadingStus = LoadingStus.loading;
    });
    final Stream<MusicDashboardResponse?> stream = await get_music_dashboard();
    stream.listen(
      (MusicDashboardResponse? notificationModel) {
        setState(() {
          musicDashboardResponse = notificationModel;
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
        getDefaultLink(channel?.userId ?? 0);
      },
    );
  }

  Future<void> listenForClientEvents(EventGroupType type) async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<EventModel?> stream = await get_the_client_events(type);
    stream.listen(
      (EventModel? notificationModel) {
        if (notificationModel != null) {
          events.add(notificationModel);
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

  Future<void> listenForPurchasedEvents() async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<EventModel?> stream = await get_purchased_events();
    stream.listen(
      (EventModel? notificationModel) {
        if (notificationModel != null) {
          events.add(notificationModel);
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

  Future<void> listenForEvent(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<EventModel?> stream = await get_event(id);

    stream.listen(
      (EventModel? employerModel) {
        setState(() {
          eventModel = employerModel;
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

  Future<void> listenForEventDashboad() async {
    setState(() {
      loading = true;
    });
    final Stream<EventDashboardResponse?> stream =
        await get_client_event_dashboard();

    stream.listen(
      (EventDashboardResponse? employerModel) {
        setState(() {
          eventDashboardResponse = employerModel;
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

  Future<void> listenForEvents({
    int? userId,
    int? page = 1,
    int? limit = 10,
  }) async {
    setState(() {
      loading = true;
    });
    events.clear();
    final Stream<EventResponse?> stream = await get_all_events(
      user_id: userId,
      page: page,
      limit: limit,
    );
    stream.listen(
      (EventResponse? notificationModel) {
        setState(() {
          eventResponse = notificationModel;
          events.addAll(notificationModel?.events ?? []);
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

  void getDefaultLink(int id) {
    setState(() {
      loading = true;
    });
    client_default_link(id).then((value) async {
      if (value != null) {
        setState(() {
          defaultLinkModel = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
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
        getDefaultLink(channel?.userId ?? 0);
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

  Future<void> listenForArtistVideos(int id) async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<Video?> stream = await get_artist_videos(id);
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

  Future<void> listenForPersonalPlaylistVideos(int id) async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<Video?> stream = await get_personal_playlists_videos(id);
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

  Future<void> listenForChannelVideos(int id) async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<Video?> stream = await get_channel_videos(id);
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

  Future<void> listenForTrendingCreators() async {
    setState(() {
      loading = true;
      videos.clear();
    });
    final Stream<User?> stream = await get_trending_creators();
    stream.listen(
      (User? notificationModel) {
        if (notificationModel != null) {
          trendingCreators.add(notificationModel);
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
    final Stream<TransactionHistoryModel?> stream =
        await get_client_transactions(1);
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

  Future<void> listenForCreatorPlaylists(int id) async {
    setState(() {
      loading = true;
      playlists.clear();
    });
    final Stream<Playlist?> stream = await get_creator_playlists(id);
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

  Future<void> listenForPersonalPlaylists(int id) async {
    setState(() {
      loading = true;
      personal_playlists.clear();
    });
    final Stream<PersonalPlaylist?> stream = await get_personal_playlists(id);
    stream.listen(
      (PersonalPlaylist? notificationModel) {
        if (notificationModel != null) {
          personal_playlists.add(notificationModel);
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

  Future<void> listenForFollowingChannels() async {
    setState(() {
      loading = true;
    });
    final Stream<Channel?> stream = await get_following_channels();
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

  Future<void> listenForVideoDashboard() async {
    final result = await get_video_dashboard();
    setState(() {
      homeDashboard = result;
    });
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

  Future<void> listenForPurchasedPlaylists() async {
    setState(() {
      loading = true;
    });
    final Stream<Playlist?> stream = await get_subscribed_playlists();
    stream.listen(
      (Playlist? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            subscribed_playlists.add(notificationModel);
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

  Future<void> listenForPurchasedChannels() async {
    setState(() {
      loading = true;
    });
    final Stream<Channel?> stream = await get_subscribed_channels();
    stream.listen(
      (Channel? notificationModel) {
        if (notificationModel != null) {
          setState(() {
            subscribed_channels.add(notificationModel);
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

  Future<void> listenForFollowingCreators() async {
    setState(() {
      loading = true;
    });
    final Stream<User?> stream = await get_all_creators(following: true);
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

  Future<bool?> logLead(Map map) async {
    // setState(() {
    //   loading = true;
    // });

    bool? res = await log_ad_lead(map);
    // setState(() {
    //   loading = false;
    // });

    return res;
  }

  Future<bool?> logClick(Map map) async {
    // setState(() {
    //   loading = true;
    // });

    bool? res = await log_ad_click(map);
    // setState(() {
    //   loading = false;
    // });

    return res;
  }

  Future<bool?> logAdImpression(Map map) async {
    bool? res = await log_ad_impression(map);
    return res;
  }

  Future<bool?> logAdView(Map map) async {
    // setState(() {
    //   loading = true;
    // });

    bool? res = await log_ad_view(map);
    // setState(() {
    //   loading = false;
    // });

    return res;
  }

  Future<VideoDownloadLink?> getDownloadLink(int id) async {
    setState(() {
      loading = true;
    });
    VideoDownloadLink? res = await get_download_link(id);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<String?> getPlaybackToken() async {
    return await get_playback_token();
  }

  Future<bool?> createPlaylist(Map map) async {
    setState(() {
      loading = true;
    });

    bool? res = await create_playlist(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<bool?> addToPlaylistPlaylist(Map map) async {
    setState(() {
      loading = true;
    });

    bool? res = await add_to_playlist(map);
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

  Future<PaymentResponseWrapper?> buyEvent(Map map) async {
    setState(() {
      loading = true;
    });

    PaymentResponseWrapper? res = await make_event_payment(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<bool?> serverHeartBeat(Map map) async {
    setState(() {
      loading = true;
    });
    bool? res = await server_heartbeat();
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<StreamWatchUnlockModel?> joinStream(Map map) async {
    setState(() {
      loading = true;
    });

    StreamWatchUnlockModel? res = await join_stream(map);
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

  Future<bool?> followCreator(Map map) async {
    setState(() {
      loading = true;
    });

    bool? res = await follow_creator(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<bool?> likeChannel(Map map, bool like) async {
    setState(() {
      loading = true;
    });

    bool? res = await like_channel(map, like);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<bool?> checkCreatorFollow(num id) async {
    setState(() {
      loading = true;
    });
    bool? res = await check_creator_follow(id);
    setState(() {
      loading = false;
      isFollowingCreator = res;
    });
    return res;
  }

  Future<bool?> unFollowCreator(Map map) async {
    setState(() {
      loading = true;
    });

    bool? res = await unfollow_creator(map);
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

  Future<bool?> reportVideo(Map map) async {
    setState(() {
      loading = true;
    });

    bool? res = await report_video(map);
    setState(() {
      loading = false;
    });

    return res;
  }
}

enum LoadingStus { loading, loaded, failed, pending }
