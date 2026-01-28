import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart' hide Category;
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/models/search_result.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/helpers/Helper.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

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

Future<Stream<User>> get_all_creators() async {
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
                }
              : {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  // HttpHeaders.authorizationHeader:
                  //     'Bearer ${currentuser.value.token}',
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
