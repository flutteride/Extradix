//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_message.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Services/Providers/user_registry_provider.dart';

class TicketUtils {
  static bool isTimeOverToReopen(
      {required int closedOn, required BuildContext context}) {
    var observer = Provider.of<Observer>(context, listen: false);
    return DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(closedOn))
                .inDays >
            observer.userAppSettingsDoc!.reopenTicketTillDays!
        ? true
        : false;
  }

  static closeTicket(
      {required String ticketID,
      required BuildContext context,
      required bool isCustomer,
      SharedPreferences? prefs,
      required String currentUserID,
      required TicketModel liveTicketModel,
      required List<dynamic> agents}) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    var observer = Provider.of<Observer>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.ticketClosedOn: DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketlatestTimestampForAgents:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketlatestTimestampForCustomer:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketclosedby: currentUserID,
      Dbkeys.ticketStatus: isCustomer == true
          ? TicketStatus.closedByCustomer.index
          : TicketStatus.closedByAgent.index,
      Dbkeys.ticketStatusShort: TicketStatusShort.close.index,
    });
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .collection(DbPaths.collectionticketChats)
        .doc(timestamp.toString() + '--' + currentUserID)
        .set(
            TicketMessage(
              tktMssgCONTENT:
                  getTranslatedForEventsAndAlerts(context, 'xxclosedxxxx')
                      .replaceAll('(####)',
                          getTranslatedForEventsAndAlerts(context, 'xxtktsxx')),
              tktMssgISDELETED: false,
              tktMssgTIME: DateTime.now().millisecondsSinceEpoch,
              tktMssgSENDBY: currentUserID,
              tktMssgTYPE: MessageType.rROBOTticketclosed.index,
              tktMssgSENDERNAME:
                  registry.getUserData(context, currentUserID).fullname,
              tktMssgISREPLY: false,
              tktMssgISFORWARD: false,
              tktMssgREPLYTOMSSGDOC: {},
              tktMssgTicketName: liveTicketModel.ticketTitle,
              tktMssgTicketIDflitered: liveTicketModel.ticketidFiltered,
              tktMssgSENDFOR: isCustomer
                  ? [
                      // MssgSendFor.agent.index,
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ]
                  : [
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ],
              tktMsgSenderIndex:
                  isCustomer ? Usertype.customer.index : Usertype.agent.index,
              tktMsgInt2: 0,
              isShowSenderNameInNotification: true,
              tktMsgBool2: true,
              notificationActiveList:
                  observer.userAppSettingsDoc!.departmentBasedContent == true
                      ? [
                          liveTicketModel.ticketDepartmentID,
                        ]
                      : agents,
              tktMssgLISToptional: [],
              tktMsgList2: [],
              tktMsgList3: [],
              tktMsgMap1: {},
              tktMsgMap2: {},
              tktMsgDELETEREASON: '',
              tktMsgDELETEDby: '',
              tktMsgString4: '',
              tktMsgString5: '',
              ttktMsgString3: '',
              tktMsgCUSTOMERID: liveTicketModel.ticketcustomerID,
            ).toMap(),
            SetOptions(merge: true));

    FirebaseApi.runTransactionRecordActivity(
        parentid: "TICKET--$ticketID",
        title: "Ticket Closed",
        postedbyID: currentUserID,
        onErrorFn: (e) {},
        onSuccessFn: () {},
        plainDesc: isCustomer
            ? "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) is closed by Customer"
            : "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) is closed by Agent ID: $currentUserID",
        styledDesc: isCustomer
            ? "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID) is <bold>Closed</bold> by Customer ID: $currentUserID"
            : "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID) is <bold>Closed</bold> by Agent ID: $currentUserID");
  }

  static askToClose(
      {required String ticketID,
      required BuildContext context,
      required bool isCustomer,
      SharedPreferences? prefs,
      required String currentUserID,
      required TicketModel liveTicketModel,
      required List<dynamic> agents}) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    var observer = Provider.of<Observer>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.ticketlatestTimestampForCustomer:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketStatus: isCustomer == true
          ? TicketStatus.canWeCloseByCustomer.index
          : TicketStatus.canWeCloseByAgent.index,
      Dbkeys.ticketStatusShort: TicketStatusShort.active.index,
    });
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .collection(DbPaths.collectionticketChats)
        .doc(timestamp.toString() + '--' + currentUserID)
        .set(
            TicketMessage(
              tktMssgCONTENT: getTranslatedForEventsAndAlerts(
                      context, 'xxrequestedtoclosexx')
                  .replaceAll('(####)',
                      getTranslatedForEventsAndAlerts(context, 'xxtktsxx')),
              tktMssgISDELETED: false,
              tktMssgTIME: DateTime.now().millisecondsSinceEpoch,
              tktMssgSENDBY: currentUserID,
              tktMssgTYPE: MessageType.rROBOTrequestedtoclose.index,
              tktMssgSENDERNAME:
                  registry.getUserData(context, currentUserID).fullname,
              tktMssgISREPLY: false,
              tktMssgISFORWARD: false,
              tktMssgREPLYTOMSSGDOC: {},
              tktMssgTicketName: liveTicketModel.ticketTitle,
              tktMssgTicketIDflitered: liveTicketModel.ticketidFiltered,
              tktMssgSENDFOR: isCustomer
                  ? [
                      // MssgSendFor.agent.index,
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ]
                  : [
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ],
              tktMsgSenderIndex:
                  isCustomer ? Usertype.customer.index : Usertype.agent.index,
              tktMsgInt2: 0,
              isShowSenderNameInNotification: true,
              tktMsgBool2: true,
              notificationActiveList:
                  observer.userAppSettingsDoc!.departmentBasedContent == true
                      ? [
                          liveTicketModel.ticketDepartmentID,
                        ]
                      : agents,
              tktMssgLISToptional: [],
              tktMsgList2: [],
              tktMsgList3: [],
              tktMsgMap1: {},
              tktMsgMap2: {},
              tktMsgDELETEREASON: '',
              tktMsgDELETEDby: '',
              tktMsgString4: '',
              tktMsgString5: '',
              ttktMsgString3: '',
              tktMsgCUSTOMERID: liveTicketModel.ticketcustomerID,
            ).toMap(),
            SetOptions(merge: true));

    FirebaseApi.runTransactionRecordActivity(
        parentid: "TICKET--$ticketID",
        title: "Ticket Closing request",
        postedbyID: currentUserID,
        onErrorFn: (e) {},
        onSuccessFn: () {},
        plainDesc: isCustomer
            ? "Customer ID: $currentUserID requested Agents to Close the Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)"
            : "Agent ID: $currentUserID requested Customer to Close the Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)",
        styledDesc: isCustomer
            ? "Customer ID: $currentUserID requested Agents to Close the Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)"
            : "Agent ID: $currentUserID requested Customer to Close the Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)");
  }

  static reopenTicket(
      {required String ticketID,
      required BuildContext context,
      SharedPreferences? prefs,
      required bool isCustomer,
      required String currentUserID,
      required TicketModel liveTicketModel,
      required List<dynamic> agents}) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    var observer = Provider.of<Observer>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.ticketlatestTimestampForAgents:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketlatestTimestampForCustomer:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketStatus: isCustomer
          ? TicketStatus.reOpenedByCustomer.index
          : TicketStatus.reOpenedByAgent.index,
      Dbkeys.ticketStatusShort: TicketStatusShort.active.index,
    });
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .collection(DbPaths.collectionticketChats)
        .doc(timestamp.toString() + '--' + currentUserID)
        .set(
            TicketMessage(
              tktMssgCONTENT:
                  getTranslatedForEventsAndAlerts(context, 'xxreopenedxxxx')
                      .replaceAll('(####)',
                          getTranslatedForEventsAndAlerts(context, 'xxtktsxx')),
              tktMssgISDELETED: false,
              tktMssgTIME: DateTime.now().millisecondsSinceEpoch,
              tktMssgSENDBY: currentUserID,
              tktMssgTYPE: MessageType.rROBOTticketreopened.index,
              tktMssgSENDERNAME:
                  registry.getUserData(context, currentUserID).fullname,
              tktMssgISREPLY: false,
              tktMssgISFORWARD: false,
              tktMssgREPLYTOMSSGDOC: {},
              tktMssgTicketName: liveTicketModel.ticketTitle,
              tktMssgTicketIDflitered: liveTicketModel.ticketidFiltered,
              tktMssgSENDFOR: isCustomer
                  ? [
                      // MssgSendFor.agent.index,
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ]
                  : [
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ],
              tktMsgSenderIndex:
                  isCustomer ? Usertype.customer.index : Usertype.agent.index,
              tktMsgInt2: 0,
              isShowSenderNameInNotification: true,
              tktMsgBool2: true,
              notificationActiveList:
                  observer.userAppSettingsDoc!.departmentBasedContent == true
                      ? [
                          liveTicketModel.ticketDepartmentID,
                        ]
                      : agents,
              tktMssgLISToptional: [],
              tktMsgList2: [],
              tktMsgList3: [],
              tktMsgMap1: {},
              tktMsgMap2: {},
              tktMsgDELETEREASON: '',
              tktMsgDELETEDby: '',
              tktMsgString4: '',
              tktMsgString5: '',
              ttktMsgString3: '',
              tktMsgCUSTOMERID: liveTicketModel.ticketcustomerID,
            ).toMap(),
            SetOptions(merge: true));

    FirebaseApi.runTransactionRecordActivity(
      parentid: "TICKET--$ticketID",
      title: "Ticket Re-Opened",
      postedbyID: currentUserID,
      onErrorFn: (e) {},
      onSuccessFn: () {},
      plainDesc: isCustomer
          ? "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) is re-opened by Customer ID: $currentUserID after ${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(liveTicketModel.ticketClosedOn!)).inDays} Days"
          : "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) is re-opened by Agent ID: $currentUserID after ${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(liveTicketModel.ticketClosedOn!)).inDays} Days",
      styledDesc: isCustomer
          ? "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID) is <bold>Re-Opened</bold> by Customer ID: $currentUserID after <bold>${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(liveTicketModel.ticketClosedOn!)).inDays}</bold> Days"
          : "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID) is <bold>Re-Opened</bold> by Agent ID: $currentUserID after <bold>${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(liveTicketModel.ticketClosedOn!)).inDays}</bold> Days",
    );
  }

  static markNeedsAttention(
      {required String ticketID,
      required String attentionResaon,
      required BuildContext context,
      SharedPreferences? prefs,
      required String currentUserID,
      required TicketModel liveTicketModel,
      required List<dynamic> agents}) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    var observer = Provider.of<Observer>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.ticketlatestTimestampForAgents:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketStatus: TicketStatus.needsAttention.index,
      Dbkeys.ticketStatusShort: TicketStatusShort.active.index,
    });
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .collection(DbPaths.collectionticketChats)
        .doc(timestamp.toString() + '--' + currentUserID)
        .set(
            TicketMessage(
              tktMssgCONTENT: "$attentionResaon",
              tktMssgISDELETED: false,
              tktMssgTIME: DateTime.now().millisecondsSinceEpoch,
              tktMssgSENDBY: currentUserID,
              tktMssgTYPE: MessageType.rROBOTrequireattention.index,
              tktMssgSENDERNAME:
                  registry.getUserData(context, currentUserID).fullname,
              tktMssgISREPLY: false,
              tktMssgISFORWARD: false,
              tktMssgREPLYTOMSSGDOC: {},
              tktMssgTicketName: liveTicketModel.ticketTitle,
              tktMssgTicketIDflitered: liveTicketModel.ticketidFiltered,
              tktMssgSENDFOR: [
                MssgSendFor.agent.index,
              ],
              tktMsgSenderIndex: Usertype.agent.index,
              tktMsgInt2: 0,
              isShowSenderNameInNotification: true,
              tktMsgBool2: true,
              notificationActiveList:
                  observer.userAppSettingsDoc!.departmentBasedContent == true
                      ? [
                          liveTicketModel.ticketDepartmentID,
                        ]
                      : agents,
              tktMssgLISToptional: [],
              tktMsgList2: [],
              tktMsgList3: [],
              tktMsgMap1: {},
              tktMsgMap2: {},
              tktMsgDELETEREASON: '',
              tktMsgDELETEDby: '',
              tktMsgString4: '',
              tktMsgString5: '',
              ttktMsgString3: '',
              tktMsgCUSTOMERID: liveTicketModel.ticketcustomerID,
            ).toMap(),
            SetOptions(merge: true));

    FirebaseApi.runTransactionRecordActivity(
      parentid: "TICKET--$ticketID",
      title: "Ticket Requires Attention",
      postedbyID: currentUserID,
      onErrorFn: (e) {},
      onSuccessFn: () {},
      plainDesc:
          "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) is marked as Requires Attention Agent ID: $currentUserID.",
      styledDesc:
          "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID) is marked as <bold>Requires Attention</bold> by Agent ID: $currentUserID. \n\n<bold>REASON:</bold>\n $attentionResaon",
    );
  }

  static markNeedsAttentionOFF(
      {required String ticketID,
      required String attentionResaon,
      required BuildContext context,
      SharedPreferences? prefs,
      required String currentUserID,
      required TicketModel liveTicketModel,
      required List<dynamic> agents}) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    var observer = Provider.of<Observer>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.ticketlatestTimestampForAgents:
          DateTime.now().millisecondsSinceEpoch,
      Dbkeys.ticketStatus: TicketStatus.active.index,
      Dbkeys.ticketStatusShort: TicketStatusShort.active.index,
    });
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .collection(DbPaths.collectionticketChats)
        .doc(timestamp.toString() + '--' + currentUserID)
        .set(
            TicketMessage(
              tktMssgCONTENT: getTranslatedForEventsAndAlerts(
                  context, 'xxattentionremovexx'),
              tktMssgISDELETED: false,
              tktMssgTIME: DateTime.now().millisecondsSinceEpoch,
              tktMssgSENDBY: currentUserID,
              tktMssgTYPE: MessageType.rROBOTremovettention.index,
              tktMssgSENDERNAME:
                  registry.getUserData(context, currentUserID).fullname,
              tktMssgISREPLY: false,
              tktMssgISFORWARD: false,
              tktMssgREPLYTOMSSGDOC: {},
              tktMssgTicketName: liveTicketModel.ticketTitle,
              tktMssgTicketIDflitered: liveTicketModel.ticketidFiltered,
              tktMssgSENDFOR: [
                MssgSendFor.agent.index,
              ],
              tktMsgSenderIndex: Usertype.agent.index,
              tktMsgInt2: 0,
              isShowSenderNameInNotification: true,
              tktMsgBool2: true,
              notificationActiveList:
                  observer.userAppSettingsDoc!.departmentBasedContent == true
                      ? [
                          liveTicketModel.ticketDepartmentID,
                        ]
                      : agents,
              tktMssgLISToptional: [],
              tktMsgList2: [],
              tktMsgList3: [],
              tktMsgMap1: {},
              tktMsgMap2: {},
              tktMsgDELETEREASON: '',
              tktMsgDELETEDby: '',
              tktMsgString4: '',
              tktMsgString5: '',
              ttktMsgString3: '',
              tktMsgCUSTOMERID: liveTicketModel.ticketcustomerID,
            ).toMap(),
            SetOptions(merge: true));

    FirebaseApi.runTransactionRecordActivity(
      parentid: "TICKET--$ticketID",
      title: "Ticket Attention Mark Removed",
      postedbyID: currentUserID,
      onErrorFn: (e) {},
      onSuccessFn: () {},
      plainDesc:
          "Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID) attention mark is removed by Agent ID: $currentUserID.",
      styledDesc:
          "Ticket <bold>${liveTicketModel.ticketTitle}</bold> (ID: $ticketID)  <bold>attention mark </bold> is <bold>removed</bold> by Agent ID: $currentUserID.",
    );
  }

  static bool isReopenAllowedForUserType(
      BuildContext context, int closedOn, int usertype) {
    var observer = Provider.of<Observer>(context, listen: false);
    bool isallowednow = DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(closedOn))
                .inDays >
            observer.userAppSettingsDoc!.reopenTicketTillDays!
        ? false
        : true;
    if (usertype == Usertype.agent.index) {
      if (observer.userAppSettingsDoc!.agentCanReopenTicket! &&
          isallowednow == true) {
        return true;
      } else {
        return false;
      }
    } else if (usertype == Usertype.customer.index) {
      if (observer.userAppSettingsDoc!.customerCanReopenTicket! &&
          isallowednow == true) {
        return true;
      } else {
        return false;
      }
    } else if (usertype == Usertype.departmentmanager.index) {
      if (observer.userAppSettingsDoc!.departmentManagerCanReopenTicket! &&
          isallowednow == true) {
        return true;
      } else {
        return false;
      }
    } else if (usertype == Usertype.secondadmin.index) {
      if (observer.userAppSettingsDoc!.secondadminCanReopenTicket! &&
          isallowednow == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static int totalReopenDays(BuildContext context) {
    var observer = Provider.of<Observer>(context, listen: false);

    return observer.userAppSettingsDoc!.reopenTicketTillDays!;
  }

  static int totalDeletingdays(BuildContext context) {
    var observer = Provider.of<Observer>(context, listen: false);

    return observer
        .userAppSettingsDoc!.defaultTicketMssgsDeletingTimeAfterClosing!;
  }

  static submitRating(
      {required String ticketID,
      required String feedback,
      required int rating,
      required String customeruid,
      List<dynamic>? agents = const [],
      String? departmentName = ""}) async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID)
        .update({
      Dbkeys.rating: rating,
      Dbkeys.feedback: feedback,
    });
    if (departmentName != null) {
      await FirebaseApi.runUPDATEmapobjectinListField(
          docrefdata: FirebaseFirestore.instance
              .collection(DbPaths.userapp)
              .doc(DbPaths.appsettings),
          compareKey: Dbkeys.departmentTitle,
          compareVal: departmentName,
          onErrorFn: (e) {},
          isshowloader: false,
          onSuccessFn: () {},
          replaceableMapObjectWithOnlyFieldsRequired: {
            Dbkeys.departmentRatingsList: FieldValue.arrayUnion([
              {Dbkeys.rating: rating, Dbkeys.ticketID: ticketID}
            ])
          },
          listkeyname: Dbkeys.departmentList);
    }
    if (agents != null) {
      agents.forEach((agent) async {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(agent)
            .update({
          Dbkeys.ratings: FieldValue.arrayUnion([
            {Dbkeys.rating: rating, Dbkeys.ticketID: ticketID}
          ])
        });
      });
    }

    await FirebaseApi.runTransactionRecordActivity(
        parentid: "TICKET--$ticketID",
        title: feedback == ""
            ? "Rating Recieved for Ticket"
            : "Rating & Feedback Recieved for Ticket",
        postedbyID: customeruid,
        onErrorFn: (e) {},
        onSuccessFn: () {},
        plainDesc: feedback == ""
            ? "Customer ID: $customeruid has rated the Ticket. See the ticket details to find the rating."
            : "Customer ID: $customeruid has rated the Ticket & provided a feedback. See the ticket details to find the rating & feedback.");
  }
}
