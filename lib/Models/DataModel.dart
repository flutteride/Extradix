//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'dart:io';
import 'package:async/async.dart' show StreamGroup;
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

class DataModel extends Model {
  Map<String?, Map<String, dynamic>?> userData =
      new Map<String?, Map<String, dynamic>?>();

  Map<String, Future> _messageStatus = new Map<String, Future>();

  _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return _messageStatus[key] ?? true;
  }

  bool _loaded = false;

  LocalStorage _storage = LocalStorage('model');

  addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      _messageStatus.remove(key);
    });
    _messageStatus[key] = future;
  }

  addUser(DocumentSnapshot<Map<String, dynamic>> user) {
    userData[user.data()![Dbkeys.id]] = user.data();
    notifyListeners();
  }

  addUsermap(var user) {
    userData[user[Dbkeys.id]] = user;
    notifyListeners();
  }

  setWallpaper(String? id, File image) async {
    final dir = await getDir();
    int now = DateTime.now().millisecondsSinceEpoch;
    String path = '${dir.path}/WALLPAPER-$id-$now';
    await image.copy(path);
    userData[id]![Dbkeys.wallpaper] = path;
    updateItem(id!, {Dbkeys.wallpaper: path});
    notifyListeners();
  }

  removeWallpaper(String id) {
    userData[id]![Dbkeys.wallpaper] = null;
    String? path = userData[id]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[id]![Dbkeys.wallpaper] = null;
    }
    updateItem(id, {Dbkeys.wallpaper: null});
    notifyListeners();
  }

  getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  updateItem(String key, Map<String, dynamic> value) {
    Map<String, dynamic> old = _storage.getItem(key) ?? Map<String, dynamic>();

    old.addAll(value);
    _storage.setItem(key, old);
  }

  // setAlias(String aliasName, File? image, String id) async {
  //   userData[id]![Dbkeys.aliasName] = aliasName;
  //   if (image != null) {
  //     final dir = await getDir();
  //     int now = DateTime.now().millisecondsSinceEpoch;
  //     String path = '${dir.path}/$id-$now';
  //     await image.copy(path);
  //     userData[id]![Dbkeys.aliasAvatar] = path;
  //   }
  //   updateItem(id, {
  //     Dbkeys.aliasName: userData[id]![Dbkeys.aliasName],
  //     Dbkeys.aliasAvatar: userData[id]![Dbkeys.aliasAvatar],
  //   });
  //   notifyListeners();
  // }

  removeAlias(String id) {
    userData[id]![Dbkeys.aliasName] = null;
    String? path = userData[id]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[id]![Dbkeys.aliasAvatar] = null;
    }
    updateItem(id, {Dbkeys.aliasName: null, Dbkeys.aliasAvatar: null});
    notifyListeners();
  }

  bool get loaded => _loaded;

  Map<String, dynamic>? get currentUser => _currentUser;

  Map<String, dynamic>? _currentUser;

  Map<String?, int?> get lastSpokenAt => _lastSpokenAt;

  Map<String?, int?> _lastSpokenAt = {};

  getChatOrder(List<String> chatsWith, String? currentUserNo) {
    List<Stream<QuerySnapshot>> messages = [];
    chatsWith.forEach((otherNo) {
      String chatId = Utils.getChatId(currentUserNo, otherNo);
      messages.add(FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentIndividiualmessages)
          .doc(chatId)
          .collection(chatId)
          .snapshots());
    });
    StreamGroup.merge(messages).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot message = snapshot.docs.last;
        _lastSpokenAt[message[Dbkeys.from] == currentUserNo
            ? message[Dbkeys.to]
            : message[Dbkeys.from]] = message[Dbkeys.timestamp];
        notifyListeners();
      }
    });
  }

  DataModel(String? currentUserNo, String collectionname) {
    FirebaseFirestore.instance
        .collection(collectionname)
        .doc(currentUserNo)
        .snapshots()
        .listen((user) {
      _currentUser = user.data();
      notifyListeners();
    });
    _storage.ready.then((ready) {
      if (ready) {
        FirebaseFirestore.instance
            .collection(collectionname)
            .doc(currentUserNo)
            .collection(Dbkeys.chatsWith)
            .doc(Dbkeys.chatsWith)
            .snapshots()
            .listen((_chatsWith) {
          if (_chatsWith.exists) {
            List<Stream<DocumentSnapshot>> users = [];
            List<String> peers = [];
            _chatsWith.data()!.entries.forEach((_data) {
              peers.add(_data.key);
              users.add(FirebaseFirestore.instance
                  .collection(collectionname)
                  .doc(_data.key)
                  .snapshots());
              if (userData[_data.key] != null) {
                userData[_data.key]![Dbkeys.chatStatus] = _chatsWith[_data.key];
              }
            });
            getChatOrder(peers, currentUserNo);
            notifyListeners();
            Map<String?, Map<String, dynamic>?> newData =
                Map<String?, Map<String, dynamic>?>();
            StreamGroup.merge(users).listen((user) {
              if (user.exists) {
                newData[user[Dbkeys.id]] = user.data() as Map<String, dynamic>?;
                newData[user[Dbkeys.id]]![Dbkeys.chatStatus] =
                    _chatsWith[user[Dbkeys.id]];
                Map<String, dynamic>? _stored =
                    _storage.getItem(user[Dbkeys.id]);
                if (_stored != null) {
                  newData[user[Dbkeys.id]]!.addAll(_stored);
                }
              }
              userData = Map.from(newData);
              notifyListeners();
            });
          }
          if (!_loaded) {
            _loaded = true;
            notifyListeners();
          }
        });
      }
    });
  }
}
