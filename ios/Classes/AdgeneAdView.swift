import Flutter
import UIKit
import ADG

class AdgeneAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adManager: AdgeneAdManager
    
    init(messenger: FlutterBinaryMessenger, adManager: AdgeneAdManager) {
        self.messenger = messenger
        self.adManager = adManager
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AdgeneAdView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            adManager: self.adManager
        );
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AdgeneAdView: NSObject, FlutterPlatformView, ADGManagerViewControllerDelegate {
    private var adg: ADGManagerViewController?
    private var _view: UIView
    private var id: String
    private var adManager: AdgeneAdManager
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        adManager: AdgeneAdManager
    ) {
        self.adManager = adManager
        _view = UIView()
        _view.clipsToBounds = true // 親のサイズが小さくなったら広告が消えるように
        
        // 広告枠の初期化
        let dic = (args as? Dictionary<String,Any>)
        
        id = dic?["id"] as? String ?? ""
        let slotId = dic?["slotId"] as? String ?? ""
        let widthDp = dic?["widthDp"] as? Int ?? 320
        let heightDp = dic?["heightDp"] as? Int ?? 50
        let scale = dic?["scale"] as? Double ?? 0.0
        let isTest = dic?["isTest"] as? Bool ?? true // デフォルトでテストモード

        super.init()

        // ビューコントローラの取得
        // ref https://github.com/flutter/flutter/issues/9961#issuecomment-511114434
        let rootVc = UIApplication.shared.delegate!.window!!.rootViewController!

        adg = ADGManagerViewController(locationID: slotId, adType: .adType_Free, rootViewController: rootVc)
        adg?.setEnableTestMode(isTest)
        adg?.addAdContainerView(self._view) // 広告Viewを配置するViewを指定
        adg?.adSize = CGSize(width: widthDp, height: heightDp)
        adg?.adScale = Float(scale)
        adg?.delegate = self
        adg?.loadRequest()
        
        adManager.addAd(id: id, ad: self)
        mylog("init ad view done \(id)")
    }
                    
    func view() -> UIView {
        return _view
    }
    
    // 後始末
    func dispose(){
        // 広告ネイティブビューをコンテナから削除しないとクラッシュ
        _view.subviews.forEach({ $0.removeFromSuperview() })
        adg = nil
    }
    
    // アプリが再度アクティブになった時
    func applicationDidBecomeActive(){
        adg?.resumeRefresh()
    }

    // 広告の読み込み時
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController) {
        adManager.onAdLoaded(id: id)
        mylog("Received an ad: \(id)")
    }
    
    // 広告の読み込みエラー時
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController, code: kADGErrorCode) {
        mylog("Failed to receive an ad: \(code)")
        adManager.onAdLoadError(id: id, errorCode: code)
                
        // エラー時のリトライは特段の理由がない限り必ず記述するようにしてください。
        switch code {
        case .adgErrorCodeNeedConnection, // ネットワーク不通
                .adgErrorCodeExceedLimit, // エラー多発
                .adgErrorCodeNoAd: // 広告レスポンスなし
            mylog("network error occured")
            break
        default:
            adgManagerViewController.loadRequest()
        }
    }
    
    // 広告タップ時
    func adgManagerViewControllerDidTapAd(_ adgManagerViewController: ADGManagerViewController) {
        // 何もしない
    }
}
