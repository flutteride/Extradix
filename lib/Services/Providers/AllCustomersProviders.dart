// //  _________ USERS ____________
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:thinkcreative_technologies/Configs/db_keys.dart';
// import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
// import 'package:thinkcreative_technologies/Services/Providers/FirebaseDataAPIProvider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class FirestoreDataProviderCUSTOMERS extends ChangeNotifier {
//   final datalistSnapshot = <DocumentSnapshot>[];
//   String _errorMessage = '';
//   bool _hasNext = true;
//   bool _isFetchingData = false;

//   String get errorMessage => _errorMessage;

//   bool get hasNext => _hasNext;

//   List get recievedDocs => datalistSnapshot.map((snap) {
//         final recievedData = snap.data();

//         return recievedData;
//       }).toList();

//   reset() {
//     _hasNext = true;
//     datalistSnapshot.clear();
//     _isFetchingData = false;
//     _errorMessage = '';
//     recievedDocs.clear();
//     notifyListeners();
//   }

//   Future fetchNextData(
//       String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
//     if (_isFetchingData) return;

//     _errorMessage = '';
//     _isFetchingData = true;

//     try {
//       final snap = isAfterNewdocCreated == true
//           ? await FirebaseDataApi.getFirestoreCOLLECTIONData(12,
//               // startAfter: null,
//               refdata: refdataa)
//           : await FirebaseDataApi.getFirestoreCOLLECTIONData(12,
//               startAfter:
//                   datalistSnapshot.isNotEmpty ? datalistSnapshot.last : null,
//               refdata: refdataa);
//       if (isAfterNewdocCreated == true) {
//         datalistSnapshot.clear();
//         datalistSnapshot.addAll(snap.docs);
//       } else {
//         datalistSnapshot.addAll(snap.docs);
//       }
//       // notifyListeners();
//       if (snap.docs.length < 12) _hasNext = false;
//       notifyListeners();
//     } catch (error) {
//       _errorMessage = error.toString();
//       notifyListeners();
//     }

//     _isFetchingData = false;
//   }

//   updateparticulardocinProvider({
//     required String collection,
//     String? document,
//     String? compareKey,
//     String? compareVal,
//     GlobalKey? scaffoldkey,
//     BuildContext? context,
//   }) async {
//     int index =
//         datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);
//     await FirebaseFirestore.instance
//         .collection(collection)
//         .doc(document)
//         .get()
//         .then((value) {
//       datalistSnapshot.removeAt(index);
//       datalistSnapshot.insert(index, value);
//       notifyListeners();
//     });
//   }

//   deleteparticulardocinProvider({
//     String? collection,
//     String? document,
//     String? compareKey,
//     String? compareVal,
//     GlobalKey? scaffoldkey,
//     GlobalKey? keyloader,
//     BuildContext? context,
//   }) async {
//     int index =
//         datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);

//     datalistSnapshot.removeAt(index);
//     notifyListeners();
//   }

//   Future getparticularCustomerFromProvider(String uid) async {
//     int i = datalistSnapshot.indexWhere((element) => element[Dbkeys.id] == uid);
//     if (i >= 0) {
//       return datalistSnapshot[i];
//     } else {
//       var doc = await FirebaseFirestore.instance
//           .collection(DbPaths.collectioncustomers)
//           .doc(uid)
//           .get();
//       datalistSnapshot.add(doc);
//       notifyListeners();
//       return doc;
//     }
//   }
// }
