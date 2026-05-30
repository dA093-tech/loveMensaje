import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';

import 'package:hooklove/core/constants/app_constants.dart';

class UpdateInfo {
  final String latestVersion;
  final String apkUrl;
  final bool forceUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.apkUrl,
    required this.forceUpdate,
  });
}

class UpdateService {
  final FirebaseFirestore _firestore;

  UpdateService(this._firestore);

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final doc = await _firestore.collection('config').doc('app_version').get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      final latestVersion = data['latestVersion'] as String?;
      final apkUrl = data['apkUrl'] as String?;
      if (latestVersion == null || apkUrl == null) return null;
      if (_compareVersions(latestVersion, AppConstants.appVersion) <= 0) {
        return null;
      }
      return UpdateInfo(
        latestVersion: latestVersion,
        apkUrl: apkUrl,
        forceUpdate: data['forceUpdate'] as bool? ?? false,
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.parse).toList();
    final bParts = b.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      final aVal = i < aParts.length ? aParts[i] : 0;
      final bVal = i < bParts.length ? bParts[i] : 0;
      if (aVal != bVal) return aVal - bVal;
    }
    return 0;
  }

  Future<String> downloadApk(String url) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    final dir = Directory.systemTemp;
    final file = File('${dir.path}/hooklove_update.apk');

    await response.pipe(file.openWrite());
    return file.path;
  }

  Future<void> installApk(String filePath) async {
    await OpenFile.open(filePath);
  }
}
