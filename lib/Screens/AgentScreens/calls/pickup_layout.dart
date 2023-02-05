//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Models/call.dart';
import 'package:thinkcreative_technologies/Models/call_methods.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final String curentUserID;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    required this.scaffold,
    required this.prefs,
    required this.curentUserID,
  });

  @override
  Widget build(BuildContext context) {
    final Observer observer = Provider.of<Observer>(context);

    return observer.isOngoingCall == true
        ? scaffold
        : StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: curentUserID),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                Call call = Call.fromMap(
                    snapshot.data!.data() as Map<dynamic, dynamic>);

                if (!call.hasDialled!) {
                  return PickupScreen(
                    currentUserisAgent: prefs.getInt(Dbkeys.userLoginType) ==
                                Usertype.customer.index ||
                            prefs.getInt(Dbkeys.userLoginType) == null
                        ? false
                        : true,
                    prefs: prefs,
                    call: call,
                    currentUserID: curentUserID,
                  );
                }
              }
              return scaffold;
            },
          );
  }
}
