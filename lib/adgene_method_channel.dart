import 'package:adgene/adgene_ad_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adgene_platform_interface.dart';

/// An implementation of [AdgenePlatform] that uses method channels.
class MethodChannelAdgene extends AdgenePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jp.sovation.adgene.adgene');

  late final AdgeneAdManager _adManager;

  MethodChannelAdgene() {
    _adManager = AdgeneAdManager(methodChannel);
  }

  @override
  AdgeneAdManager get adManager => _adManager;
}
