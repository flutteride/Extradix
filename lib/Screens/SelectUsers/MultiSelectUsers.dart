//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/users/widgets/usercard.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiSelectUsers extends StatefulWidget {
  const MultiSelectUsers({
    required this.prefs,
    required this.title,
    required this.usertype,
    required this.isShowPhonenumber,
    this.managerUID,
    this.initfetchlimit,
    required this.onselected,
    this.bannedusers,
  });
  final String title;
  final String? managerUID;
  final int usertype;
  final Function(
    List<dynamic> listuids,
    List<dynamic> listmap,
  ) onselected;
  final int? initfetchlimit;
  final SharedPreferences prefs;
  final List<dynamic>? bannedusers;
  final bool isShowPhonenumber;
  @override
  _MultiSelectUsersState createState() => new _MultiSelectUsersState();
}

class _MultiSelectUsersState extends State<MultiSelectUsers> {
  List<dynamic> selectedlist = [];
  List<dynamic> maplist = [];
  @override
  Widget build(BuildContext context) {
    final registry = Provider.of<UserRegistry>(context, listen: false);
    return Scaffold(
      backgroundColor: Mycolors.backgroundcolor,
      appBar: AppBar(
        actions: [
          selectedlist.length == 0
              ? SizedBox()
              : IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onselected(selectedlist, maplist);
                  },
                  icon: Icon(Icons.check))
        ],
        elevation: 0.4,
        backgroundColor:
            Mycolors.getColor(widget.prefs, Colortype.primary.index),
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: widget.usertype == Usertype.agent.index
          ? ListView.builder(
              padding: EdgeInsets.only(bottom: 150),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: registry.agents.length,
              itemBuilder: (BuildContext context, int i) {
                UserRegistryModel dc = registry.agents[i];
                return tickableusercard(
                    selectedusers: selectedlist,
                    isShowPhonenumber: widget.isShowPhonenumber,
                    onselected: (uid, userMap) {
                      if (selectedlist.contains(uid)) {
                        setState(() {
                          selectedlist.remove(uid);
                          maplist.remove(userMap);
                        });
                      } else {
                        setState(() {
                          selectedlist.add(uid);
                          maplist.add(userMap);
                        });
                      }
                    },
                    doc: dc,
                    context: context,
                    bannedusers: widget.bannedusers ?? [],
                    isCustomer: false,
                    isManager: widget.managerUID == dc.id);
              })
          : widget.usertype == Usertype.customer.index
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 150),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: registry.customer.length,
                  itemBuilder: (BuildContext context, int i) {
                    UserRegistryModel dc = registry.customer[i];
                    return tickableusercard(
                      isShowPhonenumber: widget.isShowPhonenumber,
                      selectedusers: selectedlist,
                      onselected: (uid, map) {
                        if (selectedlist.contains(uid)) {
                          setState(() {
                            selectedlist.remove(uid);
                            maplist.remove(map);
                          });
                        } else {
                          setState(() {
                            selectedlist.add(uid);
                            maplist.add(map);
                          });
                        }
                      },
                      doc: dc,
                      context: context,
                      isCustomer: true,
                      bannedusers: widget.bannedusers ?? [],
                    );
                  })
              : SizedBox(),
    );
  }
}
