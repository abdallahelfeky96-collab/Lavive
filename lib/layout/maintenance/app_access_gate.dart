import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vegesea/layout/maintenance/maintenance_screen.dart';
import 'package:vegesea/layout/splash/splash_screen.dart';
import 'package:vegesea/shared/shared/Network/remote_config_service.dart';

class AppAccessGate extends StatefulWidget {
  const AppAccessGate({super.key});

  @override
  State<AppAccessGate> createState() => _AppAccessGateState();
}

class _AppAccessGateState extends State<AppAccessGate> {
  AppAccessDecision? _decision;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await RemoteConfigService().forceFetchAndActivate();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

    final decision = RemoteConfigService().evaluateAccess(
      currentBuildNumber: currentBuildNumber,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _decision = decision;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _decision == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final decision = _decision!;

    if (decision.status == AppAccessStatus.active) {
      return const SplashScreen();
    }

    if (decision.status == AppAccessStatus.forceUpdate) {
      return MaintenanceScreen(
        titleAr: decision.titleAr,
        titleEn: decision.titleEn,
        messageAr: decision.messageAr,
        messageEn: decision.messageEn,
        primaryButtonLabelAr: 'تحديث الآن',
        primaryButtonLabelEn: 'Update now',
        supportUrl: decision.supportUrl,
        onPrimaryPressed: () async {
          final uri = Uri.tryParse(decision.androidStoreUrl);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }

          await _evaluate();
        },
      );
    }

    return MaintenanceScreen(
      titleAr: decision.titleAr,
      titleEn: decision.titleEn,
      messageAr: decision.messageAr,
      messageEn: decision.messageEn,
      primaryButtonLabelAr: 'إعادة المحاولة',
      primaryButtonLabelEn: 'Try again',
      supportUrl: decision.supportUrl,
      onPrimaryPressed: _evaluate,
    );
  }
}
