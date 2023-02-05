//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLiveDataServices {
  // FirebaseFirestore _fireStoreDataBase = FirebaseFirestore.instance;/

  //recieve the data

  Stream<SpecialLiveConfigData> getLiveData(DocumentReference query) {
    return query
        .snapshots()
        .map((document) => SpecialLiveConfigData.fromJson(document.data()));
  }
}

class SpecialLiveConfigData {
  var docmap = {};

  SpecialLiveConfigData.fromJson(var parsedJSON) : docmap = parsedJSON;
}
