import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/content_rating.dart';
import 'package:smacredit/src/content-creator/models/tag_model.dart';
import 'package:smacredit/src/content-creator/models/upload_response.dart';
import 'package:smacredit/src/content-creator/models/video_review_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/content-creator/repository/repository.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:background_transfer/background_transfer.dart';
import 'package:path/path.dart' as p; // Add path package to pubspec.yaml
import 'package:smacredit/client/models/dashboard_model.dart' as dash;

class CreatorController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  double uploadProgress = 0;
  final transfer = getBackgroundTransfer();

  List<Channel> channels = [];
  List<VideoReviewModel> reports = [];
  Channel? channel;
  bool loading = false;
  UploadIdModel? coverImage;
  UploadIdModel? profileImage;
  UploadIdModel? playlistThumb;
  Playlist? playlist;
  UploadIdModel? videoThumb;
  EventModel? eventModel;
  bool uploadingVideo = false;
  List<dash.Category> musicCategories = [];
  File? updatedCover;
  VideoStatsModel? videoStatsModel;
  List<CategoryModel> categories = [];
  List<ContentRating> contentRatings = [];
  List<TagModel> tags = [];
  UploadIdModel? video;
  bool success = false;
  Channel? channelModel;
  EventResponse? eventResponse;

  List<EventModel> events = [];
  CreatorController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }
  Future<void> listenForMusicCategories() async {
    setState(() {
      loading = true;
    });

    final Stream<dash.Category?> stream = await get_all_music_categories();
    stream.listen(
      (dash.Category? notificationModel) {
        setState(() {
          musicCategories.add(notificationModel!);
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

  Future<void> listenForTags() async {
    setState(() {
      loading = true;
    });

    final Stream<TagModel?> stream = await get_tags();
    stream.listen(
      (TagModel? notificationModel) {
        setState(() {
          tags.add(notificationModel!);
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

  Future<void> listenForContentRatings() async {
    setState(() {
      loading = true;
    });

    final Stream<ContentRating?> stream = await get_all_content_rating();
    stream.listen(
      (ContentRating? notificationModel) {
        setState(() {
          contentRatings.add(notificationModel!);
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
    int? page = 1,
    int limit = 10,
    bool? restart = false,
  }) async {
    setState(() {
      loading = true;
    });
    if (restart == true) {
      events.clear();
    }
    final Stream<EventResponse?> stream = await get_creator_events(
      limit: limit,
      page: page,
    );
    stream.listen(
      (EventResponse? notificationModel) {
        eventResponse = notificationModel;
        (notificationModel?.events ?? []).forEach((element) {
          setState(() {
            events.add(element);
          });
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

  Future<void> listenForUpcomingEvents({int? page = 1, int limit = 10}) async {
    setState(() {
      loading = true;
    });
    final Stream<EventResponse?> stream = await get_creator_upcoming_events(
      limit: limit,
      page: page,
    );
    stream.listen(
      (EventResponse? notificationModel) {
        eventResponse = notificationModel;
        (notificationModel?.events ?? []).forEach((element) {
          setState(() {
            events.add(element);
          });
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

  Future<void> listenForCreatorEvents({
    int? user_id,
    int? page = 1,
    int limit = 10,
  }) async {
    setState(() {
      loading = true;
      events.clear();
    });
    final Stream<EventResponse?> stream = await get_all_events(
      limit: limit,
      page: page,
      user_id: user_id,
    );
    stream.listen(
      (EventResponse? notificationModel) {
        eventResponse = notificationModel;
        (notificationModel?.events ?? []).forEach((element) {
          setState(() {
            events.add(element);
          });
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

  Future<void> listenForPastEvents({int? page = 1, int limit = 10}) async {
    setState(() {
      loading = true;
    });
    final Stream<EventResponse?> stream = await get_creator_past_events(
      limit: limit,
      page: page,
    );
    stream.listen(
      (EventResponse? notificationModel) {
        eventResponse = notificationModel;
        (notificationModel?.events ?? []).forEach((element) {
          setState(() {
            events.add(element);
          });
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

  Future<void> listenForChannels() async {
    setState(() {
      loading = true;
    });
    channels.clear();
    final Stream<Channel> stream = await get_channels();
    stream.listen(
      (Channel notificationModel) {
        setState(() => channels.add(notificationModel));
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

  Future<void> listenForReports(int id) async {
    setState(() {
      loading = true;
    });
    reports.clear();
    final Stream<VideoReviewModel> stream = await get_video_reviews(id);
    stream.listen(
      (VideoReviewModel notificationModel) {
        setState(() => reports.add(notificationModel));
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

  Future<void> listenForCategoies() async {
    setState(() {
      loading = true;
    });
    channels.clear();
    final Stream<CategoryModel> stream = await get_categories();
    stream.listen(
      (CategoryModel notificationModel) {
        setState(() => categories.add(notificationModel));
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

  Future<void> refreshNotifications() async {
    channels.clear();
    listenForChannels();
  }

  Future<void> uploadCover(File file) async {
    setState(() {
      loading = true;
    });
    upload_image(file).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          coverImage = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<Channel?> updateChannel(Map map) async {
    setState(() {
      loading = true;
    });

    Channel? channel = await update_channel(map);
    setState(() {
      loading = false;
    });

    return channel;
  }

  Future<Channel?> createChannel(Map map) async {
    setState(() {
      loading = true;
    });

    Channel? channel = await create_channel(map);
    setState(() {
      loading = false;
    });

    return channel;
  }

  Future<Playlist?> createPlaylist(Map map) async {
    setState(() {
      loading = true;
    });

    Playlist? playlist = await create_playlist(map);
    setState(() {
      loading = false;
    });

    return playlist;
  }

  Future<Playlist?> updatePlaylist(Map map) async {
    setState(() {
      loading = true;
    });

    Playlist? playlist = await update_playlist(map);
    setState(() {
      loading = false;
    });

    return playlist;
  }

  Future<Video?> updateVideo(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await update_video(map);

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }
    return null;
  }

  Future<bool?> serverHeartBeat() async {
    setState(() {
      loading = true;
    });
    bool? res = await server_heartbeat();
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<StreamWatchUnlockModel?> startStream(Map map) async {
    setState(() {
      loading = true;
    });

    StreamWatchUnlockModel? res = await start_stream(map);
    setState(() {
      loading = false;
    });

    return res;
  }

  Future<EventModel?> createLiveStream(File file, Map map) async {
    setState(() {
      loading = true;
    });

    try {
      EventModel? playlist = await create_live_stream(file, map);
      setState(() {
        loading = false;
      });
      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }
    return null;
  }

  Future<Video?> deleteVideo(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await delete_video(map);

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }
    return null;
  }

  Future<Video?> updateVideoVisibility(Map map) async {
    setState(() {
      loading = true;
    });
    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await update_video_visibility(map);
      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<Video?> createVideo(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await create_video(map);

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<S3UploadResponse?> generateTrailerUploadLink(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      S3UploadResponse? playlist = await generatetrailerpploadlink(map);
      setState(() {
        loading = false;
      });
      if (playlist != null) {
        // transferFile(playlist, file);
        // uploadVideoToS3(playlist, file);
        // 4. Tell the user it's started!
      }
      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<Video?> saveVideoTrailer(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await savevideotrailer(map);

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<S3UploadResponse?> createVideoWithoutFile(Map map, File file) async {
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      S3UploadResponse? playlist = await create_video_without_file(map);

      if (playlist != null) {
        // transferFile(playlist, file);
        uploadVideoToS3(
          playlist,
          file,
          contentType: map['is_audio'] == true ? 'audio' : 'Video',
        );
        // 4. Tell the user it's started!
      }

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<void> uploadVideoToS3(
    S3UploadResponse s3Data,
    File file, {
    String contentType = 'Video',
  }) async {
    print(s3Data.uploadUrl);
    final (baseDirectory, directory, filename) = await Task.split(
      filePath: file.path,
    );
    try {
      String directoryPath = p.dirname(
        file.path,
      ); // "/data/user/0/com.tese.africa/cache"
      String originalFileName = p.basename(file.path);
      final task = UploadTask(
        url: s3Data.uploadUrl,
        filename: filename,
        displayName: s3Data.title,
        metaData: s3Data.videoId.toString(),
        options: TaskOptions(),
        baseDirectory:
            baseDirectory, // Tells the plugin to use the absolute path
        directory: directory,
        httpRequestMethod: 'PUT', // <--- Built-in PUT support!
        headers: {
          'Content-Type': '${contentType}/${file.path.split(".").last}',
        },
        retries: 3,
        post: 'binary',
        updates: Updates.statusAndProgress, // Keeps your UI/DB updated
      );

      // Start the upload
      bool res = await FileDownloader().enqueue(task);

      if (res) {
        if (kDebugMode) {
          print(task.toJson());
        }
      } else {
        if (kDebugMode) {
          print("failed to enque");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<UploadTask?> uploadTrailerVideoToS3(
    S3UploadResponse s3Data,
    File file,
    String taskId,
  ) async {
    print(s3Data.uploadUrl);
    final (baseDirectory, directory, filename) = await Task.split(
      filePath: file.path,
    );
    try {
      final task = UploadTask(
        url: s3Data.uploadUrl,
        taskId: taskId,
        filename: filename,
        displayName: 'Trailer-' + s3Data.title,
        metaData: s3Data.videoId.toString(),
        options: TaskOptions(),
        baseDirectory: baseDirectory,
        directory: directory,
        httpRequestMethod: 'PUT', // <--- Built-in PUT support!
        headers: {'Content-Type': 'video/${file.path.split(".").last}'},
        retries: 3,
        post: 'binary',
        updates: Updates.statusAndProgress, // Keeps your UI/DB updated
      );

      // Start the upload
      bool res = await FileDownloader().enqueue(task);

      if (res) {
        if (kDebugMode) {
          print(task.toJson());
        }

        return task;
      } else {
        if (kDebugMode) {
          print("failed to enque");
        }

        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return null;
      }
    }
  }

  transferFile(Video video, File file) async {
    final String url =
        '${GlobalConfiguration().getValue('api_base_url')}/creator/add-video';
    try {
      final taskId = await transfer.startUpload(
        filePath: file.path,
        uploadUrl: url,

        headers: {'Authorization': 'Bearer ${currentuser.value.token}'},
        fields: {
          'video_id': video.id.toString(),
          'extension': file.path.split('.').last.toLowerCase(),
        },
      );

      ScaffoldMessenger.of(
        scaffoldKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Upload started in background!")));

      await DownloadDB.saveUploadTask(
        video.id,
        taskId,
        video.title ?? "Video title",
        file.path.split('/').last,
      );

      // Listen to upload progress
      transfer
          .getUploadProgress(taskId)
          .listen(
            (progress) {
              if (kDebugMode) {
                print(
                  'Upload progress: ${(progress * 100).toStringAsFixed(1)}%',
                );
              }
            },
            onDone: () {
              if (kDebugMode) {
                print('Upload completed!');
              }
            },
            onError: (error) {
              if (kDebugMode) {
                print('Upload failed: $error');
              }
            },
          );
    } catch (e) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Failed to initialise file upload")),
      );
      if (kDebugMode) {
        print('Failed to start upload: $e');
      }
    }
  }

  Future<void> updateChannelLogo(File file, int id) async {
    setState(() {
      loading = true;
    });
    upload_channel_logo(file, id).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          profileImage = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> updateVideoThumb(File file, int id) async {
    setState(() {
      loading = true;
    });
    upload_video_thumb(file, id).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          profileImage = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> updateChannelCover(File file, int id) async {
    setState(() {
      loading = true;
    });
    upload_channel_cover(file, id).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          coverImage = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> uploadProfile(File file) async {
    setState(() {
      loading = true;
    });
    upload_image(file).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          profileImage = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> updatePlayListThumb(File file, int id) async {
    setState(() {
      loading = true;
    });
    upload_playlist_thumb(file, id).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          playlistThumb = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> uploadPlayListThumb(File file) async {
    setState(() {
      loading = true;
    });
    upload_image(file).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          playlistThumb = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> uploadVideoThumb(File file) async {
    setState(() {
      loading = true;
    });
    try {
      upload_image(file).then((v) {
        setState(() {
          loading = false;
        });
        if (v != null) {
          setState(() {
            videoThumb = v;
          });
        } else {
          CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!,
            "Something went wrong.Try again",
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<Video?> uploadVideoTrailer(File file, int id) async {
    setState(() {
      loading = true;
    });
    setState(() {
      loading = true;
    });

    try {
      setState(() {
        loading = false;
      });
      Video? playlist = await upload_video_trailer(file, id);

      return playlist;
    } catch (e) {
      if (kDebugMode) {
        print("the_error");
      }
    }

    return null;
  }

  Future<void> uploadVideo(File file, File thumb) async {
    setState(() {
      loading = true;
      uploadProgress = 0;
      uploadingVideo = true;
    });
    upload_video(
      file,

      onProgress: (progress) {
        setState(() {
          if (kDebugMode) {
            print('the_progress $progress');
          }
          uploadProgress = progress;
        });
      },
    ).then((v) {
      setState(() {
        loading = false;
        uploadingVideo = false;
      });
      if (v != null) {
        setState(() {
          video = v;
        });

        uploadVideoThumb(thumb);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> listenForChannel(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<Channel?> stream = await get_channel(id);

    stream.listen(
      (Channel? employerModel) {
        setState(() {
          channelModel = employerModel;
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
    final Stream<VideoStatsModel?> stream = await get_video_stats(id);

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

  Future<void> listenForPlaylist(int id) async {
    setState(() {
      loading = true;
    });
    final Stream<Playlist?> stream = await getPlayList(id);

    stream.listen(
      (Playlist? employerModel) {
        setState(() {
          playlist = employerModel;
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
}
