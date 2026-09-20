import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimens {
  // for padding , margin and sizedBox dimensions
  static const tiny = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xlarge = 20.0;
  static const xxlarge = 30.0;
  static const xxxlarge = 40.0;

  static const radius = 6.0;
  static const circleRadius = 75.0;

  static const buttonHeight = 50.0;
  static const textFieldHeight = 50.0;

  static const border = 1.0;
  static const borderWidthEnabled = 2.0;

  /// ScreenUtil Values
  // you can use [h => height - w => width - r => radius - sw => screen width - sh => screen height - font size = sp || sm (smart)]

  //The vertical extent of this size [Device height]
  static final double screenHeight = ScreenUtil().screenHeight;

  // The horizontal extent of this size [Device width]
  static final double screenWidth = ScreenUtil().screenWidth;

  // The number of font pixels for each logical pixel [System font scaling factor]
  static final double textScaleFactor = ScreenUtil().textScaleFactor;

  // The size of the media in logical pixels (e.g, the size of the screen) [Device pixel density]
  static final double? pixelRatio = ScreenUtil().pixelRatio;

  // The offset from the bottom [Bottom safe zone distance, suitable for buttons with full screen]
  static final double bottomBarHeight = ScreenUtil().bottomBarHeight;

  // The offset from the top [Status bar height , Notch will be higher]
  static final double statusBarHeight = ScreenUtil().statusBarHeight;

  // The ratio of actual width to UI design
  static final double scaleWidth = ScreenUtil().scaleWidth;

  // The ratio of actual height to UI design
  static final double scaleHeight = ScreenUtil().scaleHeight;

  // The ratio of actual text size to UI design
  static final double scaleText = ScreenUtil().scaleText;

  // Get screen orientation [Screen orientation]
  static final Orientation orientation = ScreenUtil().orientation;
}
