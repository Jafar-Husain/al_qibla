import UIKit
import Flutter
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "task-identifier")
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", frequency: NSNumber(value: 20 * 60))
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
    GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
