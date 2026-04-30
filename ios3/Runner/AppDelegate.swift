import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import flutter_downloader
import BackgroundTasks
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

  if #available(iOS 15.0, *) {
          BGTaskScheduler.shared.register(
              forTaskWithIdentifier: "com.smatechgroup.tese.transfer", // Ensure this matches Info.plist
              using: nil
          ) { task in
              // The package handles the heavy lifting, but we acknowledge the task here
              task.setTaskCompleted(success: true)
          }
      }

if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
    GeneratedPluginRegistrant.register(with: self)
        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}


