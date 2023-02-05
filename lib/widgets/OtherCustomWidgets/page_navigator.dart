//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

pageNavigator(BuildContext context, Widget widget) {
  Navigator.push(context,
      PageTransition(type: PageTransitionType.rightToLeft, child: widget));
}

pageOpenOnTop(BuildContext context, Widget widget) {
  Navigator.push(context,
      PageTransition(type: PageTransitionType.bottomToTop, child: widget));
}
