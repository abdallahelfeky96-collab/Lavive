import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppAssetImage extends Image {
  AppAssetImage({super.key, 
    String? path = "",
    super.width = double.infinity,
    super.height = double.infinity,
    super.color,
  }) : super(
          image: AssetImage(path!),
        );
}
