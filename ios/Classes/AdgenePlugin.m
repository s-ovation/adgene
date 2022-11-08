#import "AdgenePlugin.h"
#if __has_include(<adgene/adgene-Swift.h>)
#import <adgene/adgene-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adgene-Swift.h"
#endif

@implementation AdgenePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdgenePlugin registerWithRegistrar:registrar];
}
@end
