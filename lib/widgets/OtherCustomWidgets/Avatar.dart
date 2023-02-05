//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:flutter/material.dart';

Widget avatar(
    {String? imageUrl, double radius = 22.5, String? backgroundColor}) {
  if (imageUrl == null || imageUrl == "") {
    return CircleAvatar(
      backgroundImage: Image.network(Defaultprofilepicfromnetworklink).image,
      radius: radius,
    );
  }
  return CircleAvatar(
      backgroundImage: Image.network(imageUrl).image, radius: radius);
}
