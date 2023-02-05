//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:share/share.dart';

class Utils {
  static String? getNickname(Map<String, dynamic> user) =>
      user[Dbkeys.aliasName] ?? user[Dbkeys.nickname];

  static void toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Mycolors.black.withOpacity(0.95),
        textColor: Colors.white);
  }

  static void errortoast(String message) {
    Fluttertoast.showToast(
        msg: message, backgroundColor: Colors.red, textColor: Colors.white);
  }

  static void internetLookUp() async {
    try {
      await InternetAddress.lookup('google.com').catchError((e) {
        Utils.toast('No internet connection ${e.toString()}');
      });
    } catch (err) {
      Utils.toast('No internet connection. ${err.toString()}');
    }
  }

  static void invite(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
    String multilingualtext = Platform.isIOS
        ? '${getTranslatedForCurrentUser(context, 'letschat')} $Appname, ${getTranslatedForCurrentUser(context, 'joinme')} - ${observer.basicSettingDoc!.newapplinkios}'
        : '${getTranslatedForCurrentUser(context, 'letschat')} $Appname, ${getTranslatedForCurrentUser(context, 'joinme')} -  ${observer.basicSettingDoc!.newapplinkandroid}';
    Share.share(observer.isCustomAppShareLink == true
        ? (Platform.isAndroid
            ? observer.appShareMessageStringAndroid == ''
                ? multilingualtext
                : observer.appShareMessageStringAndroid
            : Platform.isIOS
                ? observer.appShareMessageStringiOS == ''
                    ? multilingualtext
                    : observer.appShareMessageStringiOS
                : multilingualtext)
        : multilingualtext);
  }

  static Widget avatar(Map<String, dynamic>? user,
      {File? image, double radius = 22.5}) {
    if (image == null) {
      if (user![Dbkeys.aliasAvatar] == null)
        return (user[Dbkeys.photoUrl] ?? '').isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    CachedNetworkImageProvider(user[Dbkeys.photoUrl]),
                radius: radius)
            : CircleAvatar(
                backgroundColor: Mycolors.primary,
                foregroundColor: Colors.white,
                child: Text(getInitials(Utils.getNickname(user)!)),
                radius: radius,
              );
      return CircleAvatar(
        backgroundImage: Image.file(File(user[Dbkeys.aliasAvatar])).image,
        radius: radius,
      );
    }
    return CircleAvatar(
        backgroundImage: Image.file(image).image, radius: radius);
  }

  static Future<int> getNTPOffset() {
    return NTP.getNtpOffset();
  }

  static Widget getNTPWrappedWidget(Widget child) {
    return FutureBuilder(
        future: NTP.getNtpOffset(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data! > Duration(minutes: 1).inMilliseconds ||
                snapshot.data! < -Duration(minutes: 1).inMilliseconds)
              return Material(
                  color: Mycolors.black,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            getTranslatedForCurrentUser(
                                context, 'xxclocktimexx'),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ))));
          }
          return child;
        });
  }

  static void showRationale(rationale) async {
    Utils.toast(rationale);
  }

  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer = new Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((_status) {
          bool granted = _status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else
        completer.complete(true);
    });
    return completer.future;
  }

  static String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll(new RegExp(r'[\W]'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2)
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      else if (names.elementAt(0).length >= 2)
        return names.elementAt(0).substring(0, 2);
      else
        return names.elementAt(0)[0];
    } catch (e) {
      return '?';
    }
  }

  static String getChatId(String? currentUserUID, String? peerUID) {
    if (currentUserUID.hashCode <= peerUID.hashCode)
      return '$currentUserUID-$peerUID';
    return '$peerUID-$currentUserUID';
  }

  static AuthenticationType getAuthenticationType(
      bool biometricEnabled, DataModel? model) {
    if (biometricEnabled && model?.currentUser != null) {
      return AuthenticationType
          .values[model!.currentUser![Dbkeys.authenticationType]];
    }
    return AuthenticationType.passcode;
  }

  static ChatStatus getChatStatus(int index) => ChatStatus.values[index];

  static String normalizePhone(String phone) =>
      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");

  static String getHashedAnswer(String answer) {
    answer = answer.toLowerCase().replaceAll(new RegExp(r"[^a-z0-9]"), "");
    var bytes = utf8.encode(answer); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getHashedString(String str) {
    var bytes = utf8.encode(str); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static bool isValidPassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static Color randomColorgenratorBasedOnFirstLetter(String fullstring) {
    String firstletter = fullstring.trim().length < 2
        ? fullstring
        : fullstring.trim().substring(0, 1);
    firstletter = firstletter == "" ? firstletter : firstletter.toLowerCase();

    switch (firstletter) {
      case "a":
        {
          return Mycolors.red;
        }

      case "b":
        {
          return Mycolors.blue;
        }
      case "c":
        {
          return Mycolors.purple;
        }
      case "d":
        {
          return Mycolors.green;
        }
      case "e":
        {
          return Mycolors.orange;
        }
      case "f":
        {
          return Mycolors.cyan;
        }
      case "g":
        {
          return Mycolors.pink;
        }
      case "h":
        {
          return Mycolors.orange;
        }
      case "i":
        {
          return Mycolors.green;
        }
      case "j":
        {
          return Mycolors.yellow;
        }

      case "k":
        {
          return Mycolors.blue;
        }
      case "l":
        {
          return Mycolors.purple;
        }
      case "m":
        {
          return Mycolors.green;
        }
      case "n":
        {
          return Mycolors.pink;
        }
      case "o":
        {
          return Mycolors.cyan;
        }
      case "p":
        {
          return Mycolors.red;
        }
      case "q":
        {
          return Mycolors.pink;
        }
      case "r":
        {
          return Mycolors.yellow;
        }
      case "s":
        {
          return Mycolors.orange;
        }

      case "t":
        {
          return Mycolors.blue;
        }
      case "u":
        {
          return Mycolors.red;
        }
      case "v":
        {
          return Mycolors.green;
        }
      case "w":
        {
          return Mycolors.blue;
        }
      case "x":
        {
          return Mycolors.cyan;
        }
      case "y":
        {
          return Mycolors.pink;
        }
      case "z":
        {
          return Mycolors.orange;
        }

      default:
        {
          return Mycolors.primary;
        }
    }
  }

  static squareAvatarIcon(
      {required Color backgroundColor,
      required IconData iconData,
      Color? iconColor,
      double? radius,
      required double size}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 10.0), //or 15.0
      child: Container(
        height: size,
        width: size,
        color: backgroundColor,
        child: Icon(iconData, color: Colors.white, size: size / 2),
      ),
    );
  }

  static squareAvatarImage(
      {Color? backgroundColor,
      required String url,
      double? radius,
      required double size}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 10.0), //or 15.0
      child: Container(
        height: size,
        width: size,
        color: backgroundColor ?? Colors.transparent,
        child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[100]!),
            ),
            width: size,
            height: size,
            padding: EdgeInsets.all(size / 2),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.all(
                Radius.circular(0.0),
              ),
            ),
          ),
          errorWidget: (context, str, error) => Material(
            child: Image.asset(
              'assets/images/img_not_available.jpeg',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(0.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        //  Icon(iconData, color: Colors.white, size: size / 2),
      ),
    );
  }

  static sendDirectNotification(
      {required String title,
      required String parentID,
      required String plaindesc,
      String? styleddesc,
      required DocumentReference docRef,
      String? imageurl = "",
      required String postedbyID,
      bool? isOnlyAlertNoSave = false}) async {
    await docRef.set({
      Dbkeys.nOTIFICATIONxxtitle: title,
      Dbkeys.nOTIFICATIONxxdesc: plaindesc,
      Dbkeys.nOTIFICATIONxxlastupdateepoch:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
      Dbkeys.list: FieldValue.arrayUnion([
        {
          Dbkeys.docid: DateTime.now().millisecondsSinceEpoch.toString(),
          Dbkeys.nOTIFICATIONxxdesc: styleddesc ?? plaindesc,
          Dbkeys.nOTIFICATIONxxtitle: title,
          Dbkeys.nOTIFICATIONxximageurl: imageurl,
          Dbkeys.nOTIFICATIONxxlastupdateepoch:
              DateTime.now().millisecondsSinceEpoch,
          Dbkeys.nOTIFICATIONxxauthor: postedbyID,
          Dbkeys.nOTIFICATIONxxextrafield: parentID
        }
      ])
    }, SetOptions(merge: true));
  }

  static requestDelete(
      {required BuildContext context,
      required String topicName,
      required String sendBy,
      required TextEditingController reportEditingController,
      required String topicid,
      required bool isDeleteRequest}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          var w = MediaQuery.of(context).size.width;
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height >
                        MediaQuery.of(context).size.width
                    ? MediaQuery.of(context).size.height / 2.6
                    : MediaQuery.of(context).size.height / 2.0,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          isDeleteRequest == false
                              ? getTranslatedForCurrentUser(
                                  context, 'xxreportshortxx')
                              : getTranslatedForCurrentUser(
                                  context, 'xxrequestadmintoadminxx'),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.5),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        // height: 63,
                        height: 83,
                        width: w / 1.24,
                        child: InpuTextBox(
                          controller: reportEditingController,
                          leftrightmargin: 0,
                          showIconboundary: false,
                          boxcornerradius: 5.5,
                          boxheight: 50,
                          hinttext: isDeleteRequest
                              ? getTranslatedForCurrentUser(
                                  context, 'xxmentionreasonxx')
                              : getTranslatedForCurrentUser(
                                  context, 'xxreportdescxx'),
                          prefixIconbutton: Icon(
                            Icons.message,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: w / 10,
                      ),
                      myElevatedButton(
                          color: Mycolors.secondary,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Text(
                              isDeleteRequest
                                  ? getTranslatedForCurrentUser(
                                      context, 'xxsubmitxx')
                                  : getTranslatedForCurrentUser(
                                      context, 'xxreportxx'),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();

                            DateTime time = DateTime.now();

                            Map<String, dynamic> mapdata = {
                              'title': isDeleteRequest
                                  ? 'New Delete Request by ${getTranslatedForCurrentUser(context, 'xxagentxx')}'
                                  : "New Report from ${getTranslatedForCurrentUser(context, 'xxagentxx')}",
                              'desc': '${reportEditingController.text}',
                              'uid': '$sendBy',
                              'type': topicName,
                              'time': time.millisecondsSinceEpoch,
                              'id': topicid,
                            };

                            await FirebaseFirestore.instance
                                .collection('reports')
                                .doc(time.millisecondsSinceEpoch.toString())
                                .set(mapdata)
                                .then((value) async {
                              Utils.toast("Request Submitted successfully !");

                              //----
                            }).catchError((err) {
                              Utils.toast("Request Submitted successfully !");
                            });
                          }),
                    ])),
          );
        });
  }
}
