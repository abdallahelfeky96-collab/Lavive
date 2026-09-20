import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.messageAr,
    required this.messageEn,
    required this.primaryButtonLabelAr,
    required this.primaryButtonLabelEn,
    required this.onPrimaryPressed,
    this.supportUrl,
  });

  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final String primaryButtonLabelAr;
  final String primaryButtonLabelEn;
  final Future<void> Function() onPrimaryPressed;
  final String? supportUrl;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = AppLocalizations.of(context).locale.languageCode == 'ar';
    final String title = isArabic ? titleAr : titleEn;
    final String message = isArabic ? messageAr : messageEn;
    final String primaryButtonLabel =
        isArabic ? primaryButtonLabelAr : primaryButtonLabelEn;
    final bool hasSupportLink =
        supportUrl != null && supportUrl!.trim().isNotEmpty;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              const Color(0xFF1E1E2C),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon or Image
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings_suggest_rounded,
                    size: 100.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 50.h),
                
                // Refresh Button
                ElevatedButton(
                  onPressed: () async {
                    await onPrimaryPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                    shape: RoundedRectanglePlatform.borderRadius(25.r),
                    elevation: 5,
                  ),
                  child: Text(
                    primaryButtonLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Contact Support
                if (hasSupportLink)
                  TextButton(
                    onPressed: () => _launchURL(supportUrl!),
                    child: Text(
                      isArabic ? 'اتصل بالدعم' : 'Contact Support',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class RoundedRectanglePlatform {
  static RoundedRectangleBorder borderRadius(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
