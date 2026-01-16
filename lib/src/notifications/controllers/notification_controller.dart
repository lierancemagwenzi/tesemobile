import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/notifications/repository/respository.dart';

class NotificationController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;

  List<NotificationModel> notifications = [];
  NotificationModel? notificationModel;
  bool loading = false;

  bool success = false;

  NotificationController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> listenForNotifications() async {
    setState(() {
      loading = true;
    });
    notifications.clear();
    final Stream<NotificationModel> stream = await getnotifications();
    stream.listen(
      (NotificationModel notificationModel) {
        setState(() => notifications.add(notificationModel));
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
    notifications.clear();
    listenForNotifications();
  }

  void DeleteNotification(int id) {
    deletenotification({"id": id}).then((value) async {
      if (kDebugMode) {
        print(value);
      }
      loading = false;
      if (value != null) {
        setState(() {
          notifications.removeWhere((element) => element.id == id);
          success = true;
        });
        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Notification removed",
        );
      } else {}
    });
  }

  MarkAsRead(int id) {
    print("called");
    markasread({"id": id}).then((value) async {
      if (kDebugMode) {
        print(value);
      }
      loading = false;
      if (value != null) {
        setState(() {
          // notifications[index].opened = value;
          success = true;
        });
        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Done!",
        );
      } else {}
    });
  }
}
