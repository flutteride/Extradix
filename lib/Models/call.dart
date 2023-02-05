//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

class Call {
  String? callSessionID;
  String? callSessionInitiatedBy;
  bool? isShowNameAndPhotoToDialer;
  int? callTypeIndex;
  bool? isShowCallernameAndPhotoToReciever;
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  String? ticketID;
  String? ticketCustomerID;
  String? ticketTitle;
  String? ticketIDfiltered;
  int? timeepoch;
  bool? hasDialled;
  bool? isvideocall;

  Call({
    this.callSessionID,
    this.callSessionInitiatedBy,
    this.isShowNameAndPhotoToDialer,
    this.isShowCallernameAndPhotoToReciever,
    this.callerId,
    this.callTypeIndex,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.ticketID,
    this.ticketCustomerID,
    this.ticketIDfiltered,
    this.ticketTitle,
    this.receiverPic,
    this.timeepoch,
    this.channelId,
    this.hasDialled,
    this.isvideocall,
  });

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap["call_session_ID"] = call.callSessionID;
    callMap["customer_id"] = call.ticketCustomerID;
    callMap["ticket_session_ib"] = call.callSessionInitiatedBy;
    callMap["call_type_idx"] = call.callTypeIndex;
    callMap["show_name_photo_to_dialer"] = call.isShowNameAndPhotoToDialer;
    callMap["show_name_photo_to_reciever"] = isShowCallernameAndPhotoToReciever;
    callMap["caller_id"] = call.callerId;
    callMap["ticket_ID"] = call.ticketID;
    callMap["ticket_id_f"] = call.ticketIDfiltered;
    callMap["ticket_title"] = call.ticketTitle;
    callMap["caller_name"] = call.callerName;
    callMap["caller_pic"] = call.callerPic;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_pic"] = call.receiverPic;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    callMap["isvideocall"] = call.isvideocall;
    callMap["timeepoch"] = call.timeepoch;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    this.ticketIDfiltered = callMap["ticket_id_f"];
    this.ticketCustomerID = callMap["customer_id"];
    this.ticketTitle = callMap["ticket_title"];
    this.callSessionID = callMap["call_session_ID"];
    this.callSessionInitiatedBy = callMap["ticket_session_ib"];
    this.ticketID = callMap["ticket_ID"];
    this.callTypeIndex = callMap["call_type_idx"];
    this.isShowNameAndPhotoToDialer = callMap["show_name_photo_to_dialer"];
    this.isShowCallernameAndPhotoToReciever =
        callMap["show_name_photo_to_reciever"];
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerPic = callMap["caller_pic"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
    this.isvideocall = callMap["isvideocall"];
    this.timeepoch = callMap["timeepoch"];
  }
}
