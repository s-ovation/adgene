import 'adgene_ad_manager.dart';
import 'adgene_platform_interface.dart';

class Adgene {
  static AdgeneAdManager get adManager => AdgenePlatform.instance.adManager;
}
