//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:flutter/foundation.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int currentInd = 0;

  // get currentIndex => _currentIndex;

  setcurrentIndex(int index) {
    currentInd = index;
    notifyListeners();
  }
}
