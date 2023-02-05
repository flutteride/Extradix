//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';

InkWell myinkwell({Widget? child, Function? onTap, Function? onLongPress}) {
  return InkWell(
    onLongPress: onLongPress as void Function()? ?? null,
    splashColor: Colors.transparent,
    focusColor: Colors.transparent,
    hoverColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: child,
    onTap: onTap as void Function()? ?? null,
  );
}
