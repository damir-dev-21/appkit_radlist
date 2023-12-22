import 'package:url_launcher/url_launcher.dart' as Launcher;

abstract class UrlLauncher {
  static Future<void> launch(String url) async {
    final uri = Uri.parse(url);
    if (await Launcher.canLaunchUrl(uri)) {
      await Launcher.launchUrl(uri);
    }
  }
}
