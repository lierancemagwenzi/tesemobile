import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/content-creator/repository/repository.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/notifications/repository/respository.dart';

class CreatorController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  double uploadProgress = 0;

  List<Channel> channels = [];
  Channel? channel;
  bool loading = false;
  UploadIdModel? coverImage;
  UploadIdModel? profileImage;
  UploadIdModel? playlistThumb;
  Playlist? playlist;
  UploadIdModel? videoThumb;

  bool uploadingVideo = false;

  File? updatedCover;
  VideoStatsModel? videoStatsModel;
  List<CategoryModel> categories = [];

  UploadIdModel? video;
  bool success = false;
  Channel? channelModel;
  CreatorController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
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
      print("the_error");
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
      print("the_error");
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
      print("the_error");
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
      print("the_error");
    }

    return null;
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
      print("the_error");
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
          print('the_progress $progress');
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
        print(a);
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
        print(a);
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
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }
}
