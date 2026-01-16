import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
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

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);
Future<Stream<Channel>> get_channels() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/channels';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';

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

Future<Stream<User>> get_creators() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creators/all';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';

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

Future<Stream<PaymentLinkModel>> get_creator_links(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator-payment-links/$id';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        PaymentLinkModel channel = PaymentLinkModel.fromJson(data);
        return channel;
      });
}

Future<Stream<CategoryModel>> get_categories() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/categories';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        print(data);
        CategoryModel channel = CategoryModel.fromJson(data);
        return channel;
      });
}

Future<Channel?> create_channel(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/create-channel';

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
      Channel userModel = Channel.fromJson(json.decode(response.body));

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

Future<Channel?> update_channel(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/update-channel';

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
      Channel userModel = Channel.fromJson(json.decode(response.body));

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

Future<Stream<Channel?>> get_channel(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/channel/$id';
  print(url);
  final client = new http.Client();
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
          Channel employerModel = Channel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Stream<Playlist?>> getPlayList(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/playlist/$id';
  print(url);
  final client = new http.Client();
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
          Playlist employerModel = Playlist.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Stream<VideoStatsModel?>> get_client_video_stats(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/stats/get/$id';
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
          VideoStatsModel employerModel = VideoStatsModel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Stream<VideoStatsModel?>> get_video_stats(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/video/stats/$id';
  print(url);
  final client = new http.Client();
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
          VideoStatsModel employerModel = VideoStatsModel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Video?> update_video_visibility(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/update-video-visibility';

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
        .timeout(Duration(seconds: 200));

    print(response.statusCode);
    if (response.statusCode == 200) {
      try {
        Video userModel = Video.fromJson(json.decode(response.body));

        return userModel;
      } catch (e, x) {
        print(e);
        print(x);

        return null;
      }
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e, a) {
    print("error");
    print(a);
    return null;
  }
}

Future<Video?> delete_video(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/delete-video';

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
        .timeout(Duration(seconds: 200));

    print(response.statusCode);
    if (response.statusCode == 200) {
      try {
        Video userModel = Video.fromJson(json.decode(response.body));

        return userModel;
      } catch (e, x) {
        print(e);
        print(x);

        return null;
      }
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e, a) {
    print("error");
    print(a);
    return null;
  }
}

Future<Video?> update_video(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/update-video';

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
        .timeout(Duration(seconds: 200));

    print(response.statusCode);
    if (response.statusCode == 200) {
      try {
        Video userModel = Video.fromJson(json.decode(response.body));

        return userModel;
      } catch (e, x) {
        print(e);
        print(x);

        return null;
      }
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e, a) {
    print("error");
    print(a);
    return null;
  }
}

Future<Video?> create_video(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/create-video';

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
        .timeout(Duration(seconds: 200));

    print(response.statusCode);
    if (response.statusCode == 200) {
      try {
        Video userModel = Video.fromJson(json.decode(response.body));

        return userModel;
      } catch (e, x) {
        print(e);
        print(x);

        return null;
      }
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e, a) {
    print("error");
    print(a);
    return null;
  }
}

Future<Playlist?> create_playlist(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/create-playlist';

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
      Playlist userModel = Playlist.fromJson(json.decode(response.body));

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

Future<Playlist?> update_playlist(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/creator/update-playlist';

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
      Playlist userModel = Playlist.fromJson(json.decode(response.body));

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

Future<UploadIdModel?> upload_channel_logo(File files, int id) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/creator/update-channel-logo",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Image',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);
    request.fields['id'] = id.toString();
    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);
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
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<UploadIdModel?> upload_playlist_thumb(File files, int id) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/creator/update-playlist-thumb",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Image',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);
    request.fields['id'] = id.toString();
    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);
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
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<UploadIdModel?> upload_channel_cover(File files, int id) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/creator/update-channel-cover",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Image',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);
    request.fields['id'] = id.toString();
    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);
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
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<UploadIdModel?> upload_image(File files) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/registration/selfie-upload",
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
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<UploadIdModel?> upload_video(
  File file, {
  required Function(double progress) onProgress,
}) async {
  try {
    final dio = Dio();

    final url =
        "${GlobalConfiguration().getValue('api_base_url')}/creator/upload-video";

    final extension = file.path.split('.').last;

    final formData = FormData.fromMap({
      'extension': extension,
      'uploads': jsonEncode([]),
      'Video': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer ${currentuser.value.token}'},
        sendTimeout: const Duration(minutes: 20),
      ),
      onSendProgress: (sent, total) {
        print("total_${total} sent_$sent");
        if (total > 0) {
          onProgress(sent / total); // 0.0 → 1.0
        }
      },
    );

    if (response.statusCode == 200) {
      return UploadIdModel.fromJson(response.data);
    }

    return null;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

Future<UploadIdModel?> upload_video2(File files) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/creator/upload-video",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Video',
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

    // http.StreamedResponse response = await request.send();

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60 * 20),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<Video?> upload_video_trailer(File files, int id) async {
  try {
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/creator/upload-video-trailer",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Video',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);
    request.fields['id'] = id.toString();
    request.fields['uploads'] = jsonEncode(files2);

    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);

    // http.StreamedResponse response = await request.send();

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60 * 20),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      Video uploadIdModel = Video.fromJson(jsonDecode(responseB.body));

      return uploadIdModel;

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
