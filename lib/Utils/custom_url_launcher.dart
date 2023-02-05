//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:url_launcher/url_launcher.dart';

// ignore: non_constant_identifier_names
void custom_url_launcher(String url) async {
  if (url.startsWith("http")) {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication))
      throw 'Could not launch $url';
  } else {
    var newUrl = "http://$url";
    if (!await launchUrl(Uri.parse(newUrl),
        mode: LaunchMode.externalApplication)) throw 'Could not launch $newUrl';
  }
}
