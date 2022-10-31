package jp.sovation.fivesdk.fivesdk

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.socdm.d.adgeneration.ADG
import com.socdm.d.adgeneration.ADGConsts
import com.socdm.d.adgeneration.ADGListener
import io.flutter.plugin.platform.PlatformView
import jp.sovation.adgene.adgene.AdgeneAd
import jp.sovation.adgene.adgene.AdgeneAdManager

/**
 * Adgene広告のビュークラス
 */
internal class AdgeneAdView(context: Context, viewId: Int, private val adManager: AdgeneAdManager, creationParams: Map<String?, Any?>?) : PlatformView, DefaultLifecycleObserver, AdgeneAd {
    private var adg: ADG? = null
    private val view: LinearLayout = LinearLayout(context)

    // 広告の枠ID
    private var slotId: String = ""

    // 広告のインスタンスID(同じ広告枠を使うページが複数インスタンス存在することがあり、個別にイベント管理が必要なため)
    override var id: String = ""

    override fun getView(): View {
        return view
    }

    // 広告View破棄時の処理
    override fun dispose() {
        adManager.removeAd(id);
        mylog("ad disposed $id")
    }

    init {
        // パラメータの受け取り
        var isTest = creationParams?.get("isTest") as Boolean? ?: true
        var widthDp = creationParams?.get("widthDp") as Int? ?: 320
        var heightDp = creationParams?.get("heightDp") as Int? ?: 50
        var scale = creationParams?.get("scale") as Double? ?: 0.0
        slotId = creationParams?.get("slotId") as String? ?: ""
        id = creationParams?.get("id") as String? ?: ""

        // 広告のコンテナとなるビューを作成
        adg = ADG(context).apply {
            locationId = slotId
            adListener = AdListener()
            isEnableTestMode = isTest // リリース時には[必ず]falseにしてください
        }
        adg?.setAdFrameSize(ADG.AdFrameSize.FREE.setSize(widthDp, heightDp))
        adg?.setAdScale(scale);
        view.addView(adg)
        adg?.start()

        adManager.addAd(this)
        mylog("init adgene view done: $slotId, isTest=$isTest")
    }

    // 広告のイベントリスナー
    internal inner class AdListener : ADGListener() {
        // 成功
        override fun onReceiveAd() {
            mylog( "Received ad for slot: $slotId")
            adManager.onAdLoaded(id)
        }

        // 失敗
        override fun onFailedToReceiveAd(code: ADGConsts.ADGErrorCode) {
            adManager.onAdLoadError(id, code)
            when (code) {
                ADGConsts.ADGErrorCode.EXCEED_LIMIT, ADGConsts.ADGErrorCode.NEED_CONNECTION, ADGConsts.ADGErrorCode.NO_AD -> {
                    mylog( "Failed to receive an ad:$code")
                }
                else -> {
                    adg?.start()
                }
            }
        }

        override fun onClickAd() {
            // 何もしない
        }
    }

    // ライフサイクルのonResume時に広告を再開
    override fun onResume() {
        adg?.start()
    }

    // ライフサイクルのonPause時に広告を停止
    override fun onPause() {
        adg?.pause()
    }

}