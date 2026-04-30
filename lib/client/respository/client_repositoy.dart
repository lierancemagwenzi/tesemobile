import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/client/events/upcoming_events.dart';
import 'package:smacredit/client/models/cookie_model.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/client/models/home_dashboard_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart' hide Category;
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
import 'package:smacredit/client/models/downloadlink.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/models/muic_search_result.dart';
import 'package:smacredit/client/models/music_dashboard_model.dart';
import 'package:smacredit/client/models/personal_playlist.dart';
import 'package:smacredit/client/models/search_result.dart';
import 'package:smacredit/client/models/viwers_model.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/models/transaction_history_model.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/helpers/Helper.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

GlobalKey _betterPlayerKey = GlobalKey();
Future<Stream<Channel?>> get_client_channel(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/channel/get/$id';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          Channel employerModel = Channel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

// ignore: non_constant_identifier_names
Future<Stream<MusicDashboardResponse?>> get_music_dashboard() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/music-dashboard';
  if (kDebugMode) {
    print(url);
  }
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        if (kDebugMode) {
          print(data);
        }

        try {
          MusicDashboardResponse employerModel =
              MusicDashboardResponse.fromJson(data);
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<TrendingMusicResponse?>> get_trending_music() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/trending-music';
  if (kDebugMode) {
    print(url);
  }
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        if (kDebugMode) {
          print(data);
        }

        try {
          TrendingMusicResponse employerModel = TrendingMusicResponse.fromJson(
            data,
          );
          print("employerModel${employerModel}");
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<GenreArtistResponse?>> get_genre_artists_response(
  int id, {
  int? page = 1,
  int? limit = 10,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/category-artists/$id?page=$page&limit=$limit';
  if (kDebugMode) {
    print(url);
  }
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        if (kDebugMode) {
          print(data);
        }

        try {
          GenreArtistResponse employerModel = GenreArtistResponse.fromJson(
            data,
          );
          print("employerModel${employerModel}");
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<GenreAlbumResponse?>> get_genre_album_response(
  int id, {
  int? page = 1,
  int? limit = 10,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/category-playlists/$id?page=$page&limit=$limit';
  if (kDebugMode) {
    print(url);
  }
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        if (kDebugMode) {
          print(data);
        }

        try {
          GenreAlbumResponse employerModel = GenreAlbumResponse.fromJson(data);
          print("employerModel${employerModel}");
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<Playlist?>> get_client_playlist(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/playlist/get/$id';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          Playlist employerModel = Playlist.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<ClientHomeDashboardModel?> get_video_dashboard() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/video-dashboard';
  try {
    final client = http.Client();
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            if (currentuser.value.token != null)
              HttpHeaders.authorizationHeader:
                  'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return ClientHomeDashboardModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (kDebugMode) {
      print('video-dashboard: ${response.statusCode} ${response.body}');
    }
    return null;
  } catch (e) {
    if (kDebugMode) print('get_video_dashboard error: $e');
    return null;
  }
}

Future<Stream<ClientDashboardModel?>> get_client_dashboard() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client-dashboard';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          ClientDashboardModel employerModel = ClientDashboardModel.fromJson(
            data,
          );
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Stream<MediaResponse?>> get_video(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/client/get/$id';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['x-platform'] = 'mobile';
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          MediaResponse employerModel = MediaResponse.fromJson(data);
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<Video>> get_playlist_videos(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/playlist-videos/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }
  request.headers['x-platform'] = 'mobile';

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_artist_videos(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/artist-videos/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_personal_playlists_videos(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/personal-playlists-videos/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['x-platform'] = 'mobile';
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_channel_videos(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/channel-videos/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<TransactionHistoryModel>> get_client_transactions(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/transactions';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        TransactionHistoryModel channel = TransactionHistoryModel.fromJson(
          data,
        );
        return channel;
      });
}

Future<Stream<Playlist>> get_channel_playlists(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/channel-playlists/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Playlist channel = Playlist.fromJson(data);
        return channel;
      });
}

Future<Stream<PersonalPlaylist>> get_personal_playlists(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/personal-playlists';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        PersonalPlaylist channel = PersonalPlaylist.fromJson(data);
        return channel;
      });
}

Future<Stream<Playlist>> get_creator_playlists(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator-playlists/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Playlist channel = Playlist.fromJson(data);
        return channel;
      });
}

Future<Stream<Category>> get_categories() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/categories/get/all';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Category channel = Category.fromJson(data);
        return channel;
      });
}

Future<Stream<Category>> get__dashboard_categories() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/dashboard-categories';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Category channel = Category.fromJson(data);
        return channel;
      });
}

Future<Stream<User>> get_creators() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creators/get/all';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        User channel = User.fromJson(data);
        return channel;
      });
}

Future<Stream<User>> get_category_creators(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/category/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        User channel = User.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_purchased_videos() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/purchased-videos';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_liked_videos() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/liked-videos';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_watched_videos() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/watched-videos';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Video>> get_dashboard_videos() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/dashboard-videos-all';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Video channel = Video.fromJson(data);
        return channel;
      });
}

Future<Stream<Playlist>> get_subscribed_playlists() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/subscribed-playlists';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Playlist channel = Playlist.fromJson(data);
        return channel;
      });
}

Future<Stream<Channel>> get_subscribed_channels() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/subscribed-channels';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Channel channel = Channel.fromJson(data);
        return channel;
      });
}

Future<Stream<User>> get_all_creators({bool following = false}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creators/get/all';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request(
    'get',
    Uri.parse(
      following
          ? '${GlobalConfiguration().getValue('api_base_url')}/client/creator-following'
          : url,
    ),
  );

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        User channel = User.fromJson(data);
        return channel;
      });
}

Future<Stream<User>> get_trending_creators() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/trending-creators';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        User channel = User.fromJson(data);
        return channel;
      });
}

Future<Stream<Channel>> get_creator_channels(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator-channels/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Channel channel = Channel.fromJson(data);
        return channel;
      });
}

Future<Stream<Channel>> get_category_channels(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/category-channels/get/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Channel channel = Channel.fromJson(data);
        return channel;
      });
}

// ignore: non_constant_identifier_names
Future<Stream<Channel>> get_following_channels() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/liked-channels';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        Channel channel = Channel.fromJson(data);
        return channel;
      });
}

Future<Stream<EventResponse?>> get_all_events({
  int? user_id,
  int? page = 1,
  int? limit = 10,
}) async {
  String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/coming-events?page=$page&limit=$limit';
  if (user_id != null) {
    url =
        '${GlobalConfiguration().getValue('api_base_url')}/client/coming-events?page=$page&limit=$limit&user_id=$user_id';
  }

  final client = http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          EventResponse employerModel = EventResponse.fromJson(data);
          return employerModel;
        } catch (e, s) {
          return null;
        }
      });
}

Future<Stream<EventModel?>> get_event(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/event/$id';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          EventModel employerModel = EventModel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<ViewersModel?>> get_viewers(String id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/stream-viewers/$id';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          ViewersModel employerModel = ViewersModel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<EventDashboardResponse?>> get_client_event_dashboard() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/event-dashboard';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          EventDashboardResponse employerModel =
              EventDashboardResponse.fromJson(data);
          return employerModel;
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
          }
          if (kDebugMode) {
            print(s);
          }

          return null;
        }
      });
}

Future<Stream<EventModel>> get_the_client_events(EventGroupType type) async {
  final String url = type == EventGroupType.upcoming
      ? '${GlobalConfiguration().getValue('api_base_url')}/client/my-coming-events'
      : type == EventGroupType.live
      ? '${GlobalConfiguration().getValue('api_base_url')}/client/live-events'
      : '${GlobalConfiguration().getValue('api_base_url')}/client/past-events';

  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        EventModel channel = EventModel.fromJson(data);
        return channel;
      });
}

Future<Stream<EventModel>> get_purchased_events() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/purchased-events';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  if (currentuser.value.token != null) {
    request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  }

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        EventModel channel = EventModel.fromJson(data);
        return channel;
      });
}

Future<VideoStatsModel?> log_video_view(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/view-video';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          body: jsonEncode({'video_id': id}),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      VideoStatsModel userModel = VideoStatsModel.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> log_ad_impression(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/ad-impression';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          body: jsonEncode(map),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> log_ad_view(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/ad-watch';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          body: jsonEncode(map),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> log_ad_lead(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/ad-lead';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          body: jsonEncode(map),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> log_ad_click(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/ad-click';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          body: jsonEncode(map),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> report_video(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/report';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<VideoDownloadLink?> get_download_link(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/download-link/$id';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return VideoDownloadLink.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<String?> get_playback_token() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/playback-token';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] as String?;
    }
    return null;
  } on TimeoutException {
    return null;
  } on SocketException {
    return null;
  } catch (e) {
    return null;
  }
}

Future<VideoStatsModel?> log_video_like(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/video-like';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode({'video_id': id}),
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      VideoStatsModel userModel = VideoStatsModel.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<MediaResponse?> get_media(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/client/get/$id';

  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: currentuser.value.user != null
              ? {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  HttpHeaders.authorizationHeader:
                      'Bearer ${currentuser.value.token}',
                  'x-platform': 'mobile',
                }
              : {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  'x-platform': 'mobile',
                },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      MediaResponse userModel = MediaResponse.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<CloudFrontCookies> fetchSignedCookies() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/media/cookie';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      "access-token":
          "atBWa8doBCBAJejPkDE7cAV5J6GKzChtgsS3TARzdmkSS3ZhjteOMvsLOyYWewkE",
    },
  );
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final cookies = CloudFrontCookies.fromJson(jsonData);

    // Update the app-wide cookie
    cloudFrontCookieNotifier.setCookie(cookies);

    return cookies;
  } else {
    throw Exception('Failed to fetch CloudFront cookies');
  }
}

Future<bool?> server_heartbeat() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/app/stream/heartbeat';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: currentuser.value.token != null
              ? {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  HttpHeaders.authorizationHeader:
                      'Bearer ${currentuser.value.token}',
                }
              : {HttpHeaders.contentTypeHeader: 'application/json'},
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<SearchResult?> client_search(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/search';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: currentuser.value.token != null
              ? {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  HttpHeaders.authorizationHeader:
                      'Bearer ${currentuser.value.token}',
                }
              : {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      SearchResult userModel = SearchResult.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> create_playlist(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/create-playlist';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> add_to_playlist(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/add-to-playlist';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<PaymentResponseWrapper?> make_video_payment(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/buy-video';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      PaymentResponseWrapper userModel = PaymentResponseWrapper.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<PaymentResponseWrapper?> make_event_payment(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/buy-event';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      PaymentResponseWrapper userModel = PaymentResponseWrapper.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<StreamWatchUnlockModel?> join_stream(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/play-event';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      StreamWatchUnlockModel userModel = StreamWatchUnlockModel.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> like_channel(Map map, bool like) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/follow-channel';

  try {
    final response = await client
        .post(
          Uri.parse(
            like
                ? url
                : '${GlobalConfiguration().getValue('api_base_url')}/client/unlike-channel',
          ),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> unfollow_creator(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/unfollow-creator';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> check_creator_follow(num id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/check-creator-follow/$id';

  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<bool?> follow_creator(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/follow-creator';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<PaymentResponseWrapper?> make_channel_payment(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/buy-channel';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      PaymentResponseWrapper userModel = PaymentResponseWrapper.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<PaymentResponseWrapper?> make_playlist_payment(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/buy-playlist';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      PaymentResponseWrapper userModel = PaymentResponseWrapper.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<User?> upload_profile(File files, bool isProfile) async {
  try {
    var postUri = Uri.parse(
      isProfile
          ? "${GlobalConfiguration().getValue('api_base_url')}/auth/update-profile-picture"
          : "${GlobalConfiguration().getValue('api_base_url')}/auth/update-profile-banner",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'selfieImage',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);

    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);

    // http.StreamedResponse response =

    // http.StreamedResponse response = await request.send();

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      User uploadIdModel = User.fromJson(jsonDecode(responseB.body));

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<MusicSearchResponse?> search_music(
  String search, {
  int? page = 1,
  int? limit = 20,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/search-music?page=$page&limit=$limit';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode({"search": search}),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      MusicSearchResponse userModel = MusicSearchResponse.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<ArtistSearchResponse?> all_music_artists({
  int? page = 1,
  int? limit = 20,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/all-music-artists?page=$page&limit=$limit';

  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      ArtistSearchResponse userModel = ArtistSearchResponse.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<ArtistSearchResponse?> search_music_artists(
  String search, {
  int? page = 1,
  int? limit = 20,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/search-music-artists?page=$page&limit=$limit';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode({"search": search}),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      ArtistSearchResponse userModel = ArtistSearchResponse.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<PlaylistSearchResponse?> search_music_playlist(
  String search, {
  int? page = 1,
  int? limit = 20,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/client/search-music-playlists?page=$page&limit=$limit';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode({"search": search}),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      PlaylistSearchResponse userModel = PlaylistSearchResponse.fromJson(
        json.decode(response.body),
      );

      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}
