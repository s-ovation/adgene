package jp.sovation.adgene.adgene

// すべての広告が持つべきインターフェース
interface AdgeneAd {
    val id: String
    fun onResume()
    fun onPause()
}