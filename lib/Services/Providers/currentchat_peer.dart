//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CurrentChatPeer with ChangeNotifier {
  String? currentPageID = '';
  // String? groupChatId = '';
  // String? ticketChatId = '';

  setpeer(
    newpeerid,
    // String? newgroupChatId,
    // String? newticketChatId,
  ) {
    currentPageID = newpeerid ?? currentPageID;
    // groupChatId = newgroupChatId ?? groupChatId;
    // ticketChatId = newticketChatId ?? ticketChatId;
    notifyListeners();
  }
}
