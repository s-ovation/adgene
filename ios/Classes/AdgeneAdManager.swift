import Foundation
import ADG

// AdgeneADの広告管理
class AdgeneAdManager {
    private var channel: FlutterMethodChannel
    private var adMap: Dictionary<String, AdgeneAdView> = [:]
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    //  広告インスタンスを追加
    func addAd(id: String, ad: AdgeneAdView){
        adMap[id] = ad
    }
        
    // 広告インスタンスを破棄
    func disposeAd(id: String) {
        let ad = adMap[id]
        ad?.dispose()
        adMap.removeValue(forKey: id)
    }
        
    // 広告読み込み完了をFlutter側に通知
    func onAdLoaded(id: String) {
        self.channel.invokeMethod("onAdLoaded", arguments: id)
    }

    // 広告読み込みエラーをFlutter側に通知
    func onAdLoadError(id: String, errorCode: kADGErrorCode) {
        // errorCode -> logical reason message
        var reason = ""
        switch( errorCode ){
        case .adgErrorCodeNeedConnection:
            reason = "NeedConnection"
            break
        case .adgErrorCodeCommunicationError:
            reason = "CommunicationError"
            break
        case .adgErrorCodeExceedLimit:
            reason = "ExceedLimit"
            break
        case .adgErrorCodeNoAd:
            reason = "NoAd"
            break
        case .adgErrorCodeReceivedFiller:
            reason = "ReceivedFiller"
            break
        case .adgErrorCodeTemplateFailed:
            reason = "TemplateFailed"
            break
        default:
            reason = "Unknown"
            break
        }

        let args: Dictionary<String, String> = [
            "id": id,
            "reason": reason
        ]

        self.channel.invokeMethod("onAdLoadError", arguments: args)
    }
    
    // アプリがアクティブになった時に広告表示を再開
    func applicationDidBecomeActive(){
        for (_, ad) in adMap {
            ad.applicationDidBecomeActive()
        }
    }
}
