import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    let controller = window?.rootViewController as! FlutterViewController
    FlutterMethodChannel(name: "com.tese/cookies", binaryMessenger: controller.binaryMessenger)
      .setMethodCallHandler { call, result in
        let storage = HTTPCookieStorage.shared
        let expiry = Date(timeIntervalSinceNow: 86400)

        func setCookie(name: String, value: String, domain: String) {
          if let cookie = HTTPCookie(properties: [
            .name: name, .value: value,
            .domain: domain, .path: "/",
            .secure: true, .expires: expiry,
          ]) { storage.setCookie(cookie) }
        }

        if call.method == "setCloudFrontCookies" {
          guard let args = call.arguments as? [String: String],
                let keyPairId = args["keyPairId"],
                let signature = args["signature"],
                let policy    = args["policy"],
                let domain    = args["domain"]
          else { result(FlutterMethodNotImplemented); return }
          setCookie(name: "CloudFront-Key-Pair-Id", value: keyPairId, domain: domain)
          setCookie(name: "CloudFront-Signature",   value: signature,  domain: domain)
          setCookie(name: "CloudFront-Policy",      value: policy,     domain: domain)
          result(nil)
        } else if call.method == "setPlaybackToken" {
          guard let args   = call.arguments as? [String: String],
                let token  = args["token"],
                let domain = args["domain"]
          else { result(FlutterMethodNotImplemented); return }
          setCookie(name: "x-playback-token", value: token, domain: domain)
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}


