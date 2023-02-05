//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Utils/Setupdata.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/widgets/CustomCards/customcards.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllUsers extends StatefulWidget {
  AllUsers(
      {required this.currentUserID,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.fullname,
      required this.isShowAgentstab,
      required this.isShowCustomerstab,
      required this.photourl,
      key})
      : super(key: key);
  final String? currentUserID;
  final String fullname;
  final bool isShowAgentstab;
  final bool isShowCustomerstab;
  final String photourl;

  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new AllUsersState();
}

class AllUsersState extends State<AllUsers> with TickerProviderStateMixin {
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = [];
  List<StreamController> controllers = [];

  late TabController tabController;
  @override
  void initState() {
    super.initState();

    tabController = TabController(
      initialIndex: 0,
      length:
          widget.isShowAgentstab == true && widget.isShowCustomerstab == true
              ? 2
              : 1,
      vsync: this,
    );

    Utils.internetLookUp();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  bool isloading = true;
  List<dynamic> ticketDocList = [];

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  bool showHidden = false, biometricEnabled = false;

  bool isLoading = false;

  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(context, _locale);
    if (widget.currentUserID != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(widget.currentUserID)
            .update({
          Dbkeys.notificationStringsMap:
              getTranslateNotificationStringsMap(this.context),
        });
      });
    }
    setState(() {
      // seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  Widget buildAgentList(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);
    return registry.agents.length == 0
        ? noDataWidget(
            context: context,
            title:
                getTranslatedForCurrentUser(context, 'xxnoxxavailabletoaddxx')
                    .replaceAll('(####)',
                        getTranslatedForCurrentUser(context, 'xxagentsxx')),
            subtitle: getTranslatedForCurrentUser(context, 'xxnoxxjoinedyetxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(context, 'xxagentsxx')),
          )
        : ListView.builder(
            itemCount: registry.agents.length,
            itemBuilder: (BuildContext context, int i) {
              UserRegistryModel agent = registry.agents.reversed.toList()[i];
              return futureLoad(
                  future: FirebaseFirestore.instance
                      .collection(DbPaths.collectionagents)
                      .doc(agent.id)
                      .get(),
                  placeholder: RegistryUserCard(
                      usermodel: agent, currentuserid: widget.currentUserID!),
                  onfetchdone: (agentDoc) {
                    return AgentCard(
                        isswitchshow: false,
                        usermodel: AgentModel.fromJson(agentDoc),
                        currentuserid: widget.currentUserID!,
                        isProfileFetchedFromProvider: false);
                  });
            });
  }

  Widget buildCustomerList(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);
    return registry.customer.length == 0
        ? noDataWidget(
            context: context,
            title:
                getTranslatedForCurrentUser(context, 'xxnoxxavailabletoaddxx')
                    .replaceAll('(####)',
                        getTranslatedForCurrentUser(context, 'xxcustomersxx')),
            subtitle: getTranslatedForCurrentUser(context, 'xxnoxxjoinedyetxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(context, 'xxcustomersxx')))
        : ListView.builder(
            itemCount: registry.customer.length,
            itemBuilder: (BuildContext context, int i) {
              UserRegistryModel customer =
                  registry.customer.reversed.toList()[i];
              return futureLoad(
                  future: FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .doc(customer.id)
                      .get(),
                  placeholder: RegistryUserCard(
                      usermodel: customer,
                      currentuserid: widget.currentUserID!),
                  onfetchdone: (customerDoc) {
                    return CustomerCard(
                        isswitchshow: false,
                        usermodel: CustomerModel.fromJson(customerDoc),
                        currentuserid: widget.currentUserID!,
                        isProfileFetchedFromProvider: false);
                  });
            });
  }

  @override
  Widget build(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Utils.getNTPWrappedWidget(DefaultTabController(
      length: 2,
      child: widget.isShowAgentstab == false &&
              widget.isShowCustomerstab == false
          ? MyScaffold(
              title: "Users",
              isforcehideback: true,
              body: noDataWidget(
                context: context,
                subtitle: getTranslatedForCurrentUser(
                        context, 'xxnoxxavailabletoaddxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForCurrentUser(context, 'xxagentsxx') +
                            " / " +
                            getTranslatedForCurrentUser(
                                context, 'xxcustomersxx')),
                title: getTranslatedForCurrentUser(context, 'xxusersxx'),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                bottom: PreferredSize(
                    preferredSize: new Size(30.0, 50.0),
                    child: new Container(
                      width: MediaQuery.of(context).size.width / 1.0,
                      child: new TabBar(
                        controller: tabController,
                        indicatorWeight: 1.2,
                        unselectedLabelColor: Mycolors.grey,
                        labelColor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        indicatorColor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        tabs: widget.isShowAgentstab == true &&
                                widget.isShowCustomerstab == true
                            ? [
                                new Tab(
                                    icon: MtCustomfontBold(
                                  isNullColor: true,
                                  text: registry.agents.length == 0
                                      ? getTranslatedForCurrentUser(
                                          context, 'xxagentsxx')
                                      : '${registry.agents.length} ${getTranslatedForCurrentUser(context, 'xxagentsxx')}',
                                  fontsize: 13,
                                  // color: Mycolors.getColor(
                                  //     widget.prefs, Colortype.primary.index),
                                )),
                                new Tab(
                                    icon: MtCustomfontBold(
                                  isNullColor: true,
                                  text: registry.customer.length == 0
                                      ? getTranslatedForCurrentUser(
                                          context, 'xxcustomersxx')
                                      : '${registry.customer.length} ${getTranslatedForCurrentUser(context, 'xxcustomersxx')}',
                                  fontsize: 13,
                                  // color: Mycolors.getColor(
                                  //     widget.prefs, Colortype.primary.index),
                                )),
                              ]
                            : [
                                widget.isShowAgentstab
                                    ? new Tab(
                                        icon: MtCustomfontBold(
                                        isNullColor: true,
                                        text: registry.agents.length == 0
                                            ? getTranslatedForCurrentUser(
                                                context, 'xxagentsxx')
                                            : '${registry.agents.length} ${getTranslatedForCurrentUser(context, 'xxagentsxx')}',
                                        fontsize: 13,
                                        // color: Mycolors.getColor(
                                        //     widget.prefs, Colortype.primary.index),
                                      ))
                                    : new Tab(
                                        icon: MtCustomfontBold(
                                        isNullColor: true,
                                        text: registry.customer.length == 0
                                            ? getTranslatedForCurrentUser(
                                                context, 'xxcustomersxx')
                                            : '${registry.customer.length} ${getTranslatedForCurrentUser(context, 'xxcustomersxx')}',
                                        fontsize: 13,
                                        // color: Mycolors.getColor(
                                        //     widget.prefs, Colortype.primary.index),
                                      ))
                              ],
                      ),
                    )),
                elevation: 0.4,
                backgroundColor: Mycolors.whiteDynamic,
                title: MtCustomfontBold(
                  text: getTranslatedForCurrentUser(context, 'xxusersxx'),
                  color: Mycolors.blackDynamic,
                  textalign: TextAlign.center,
                  fontsize: 18,
                ),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    10,
                    10,
                    10,
                  ),
                  child: customCircleAvatar(
                      url: widget.prefs.getString(Dbkeys.photoUrl) ??
                          'photo not found',
                      radius: 20),
                ),
                titleSpacing: -1,
                actions: <Widget>[],
              ),
              backgroundColor: Mycolors.backgroundcolor,
              body: TabBarView(
                  controller: tabController,
                  children: widget.isShowAgentstab == true &&
                          widget.isShowCustomerstab == true
                      ? [buildAgentList(context), buildCustomerList(context)]
                      : [
                          widget.isShowAgentstab == true
                              ? buildAgentList(context)
                              : buildCustomerList(context)
                        ]),
            ),
    ));
  }
}
