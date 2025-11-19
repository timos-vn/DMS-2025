import 'dart:developer';
import 'dart:io';

import 'package:dms/services/shore_bird/shore_bird_widget.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';


const _checkUpdateInterval = Duration(minutes: 10);
const _currentTrack = UpdateTrack.stable;

// Cần update version flutter lên 3.24.5 để có để dùng bản mới nhất của ShorebirdUpdater
class ShorebirdUtils {
  ShorebirdUtils._();

  // Make ShorebirdUtils a singleton.
  static final instance = ShorebirdUtils._();

  final _updater = ShorebirdUpdater();

  DateTime? _lastCheckTime;

  /// Check for an update and restart the app if one is available.
  ///
  /// Đã set auto_update: false trong file shorebird.yaml để tự xử lý update lấy kèm theo restart app
  Future<void> checkUpdateAndRestart(BuildContext context) async {
    final allowed = Platform.isAndroid || Platform.isIOS;
    if (!allowed) {
      return;
    }

    final now = DateTime.now();
    if (_lastCheckTime != null &&
        _lastCheckTime!.difference(now).abs() < _checkUpdateInterval) {
      return;
    }
    _lastCheckTime = now;
    try {
      // Check if there's an update available.
      final status = await _updater.checkForUpdate(track: _currentTrack);
      if (status == UpdateStatus.outdated) {
        await _updater.update(track: _currentTrack);
        await _restartApp(context);
      } else if (status == UpdateStatus.restartRequired) {
        await _restartApp(context);
      }
    } catch (error) {
      log('Error checking for update: $error');
    }
  }

  Future<void> _restartApp(BuildContext context) async {
    // Show dialog to force restart app, và chờ người dùng bấm đồng ý trước khi restart
    String description = "Ứng dụng sẽ khởi động lại để cập nhật phiên bản mới.";
    if (Platform.isIOS) {
      // Ở iOS nếu chưa xin quyền notification thì app sễ bị đóng mà không có notification để mở lại
      // Do đó cần thay đổi nội dung thông báo để yêu cầu user tự mở lại app
      final isNotificationPermissionGranted =
      await Permission.notification.isGranted;
      if (!isNotificationPermissionGranted) {
        description =
        "Ứng dụng sẽ đóng để chập nhật. Vui lòng mở lại ứng dụng để tiếp tục sử dụng.";
      }
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return UtilsWidget.dialogUpdateShorebird(
          contentNotification: description,
          fuc: () async {
            await Restart.restartApp(
              notificationTitle: "Khởi động lại ứng dụng",
              notificationBody: "Vui lòng bấm vào đây để mở lại ứng dụng",
            );
          },
        );
      },
    );
  }

  Future<int?> readCurrentPatchNumber() async {
    try {
      final currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number;
    } catch (error) {
      log('Error reading current patch number: $error');
      return null;
    }
  }

  /// Request notification permission cho riêng iOS.
  /// Hỗ trợ việc hiển thị notification khi restart app. (Android không cần)
  ///
  /// Nếu sau này request notification permission với lib firebase_messaging thì không cần dùng hàm này nữa.
  /// Và cần comment lại dòng 'PERMISSION_NOTIFICATIONS=1' ở Podfile
  Future<void> requestNotificationPermission() async {
    if (!Platform.isIOS) return;

    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (error) {
      log('Error requesting notification permission: $error');
    }
  }
}
