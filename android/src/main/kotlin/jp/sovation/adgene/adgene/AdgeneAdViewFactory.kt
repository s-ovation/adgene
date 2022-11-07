package jp.sovation.adgene.adgene

import android.content.Context
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import jp.sovation.adgene.adgene.AdgeneAdManager

class AdgeneAdViewFactory(private val adManager: AdgeneAdManager) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return AdgeneAdView(context, viewId, adManager, creationParams)
    }
}