package jp.sovation.adgene.adgene

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.socdm.d.adgeneration.ADGConsts
import io.flutter.plugin.common.MethodChannel
import jp.sovation.adgene.adgene.mylog

// 広告マネージャー
// 各広告の成功・エラーイベントをFlutter側に伝えたり
// AndroidのonResume, onPauseなどのイベントを広告オブジェクトにディスパッチする
class AdgeneAdManager(private val channel: MethodChannel) : DefaultLifecycleObserver {
    private var adMap = mutableMapOf<String, AdgeneAd>();

    // 広告を追加
    fun addAd(ad: AdgeneAd) {
        adMap[ad.id] = ad
    }

    // 広告を削除
    fun removeAd(id: String) {
        adMap.remove(id)
        mylog("Removed ad: $id")
    }

    // 広告の読み込み成功時
    fun onAdLoaded(id: String) {
        channel.invokeMethod("onAdLoaded", id);
    }

    // 広告の読み込みエラー時
    fun onAdLoadError(id: String, code: ADGConsts.ADGErrorCode) {
        mylog("load error ${code.name}")
        channel.invokeMethod("onAdLoadError", mapOf(
                "id" to id,
                "reason" to code.name,
        ))
    }

    override fun onResume(owner: LifecycleOwner) {
        adMap.forEach { entry -> entry.value.onResume() }
    }

    override fun onPause(owner: LifecycleOwner) {
        adMap.forEach { entry -> entry.value.onPause() }
    }

    override fun onStop(owner: LifecycleOwner) {
        adMap.forEach { entry -> entry.value.onPause() }
    }

    override fun onDestroy(owner: LifecycleOwner) {
        adMap.forEach { entry -> entry.value.onPause() }
    }
}