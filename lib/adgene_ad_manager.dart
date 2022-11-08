import 'package:adgene/adgene_common.dart';
import 'package:adgene/widget/adgene_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 広告マネージャー ネイティブ側とのコミュニケーションとインスタンス管理
class AdgeneAdManager {
  final MethodChannel channel;
  final Map<String, AdgeneAd> adMap = {};

  AdgeneAdManager(this.channel) {
    channel.setMethodCallHandler((call) => _onMethodCall(call));
  }

  /// 広告を管理対象に追加
  addAd(String id, AdgeneAd ad) {
    if (adMap.containsKey(id) == false) {
      adMap[id] = ad;
    }
  }

  /// 広告を破棄
  disposeAd(String id) {
    adMap.remove(id);
    channel.invokeMethod("disposeAd", {"id": id});
  }

  /// 広告オブジェクトを取得
  AdgeneAd? _getAd(String id) {
    return adMap[id];
  }

  /// ネイティブ側からイベントが呼ばれた
  _onMethodCall(MethodCall call) {
    try {
      debugPrint("onMethodCall: ${call.method} ${call.arguments}");
      switch (call.method) {
        case "onAdLoaded":
          onAdLoaded(call.arguments);
          break;
        case "onAdLoadError":
          onAdLoadError(call.arguments);
          break;
      }
    } catch (err) {
      // ignore unexpected error
      debugPrint(err.toString());
    }
  }

  /// 広告枠の読み込み成功をウィジェットに通知
  onAdLoaded(dynamic args) {
    final id = args;
    final ad = _getAd(id);
    if (ad == null) {
      return;
    }
    ad.onAdLoaded();
  }

  /// 広告枠の読み込みエラーをウィジェットに通知
  onAdLoadError(Map args) {
    final id = args["id"] as String;
    final reason = args["reason"] ?? "";
    final ad = _getAd(id);
    if (ad == null) {
      return;
    }
    AdgeneAdLoadError err = AdgeneAdLoadError.unknown;
    switch (reason) {
      case "CommunicationError":
        err = AdgeneAdLoadError.communicationError;
        break;
      case "ReceivedFiller":
        err = AdgeneAdLoadError.receivedFiller;
        break;
      case "NoAd":
        err = AdgeneAdLoadError.noAd;
        break;
      case "NeedConnection":
        err = AdgeneAdLoadError.needConnection;
        break;
      case "ExceedLimit":
        err = AdgeneAdLoadError.exceedLimit;
        break;
      case "TemplateFailed":
        err = AdgeneAdLoadError.templateFailed;
        break;
      default:
        err = AdgeneAdLoadError.unknown;
    }
    ad.onAdLoadError(err);
  }
}
