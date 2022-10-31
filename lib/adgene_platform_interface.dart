import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adgene_ad_manager.dart';
import 'adgene_method_channel.dart';

abstract class AdgenePlatform extends PlatformInterface {
  /// Constructs a AdgenePlatform.
  AdgenePlatform() : super(token: _token);

  static final Object _token = Object();

  static AdgenePlatform _instance = MethodChannelAdgene();

  /// The default instance of [AdgenePlatform] to use.
  ///
  /// Defaults to [MethodChannelAdgene].
  static AdgenePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdgenePlatform] when
  /// they register themselves.
  static set instance(AdgenePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  AdgeneAdManager get adManager => throw UnimplementedError();
}
