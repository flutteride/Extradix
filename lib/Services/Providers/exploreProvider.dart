//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ExploreProvider with ChangeNotifier {
  DocumentSnapshot<Map<String, dynamic>>? exploreDoc;
  bool isloading = true;
  String errorMssg = '';
  bool isPageViewed = false;
  List bannersclicksList = [];
  List widgetclicksList = [];

  reset() {
    exploreDoc = null;
    isloading = true;
    errorMssg = '';
    isPageViewed = false;
    bannersclicksList = [];
    widgetclicksList = [];
    notifyListeners();
  }

  setPageViewed() {
    if (isPageViewed == false) {
      FirebaseFirestore.instance
          .collection('explore')
          .doc('explore')
          .update(Platform.isIOS
              ? {'iospageViews': FieldValue.increment(1)}
              : {'androidpageViews': FieldValue.increment(1)})
          .then((value) {
        isPageViewed = true;
        notifyListeners();
      });
    }
  }

  setClicked(String docid, String currentUserNo, bool isbannerWidget) {
    if (isbannerWidget == true) {
      if (!bannersclicksList.contains(docid)) {
        FirebaseFirestore.instance.collection('explore').doc('explore').update({
          docid + 'c': FieldValue.increment(1),
          docid + 'v': FieldValue.arrayUnion([currentUserNo])
        }).then((value) {
          bannersclicksList.add(docid);
          notifyListeners();
        });
      }
    } else {
      if (!widgetclicksList.contains(docid)) {
        FirebaseFirestore.instance.collection('explore').doc('explore').update({
          docid + 'c': FieldValue.increment(1),
          docid + 'v': FieldValue.arrayUnion([currentUserNo])
        }).then((value) {
          widgetclicksList.add(docid);
          notifyListeners();
        });
      }
    }
  }

  fetchDoc(Function callback) async {
    errorMssg = '';

    await FirebaseFirestore.instance
        .collection('explore')
        .doc('explore')
        .get()
        .then((doc) {
      if (doc.exists) {
        isloading = false;
        exploreDoc = doc;
        callback();
        notifyListeners();
      } else {
        isloading = false;
        errorMssg = 'This Page is Not Setup yet from the Admin App';
        notifyListeners();
      }
    }).catchError((onError) {
      isloading = false;
      errorMssg = 'Error Occured While Loading this Page.  ERROR: $onError';
      notifyListeners();
    });
  }
}
