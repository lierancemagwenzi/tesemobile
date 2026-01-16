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
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/notifications/repository/respository.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';

class ClientController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  double uploadProgress = 0;

  List<User> creators = [];
    List<User> filteredCreators = [];
  Channel? channel;
  bool loading = false;
  UploadIdModel? coverImage;
  UploadIdModel? profileImage;
  UploadIdModel? playlistThumb;
  Playlist? playlist;
  UploadIdModel? videoThumb;

  bool uploadingVideo = false;
  List<PaymentLinkModel> filteredLinks = [];
  final List<PaymentLinkModel> paymentLinks = [];
  File? updatedCover;
  VideoStatsModel? videoStatsModel;
  List<CategoryModel> categories = [];
  List<PaymentLinkModel> links = [];
  UploadIdModel? video;
  bool success = false;
  Channel? channelModel;
  ClientController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<void> listenForLinks(int id) async {
    setState(() {
      loading = true;
    });
    creators.clear();
    final Stream<PaymentLinkModel> stream = await get_creator_links(id);
    stream.listen(
      (PaymentLinkModel notificationModel) {
        setState(() => paymentLinks.add(notificationModel));
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
          filteredLinks= paymentLinks;
          loading = false;
        });
      },
    );
  }
  Future<void> listenForCreators() async {
    setState(() {
      loading = true;
    });
    creators.clear();
    final Stream<User> stream = await get_creators();
    stream.listen(
      (User notificationModel) {
        setState(() => creators.add(notificationModel));
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
          filteredCreators=creators;
        });
      },
    );
  }
}
