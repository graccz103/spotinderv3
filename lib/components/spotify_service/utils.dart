import 'package:url_launcher/url_launcher.dart';

Future<void> openSpotifyLink(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    // Otwiera dialog wyboru aplikacji
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
