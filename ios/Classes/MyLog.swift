import Foundation

// カスタムロガー(デバッグモードのときだけログが出る)
func mylog(_ items: Any...) {
    #if DEBUG
    let arr: [String] = ["AdgenePlugin:"] + items.map { String(describing: $0) }
    Swift.print(arr.joined(separator: " "))
    #endif
}
