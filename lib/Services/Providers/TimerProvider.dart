//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  bool wait = false;
  int start = timeOutSeconds;
  bool isActionBarShow = false;
  startTimer() {}

  resetTimer() {
    start = timeOutSeconds;
    isActionBarShow = false;
    notifyListeners();
  }
}
