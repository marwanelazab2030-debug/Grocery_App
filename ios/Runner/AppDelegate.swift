import UIKit
import Flutter
import GoogleMaps // ✅ Add this line

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Initialize Google Maps with your API Key
    GMSServices.provideAPIKey("AIzaSyDIgv2x_ZQH-AX3e5zKEtncuC9tJrnx1w0")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
