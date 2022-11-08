import 'package:adgene/adgene.dart';
import 'package:adgene/adgene_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ネイティブ側に渡すパラメータ
class AdgeneAdNativeParams {
  final int widthDp;
  final int heightDp;
  final double scale;
  final bool isTest;
  final String slotId;
  final String id;

  AdgeneAdNativeParams({
    required this.slotId,
    required this.id,
    required this.isTest,
    required this.widthDp,
    required this.heightDp,
    required this.scale,
  });

  Map<String, dynamic> encode() {
    return {
      "widthDp": widthDp,
      "heightDp": heightDp,
      "scale": scale,
      "isTest": isTest,
      "slotId": slotId,
      "id": id,
    };
  }
}

/// 広告読み込み成功のリスナー
typedef AdgeneAdLoadedListener = VoidCallback;

/// 広告読み込みエラーのリスナー
typedef AdgeneAdLoadErrorListener = Function(AdgeneAdLoadError err);

class Ad {
  Ad();

  AdgeneAdLoadErrorListener? loadErrorListener;
  AdgeneAdLoadedListener? loadedListener;
}

///
/// Adgene広告
///
class AdgeneAd extends StatefulWidget {
  static String viewType = 'adgene-ad-view';

  final String slotId;
  final int width;
  final int height;
  final bool isTest;

  final ad = Ad();

  AdgeneAd({
    super.key,
    required this.slotId,
    required this.width,
    required this.height,
    this.isTest = true,
  });

  @override
  State<AdgeneAd> createState() => _AdgeneAdState();

  /// 広告の読み込みが成功
  onAdLoaded() {
    debugPrint("ad loaded successfully: $slotId");
    if (ad.loadedListener != null) {
      ad.loadedListener!();
    }
  }

  /// 広告の読み込みが失敗
  onAdLoadError(AdgeneAdLoadError err) {
    debugPrint("ad loaded error: $err");
    if (ad.loadErrorListener != null) {
      ad.loadErrorListener!(err);
    }
  }
}

class _AdgeneAdState extends State<AdgeneAd> {
  bool enabled = true;
  late final String _id;
  Widget? _nativeAdView;

  @override
  void initState() {
    _id = widget.hashCode.toString();
    // 広告マネージャに登録
    Adgene.adManager.addAd(_id, widget);

    widget.ad.loadedListener = (() {
      setState(() {
        enabled = true;
      });
    });

    widget.ad.loadErrorListener = (err) {
      setState(() {
        enabled = false;
      });
    };

    super.initState();
  }

  @override
  void dispose() {
    Adgene.adManager.disposeAd(_id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("slotId: ${widget.slotId}, enabled: $enabled");

    return LayoutBuilder(builder: (context, constraint) {
      // ネイティブ側に渡すパラメータ
      final widthDp = (constraint.biggest.width).toInt();
      final heightDp = (widthDp * (widget.height / widget.width)).toInt();
      final scale = widthDp / widget.width;

      final params = AdgeneAdNativeParams(
              widthDp: widthDp,
              heightDp: heightDp,
              scale: scale,
              isTest: widget.isTest,
              id: _id,
              slotId: widget.slotId)
          .encode();

      // ネイティブのViewは一度作ったものをキャッシュする
      _nativeAdView ??= _getNativeAdView(params);

      return SizedBox(
        height: enabled ? heightDp.toDouble() : 0,
        child: AspectRatio(
          aspectRatio: widget.width / widget.height,
          child: _nativeAdView,
        ),
      );
    });
  }

  // ネイティブビューを取得
  Widget _getNativeAdView(Map<String, dynamic> params) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdgeneAd.viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.android:
        return AndroidView(
          viewType: AdgeneAd.viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }
}
