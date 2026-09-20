import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';

enum AppAccessStatus {
  active,
  maintenance,
  forceUpdate,
}

class AppAccessDecision {
  const AppAccessDecision({
    required this.status,
    required this.titleAr,
    required this.titleEn,
    required this.messageAr,
    required this.messageEn,
    required this.supportUrl,
    required this.androidStoreUrl,
  });

  final AppAccessStatus status;
  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final String supportUrl;
  final String androidStoreUrl;
}

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _applyConfigSettings();

      await _remoteConfig.setDefaults(<String, dynamic>{
        // Global emergency switch for all versions.
        'kill_switch_enabled': false,
        // If current build number is lower than this value -> force update.
        'minimum_supported_build': 0,
        // Optional blocked builds: e.g. "7,9,12"
        'blocked_builds_csv': '',
        'maintenance_title_ar': 'التطبيق تحت الصيانة',
        'maintenance_title_en': 'App Under Maintenance',
        'maintenance_message_ar': 'نجري تحديثات مهمة الآن، الرجاء المحاولة لاحقاً.',
        'maintenance_message_en':
            'We are performing important updates right now, please try again later.',
        'force_update_title_ar': 'يتطلب تحديث',
        'force_update_title_en': 'Update Required',
        'force_update_message_ar':
            'هذه النسخة قديمة. الرجاء التحديث من متجر Google Play للمتابعة.',
        'force_update_message_en':
            'This version is outdated. Please update from Google Play to continue.',
        'support_url': '',
        'android_store_url': '',
      });

      await fetchAndActivate();
    } catch (e) {
      log('RemoteConfig init error: $e');
    }
  }

  Future<void> fetchAndActivate() async {
    try {
      final bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        log('RemoteConfig updated');
      }
    } catch (e) {
      log('RemoteConfig fetch error: $e');
    }
  }

  Future<void> forceFetchAndActivate() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      log('RemoteConfig force fetch error: $e');
    } finally {
      await _applyConfigSettings();
    }
  }

  AppAccessDecision evaluateAccess({
    required int currentBuildNumber,
  }) {
    final bool killSwitchEnabled = _remoteConfig.getBool('kill_switch_enabled');
    final int minimumSupportedBuild =
        _remoteConfig.getInt('minimum_supported_build');
    final Set<int> blockedBuilds = _parseBuildsCsv(
      _remoteConfig.getString('blocked_builds_csv'),
    );

    final bool shouldForceUpdate = currentBuildNumber < minimumSupportedBuild ||
        blockedBuilds.contains(currentBuildNumber);

    if (shouldForceUpdate) {
      return AppAccessDecision(
        status: AppAccessStatus.forceUpdate,
        titleAr: _remoteConfig.getString('force_update_title_ar'),
        titleEn: _remoteConfig.getString('force_update_title_en'),
        messageAr: _remoteConfig.getString('force_update_message_ar'),
        messageEn: _remoteConfig.getString('force_update_message_en'),
        supportUrl: _remoteConfig.getString('support_url'),
        androidStoreUrl: _remoteConfig.getString('android_store_url'),
      );
    }

    if (killSwitchEnabled) {
      return AppAccessDecision(
        status: AppAccessStatus.maintenance,
        titleAr: _remoteConfig.getString('maintenance_title_ar'),
        titleEn: _remoteConfig.getString('maintenance_title_en'),
        messageAr: _remoteConfig.getString('maintenance_message_ar'),
        messageEn: _remoteConfig.getString('maintenance_message_en'),
        supportUrl: _remoteConfig.getString('support_url'),
        androidStoreUrl: _remoteConfig.getString('android_store_url'),
      );
    }

    return AppAccessDecision(
      status: AppAccessStatus.active,
      titleAr: '',
      titleEn: '',
      messageAr: '',
      messageEn: '',
      supportUrl: _remoteConfig.getString('support_url'),
      androidStoreUrl: _remoteConfig.getString('android_store_url'),
    );
  }

  Set<int> _parseBuildsCsv(String raw) {
    if (raw.trim().isEmpty) {
      return <int>{};
    }

    final normalized = raw
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('،', ',')
        .trim();

    return normalized
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toSet();
  }

  Future<void> _applyConfigSettings() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
  }
}
