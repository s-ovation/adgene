import Flutter
import UIKit

public class SwiftAdgenePlugin: NSObject, FlutterPlugin {
    private var adManager: AdgeneAdManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jp.sovation.adgene.adgene", binaryMessenger: registrar.messenger())
        let instance = SwiftAdgenePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        // アプリライフサイクルを取得する
        registrar.addApplicationDelegate(instance)
        
        instance.adManager = AdgeneAdManager(channel: channel)
        let factory = AdgeneAdViewFactory(messenger: registrar.messenger(), adManager: instance.adManager!)
        
        registrar.register(factory, withId: "adgene-ad-view")
    }
    
    // Flutterから呼ばれた関数呼び出しの処理
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>

        switch( call.method ){
        case "disposeAd":
            let id = args?["id"] as? String
            if id != nil {
                adManager?.disposeAd(id: id!)
            }
            result(nil)
            break
        default:
            result(FlutterError(code: "unsupportedMethod", message: "Unsupported method", details: nil))
            break
        }
    }
    
    // アプリが非アクティブ状態からアクティブに戻ったときに呼ばれる
    public func applicationDidBecomeActive(_ application: UIApplication) {
        adManager?.applicationDidBecomeActive()
    }
}
