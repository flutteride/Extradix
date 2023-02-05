//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketStatus.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/call_utilities.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/open_settings.dart';
import 'package:thinkcreative_technologies/Utils/permissions.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/online_tags.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

ticketAppBarforAgentsUsingRegistry(
    SharedPreferences prefs,
    Observer observer,
    BuildContext context,
    TicketModel liveTicketData,
    Function onPressMenu,
    bool issecretchat,
    String currentUserID,
    Function onBackPress) {
  return AppBar(
    bottom: issecretchat == true
        ? PreferredSize(
            preferredSize: Size.fromHeight(30.0), // here the desired height
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                width: MediaQuery.of(context).size.width,
                color: Mycolors.cyan,
                child: Text(
                  getTranslatedForCurrentUser(context, 'xxnextmessagesxx')
                      .replaceAll('(####)',
                          getTranslatedForCurrentUser(context, 'xxagentsxx')),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Mycolors.white),
                )))
        : liveTicketData.ticketStatus == TicketStatus.needsAttention.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.waitingForAgentsToJoinTicket.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.closedByAgent.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.closedByCustomer.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.mediaAutoDeleted.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.canWeCloseByAgent.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.canWeCloseByCustomer.index
            ? PreferredSize(
                preferredSize: Size.fromHeight(30.0), // here the desired height
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.only(top: 5, bottom: 3),
                  child: MtCustomfontBoldSemi(
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    text: ticketStatusTextLongForAgent(
                        context, liveTicketData.ticketStatus),
                    color: Colors.white,
                    fontsize: 13,
                  ),
                  width: MediaQuery.of(context).size.width,
                  color:
                      ticketStatusColorForAgents(liveTicketData.ticketStatus),
                ))
            : null,
    actions: [
      liveTicketData.ticketCallInfoMap!.isEmpty
          ? SizedBox()
          : observer.userAppSettingsDoc!.isCallAssigningAllowed == false
              ? SizedBox()
              : liveTicketData.ticketStatus == TicketStatus.active.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.needsAttention.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByAgent.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByCustomer.index
                  ? liveTicketData.ticketCallInfoMap![Dbkeys.ticketCallId] ==
                          currentUserID
                      ? IconButton(
                          onPressed: () {
                            showDialOptions(context, prefs, currentUserID,
                                liveTicketData, true);
                          },
                          icon: Icon(
                            Icons.call,
                            color: Mycolors.getColor(
                                prefs, Colortype.primary.index),
                          ))
                      : SizedBox()
                  : SizedBox(),
      IconButton(
          onPressed: () {
            onPressMenu();
          },
          icon: Icon(Icons.more_vert_rounded,
              color: Mycolors.getColor(prefs, Colortype.primary.index)))
    ],
    elevation: 1,
    titleSpacing: -7,
    backgroundColor: Mycolors.whiteDynamic,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
            child: customCircleAvatar(radius: 20, url: '')),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: MtCustomfontBoldSemi(
                overflow: TextOverflow.ellipsis,
                maxlines: 1,
                text: liveTicketData.ticketTitle,
                fontsize: 17,
                color: Mycolors.blackDynamic,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                '${getTranslatedForCurrentUser(context, 'xxticketidxx')} ' +
                    liveTicketData.ticketcosmeticID,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Mycolors.blackDynamic,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ],
    ),
    leading: Container(
      margin: EdgeInsets.only(right: 0),
      width: 10,
      child: IconButton(
        icon: Icon(
          LineAwesomeIcons.arrow_left,
          size: 24,
          color: Mycolors.getColor(prefs, Colortype.primary.index),
        ),
        onPressed: () {
          onBackPress();
          // Navigator.of(context).pop();
        },
      ),
    ),
  );
}

AppBar ticketAppBarforAgentsUsingRealtimeCustomerData(
    SharedPreferences prefs,
    BuildContext context,
    TicketModel liveTicketData,
    CustomerModel liveCustomerData,
    Observer observer,
    Function onPressMenu,
    String currentUserID,
    bool issecretchat,
    Function onBackPress) {
  return AppBar(
    bottom: issecretchat == true
        ? PreferredSize(
            preferredSize: Size.fromHeight(30.0), // here the desired height
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                width: MediaQuery.of(context).size.width,
                color: Mycolors.cyan,
                child: Text(
                  getTranslatedForCurrentUser(context, 'xxnextmessagesxx')
                      .replaceAll('(####)',
                          getTranslatedForCurrentUser(context, 'xxagentsxx')),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Mycolors.white),
                )))
        : liveTicketData.ticketStatus == TicketStatus.needsAttention.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.waitingForAgentsToJoinTicket.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.closedByAgent.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.closedByCustomer.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.mediaAutoDeleted.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.canWeCloseByAgent.index ||
                liveTicketData.ticketStatus ==
                    TicketStatus.canWeCloseByCustomer.index
            ? PreferredSize(
                preferredSize: Size.fromHeight(30.0), // here the desired height
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.only(top: 5, bottom: 3),
                  child: MtCustomfontBoldSemi(
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    text: ticketStatusTextLongForAgent(
                        context, liveTicketData.ticketStatus),
                    color: Colors.white,
                    fontsize: 13,
                  ),
                  width: MediaQuery.of(context).size.width,
                  color:
                      ticketStatusColorForAgents(liveTicketData.ticketStatus),
                ))
            : null,
    actions: [
      liveTicketData.ticketCallInfoMap!.isEmpty
          ? SizedBox()
          : observer.userAppSettingsDoc!.isCallAssigningAllowed == false
              ? SizedBox()
              : liveTicketData.ticketStatus == TicketStatus.active.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.needsAttention.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByAgent.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByCustomer.index
                  ? liveTicketData.ticketCallInfoMap![Dbkeys.ticketCallId] ==
                          currentUserID
                      ? IconButton(
                          onPressed: () {
                            showDialOptions(context, prefs, currentUserID,
                                liveTicketData, true);
                          },
                          icon: Icon(
                            Icons.call,
                            color: Mycolors.getColor(
                                prefs, Colortype.primary.index),
                          ))
                      : SizedBox()
                  : SizedBox(),
      IconButton(
          onPressed: () {
            onPressMenu();
          },
          icon: Icon(Icons.more_vert_rounded,
              color: Mycolors.getColor(prefs, Colortype.primary.index)))
    ],
    elevation: 1,
    titleSpacing: -7,
    backgroundColor: Mycolors.whiteDynamic,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
          child: liveCustomerData.lastSeen == true &&
                  observer.userAppSettingsDoc!.showIsCustomerOnline == true &&
                  liveTicketData.ticketStatusShort == TicketStatus.active.index
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Mycolors.onlinetag.withOpacity(0.7), // border color
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.6), // border width
                    child: Container(
                      padding: EdgeInsets.all(2), // border width
                      // or ClipRRect if you need to clip the content
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // inner circle color
                      ),
                      child: customCircleAvatar(
                          url: liveCustomerData.photoUrl,
                          radius: 18), // inner content
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(4, 5, 4, 4),
                  child: customCircleAvatar(
                      url: liveCustomerData.photoUrl, radius: 20),
                ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 4,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: MtCustomfontBoldSemi(
                maxlines: 1,
                overflow: TextOverflow.ellipsis,
                text: liveTicketData.ticketTitle,
                fontsize: 15,
                color: Mycolors.blackDynamic,
              ),
            ),
            SizedBox(
              height: 4.7,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    iAmSecondAdmin(
                                currentuserid: currentUserID,
                                context: context) ==
                            true
                        ? observer.userAppSettingsDoc!
                                .secondadmincanseecustomernameandphoto!
                            ? liveCustomerData.nickname.toString()
                            : iAmDepartmentManager(
                                        currentuserid: currentUserID,
                                        context: context) ==
                                    true
                                ? observer.userAppSettingsDoc!
                                        .departmentmanagercanseecustomernameandphoto!
                                    ? liveCustomerData.nickname.toString()
                                    : observer.userAppSettingsDoc!
                                            .agentcanseecustomernameandphoto!
                                        ? liveCustomerData.nickname.toString()
                                        : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${liveTicketData.ticketcustomerID}"
                                : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${liveTicketData.ticketcustomerID} "
                        : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${liveTicketData.ticketcustomerID}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Mycolors.blackDynamic,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  liveTicketData.ticketStatusShort ==
                          TicketStatusShort.active.index
                      ? liveCustomerData.lastSeen == true &&
                              observer.userAppSettingsDoc!
                                      .showIsCustomerOnline ==
                                  true
                          ? onlineTagText()
                          : SizedBox()
                      : SizedBox()
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    leading: Container(
      margin: EdgeInsets.only(right: 0),
      width: 10,
      child: IconButton(
        icon: Icon(
          LineAwesomeIcons.arrow_left,
          size: 24,
          color: Mycolors.getColor(prefs, Colortype.primary.index),
        ),
        onPressed: () {
          onBackPress();
          // Navigator.of(context).pop();
        },
      ),
    ),
  );
}

showDialOptions(BuildContext context, SharedPreferences prefs,
    String currentuserid, TicketModel ticketData, bool isCurrentUserisAgent) {
  final observer = Provider.of<Observer>(context, listen: false);
  final userRegistry = Provider.of<UserRegistry>(context, listen: false);
  SpecialLiveConfigData? livedata =
      Provider.of<SpecialLiveConfigData?>(context, listen: false);
  bool isShowNamePhotoToReceiver = false;
  bool isShowNameAndPhotoToDialer = false;
  if (isCurrentUserisAgent) {
    isShowNamePhotoToReceiver = observer.userAppSettingsDoc!
                .customerCanSeeAgentNameInTicketCallScreen! ==
            true ||
        observer.userAppSettingsDoc!.customercanseeagentnameandphoto == true;

    isShowNameAndPhotoToDialer =
        observer.userAppSettingsDoc!.agentcanseecustomernameandphoto! == true ||
            (iAmSecondAdmin(
                        specialLiveConfigData: livedata,
                        currentuserid:
                            ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .secondadmincanseecustomernameandphoto ==
                    true) ||
            (iAmDepartmentManager(
                        currentuserid:
                            ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .departmentmanagercanseecustomernameandphoto ==
                    true);
  } else {
    isShowNamePhotoToReceiver =
        observer.userAppSettingsDoc!.agentcanseecustomernameandphoto! == true ||
            (iAmSecondAdmin(
                        specialLiveConfigData: livedata,
                        currentuserid:
                            ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .secondadmincanseecustomernameandphoto ==
                    true) ||
            (iAmDepartmentManager(
                        currentuserid:
                            ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .departmentmanagercanseecustomernameandphoto ==
                    true);
    isShowNameAndPhotoToDialer = observer.userAppSettingsDoc!
                .customerCanSeeAgentNameInTicketCallScreen! ==
            true ||
        observer.userAppSettingsDoc!.customercanseeagentnameandphoto == true;
  }

  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext contextt) {
        // return your layout
        return Consumer<Observer>(
            builder: (contextt, observer, _child) => Container(
                padding: EdgeInsets.all(12),
                height: 130,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      observer.userAppSettingsDoc!.callTypeForTicketChatRoom ==
                                  CallType.audio.index ||
                              observer.userAppSettingsDoc!
                                      .callTypeForTicketChatRoom ==
                                  CallType.both.index
                          ? InkWell(
                              onTap: observer.checkIfCurrentUserIsDemo(
                                          currentuserid) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      await Permissions
                                              .cameraAndMicrophonePermissionsGranted()
                                          .then((isgranted) {
                                        if (isgranted == true) {
                                          Navigator.of(contextt).pop();
                                          var mynickname = prefs
                                                  .getString(Dbkeys.nickname) ??
                                              '';

                                          var myphotoUrl = prefs
                                                  .getString(Dbkeys.photoUrl) ??
                                              '';
                                          CallUtils.dial(
                                              ticketCustomerID:
                                                  ticketData.ticketcustomerID,
                                              ticketidfiltered:
                                                  ticketData.ticketidFiltered,
                                              tickettitle:
                                                  ticketData.ticketTitle,
                                              callSessionID: DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              callSessionInitatedBy:
                                                  currentuserid,
                                              ticketID: ticketData.ticketID,
                                              callTypeindex: isCurrentUserisAgent
                                                  ? CallTypeIndex
                                                      .callToCustomerFromAgentInTICKET
                                                      .index
                                                  : CallTypeIndex
                                                      .callToAgentFromCustomerInTICKET
                                                      .index,
                                              isShowCallernameAndPhotoToDialler:
                                                  isShowNameAndPhotoToDialer,
                                              isShowCallernameAndPhotoToReciever:
                                                  isShowNamePhotoToReceiver,
                                              prefs: prefs,
                                              currentUserID: currentuserid,
                                              fromDp: myphotoUrl,
                                              toDp: isCurrentUserisAgent
                                                  ? userRegistry
                                                      .getUserData(
                                                          context,
                                                          ticketData
                                                              .ticketcustomerID)
                                                      .photourl
                                                  : userRegistry
                                                      .getUserData(
                                                          context,
                                                          ticketData.ticketCallInfoMap![
                                                              Dbkeys.ticketCallId])
                                                      .photourl,
                                              fromUID: currentuserid,
                                              fromFullname: mynickname,
                                              toUID: isCurrentUserisAgent ? ticketData.ticketcustomerID : ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                                              toFullname: isCurrentUserisAgent ? userRegistry.getUserData(context, ticketData.ticketcustomerID).fullname : userRegistry.getUserData(context, ticketData.ticketCallInfoMap![Dbkeys.ticketCallId]).fullname,
                                              context: context,
                                              isvideocall: false);
                                        } else {
                                          Navigator.of(contextt).pop();
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  contextt, 'xxpmcxx'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings()));
                                        }
                                      }).catchError((onError) {
                                        Utils.showRationale(
                                            getTranslatedForCurrentUser(
                                                contextt, 'xxpmcxx'));
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    OpenSettings()));
                                      });
                                    },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 13),
                                    Icon(
                                      Icons.local_phone,
                                      size: 35,
                                      color: Mycolors.agentSecondary,
                                    ),
                                    SizedBox(height: 13),
                                    Text(
                                      getTranslatedForCurrentUser(
                                          context, 'xxaudiocallxx'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: Mycolors.blackDynamic),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      observer.userAppSettingsDoc!.callTypeForTicketChatRoom ==
                                  CallType.video.index ||
                              observer.userAppSettingsDoc!
                                      .callTypeForTicketChatRoom ==
                                  CallType.both.index
                          ? InkWell(
                              onTap: observer.checkIfCurrentUserIsDemo(
                                          currentuserid) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      await Permissions
                                              .cameraAndMicrophonePermissionsGranted()
                                          .then((isgranted) {
                                        if (isgranted == true) {
                                          Navigator.of(contextt).pop();
                                          var mynickname = prefs
                                                  .getString(Dbkeys.nickname) ??
                                              '';

                                          var myphotoUrl = prefs
                                                  .getString(Dbkeys.photoUrl) ??
                                              '';
                                          CallUtils.dial(
                                              ticketCustomerID:
                                                  ticketData.ticketcustomerID,
                                              ticketidfiltered:
                                                  ticketData.ticketidFiltered,
                                              tickettitle:
                                                  ticketData.ticketTitle,
                                              callSessionID: DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              callSessionInitatedBy:
                                                  currentuserid,
                                              ticketID: ticketData.ticketID,
                                              callTypeindex: isCurrentUserisAgent
                                                  ? CallTypeIndex
                                                      .callToCustomerFromAgentInTICKET
                                                      .index
                                                  : CallTypeIndex
                                                      .callToAgentFromCustomerInTICKET
                                                      .index,
                                              isShowCallernameAndPhotoToDialler:
                                                  isShowNameAndPhotoToDialer,
                                              isShowCallernameAndPhotoToReciever:
                                                  isShowNamePhotoToReceiver,
                                              prefs: prefs,
                                              currentUserID: currentuserid,
                                              fromDp: myphotoUrl,
                                              toDp: isCurrentUserisAgent
                                                  ? userRegistry
                                                      .getUserData(
                                                          context,
                                                          ticketData
                                                              .ticketcustomerID)
                                                      .photourl
                                                  : userRegistry
                                                      .getUserData(
                                                          context,
                                                          ticketData.ticketCallInfoMap![
                                                              Dbkeys.ticketCallId])
                                                      .photourl,
                                              fromUID: currentuserid,
                                              fromFullname: mynickname,
                                              toUID: isCurrentUserisAgent ? ticketData.ticketcustomerID : ticketData.ticketCallInfoMap![Dbkeys.ticketCallId],
                                              toFullname: isCurrentUserisAgent ? userRegistry.getUserData(context, ticketData.ticketcustomerID).fullname : userRegistry.getUserData(context, ticketData.ticketCallInfoMap![Dbkeys.ticketCallId]).fullname,
                                              context: context,
                                              isvideocall: true);
                                        } else {
                                          Navigator.of(contextt).pop();
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  contextt, 'xxpmcxx'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings()));
                                        }
                                      }).catchError((onError) {
                                        Utils.showRationale(
                                            getTranslatedForCurrentUser(
                                                contextt, 'xxpmcxx'));
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    OpenSettings()));
                                      });
                                    },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 13),
                                    Icon(
                                      Icons.videocam,
                                      size: 39,
                                      color: Mycolors.agentSecondary,
                                    ),
                                    SizedBox(height: 13),
                                    Text(
                                      getTranslatedForCurrentUser(
                                          context, 'xxvideocallxx'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: Mycolors.black),
                                    ),
                                  ],
                                ),
                              ))
                          : SizedBox()
                    ])));
      });
}

AppBar ticketAppBarforCustomers(
    SharedPreferences prefs,
    BuildContext context,
    TicketModel liveTicketData,
    Function onPressMenu,
    Observer observer,
    String currentUserID,
    Function onBackPress) {
  return AppBar(
    bottom: PreferredSize(
        preferredSize: Size.fromHeight(30.0), // here the desired height
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(top: 5, bottom: 3),
          child: MtCustomfontBoldSemi(
            textalign: TextAlign.center,
            text: ticketStatusTextLongForCustomer(
                context, liveTicketData.ticketStatus),
            color: Colors.white,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
            fontsize: 13,
          ),
          width: MediaQuery.of(context).size.width,
          color: ticketStatusColorForCustomers(liveTicketData.ticketStatus),
        )),
    actions: [
      liveTicketData.ticketCallInfoMap!.isEmpty
          ? SizedBox()
          : observer.userAppSettingsDoc!.isCallAssigningAllowed == true
              ? liveTicketData.ticketStatus == TicketStatus.active.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.needsAttention.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByAgent.index ||
                      liveTicketData.ticketStatus ==
                          TicketStatus.reOpenedByCustomer.index
                  ? IconButton(
                      onPressed: () {
                        showDialOptions(context, prefs, currentUserID,
                            liveTicketData, false);
                      },
                      icon: Icon(
                        Icons.call,
                        color:
                            Mycolors.getColor(prefs, Colortype.primary.index),
                      ))
                  : SizedBox()
              : SizedBox(),
      IconButton(
          onPressed: () {
            onPressMenu();
          },
          icon: Icon(Icons.more_vert_rounded,
              color: Mycolors.getColor(prefs, Colortype.primary.index)))
    ],
    elevation: 1,
    titleSpacing: -7,
    backgroundColor: Mycolors.whiteDynamic,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
        //     child: customCircleAvatar(radius: 20, url: '')),
        // SizedBox(
        //   width: 10,
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 4,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: MtCustomfontBoldSemi(
                maxlines: 1,
                overflow: TextOverflow.ellipsis,
                text: liveTicketData.ticketTitle,
                fontsize: 17,
                color: Mycolors.blackDynamic,
              ),
            ),
            SizedBox(
              height: 4.7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${getTranslatedForCurrentUser(context, 'xxticketidxx')} ' +
                      liveTicketData.ticketcosmeticID,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Mycolors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 17,
                ),
                liveTicketData.ticketStatusShort ==
                        TicketStatusShort.active.index
                    ? observer.userAppSettingsDoc!.showIsAgentOnline!
                        ? liveTicketData.liveAgentID == "" ||
                                liveTicketData.liveAgentLastonline == 0
                            ? SizedBox()
                            : DateTime.now()
                                        .difference(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                liveTicketData
                                                    .liveAgentLastonline!))
                                        .inMinutes >
                                    Numberlimits.maxOnlineDurationShowForAgent
                                ? SizedBox()
                                : streamLoad(
                                    stream: FirebaseFirestore.instance
                                        .collection(DbPaths.collectionagents)
                                        .doc(liveTicketData.liveAgentID)
                                        .snapshots(),
                                    placeholder: SizedBox(),
                                    onfetchdone: (m) {
                                      if (m[Dbkeys.lastSeen] == true) {
                                        return onlineTagText(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            text: observer.userAppSettingsDoc!
                                                    .customercanseeagentnameandphoto!
                                                ? "${getTranslatedForCurrentUser(context, 'xxisonlinexx').replaceAll('(####)', m[Dbkeys.nickname])}"
                                                : "${getTranslatedForCurrentUser(context, 'xxisonlinexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentxx'))}");
                                      }
                                    })
                        : SizedBox()
                    : SizedBox()
              ],
            ),
          ],
        ),
      ],
    ),
    leading: Container(
      margin: EdgeInsets.only(right: 0),
      width: 10,
      child: IconButton(
        icon: Icon(
          LineAwesomeIcons.arrow_left,
          size: 24,
          color: Mycolors.getColor(prefs, Colortype.primary.index),
        ),
        onPressed: () {
          onBackPress();
          // Navigator.of(context).pop();
        },
      ),
    ),
  );
}
