//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getGroupMessageTile.dart';

Widget getMediaMessage(BuildContext context, bool isBold, var lastMessage) {
  Color textColor = isBold ? darkGrey : lightGrey;
  Color iconColor = isBold ? darkGrey : lightGrey;
  TextStyle style = TextStyle(
    color: textColor,
    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
  );
  return lastMessage![Dbkeys.messageType] == MessageType.doc.index
      ? Row(
          children: [
            Icon(Icons.file_copy, size: 17.7, color: iconColor),
            SizedBox(
              width: 4,
            ),
            Text(
              getTranslatedForCurrentUser(context, 'xxdocxx'),
              style: style,
              maxLines: 1,
            ),
          ],
        )
      : lastMessage[Dbkeys.messageType] == MessageType.audio.index
          ? Row(
              children: [
                Icon(Icons.mic, size: 17.7, color: iconColor),
                SizedBox(
                  width: 4,
                ),
                Text(
                  getTranslatedForCurrentUser(context, "xxaudioxx"),
                  style: style,
                  maxLines: 1,
                ),
              ],
            )
          : lastMessage[Dbkeys.messageType] == MessageType.location.index
              ? Row(
                  children: [
                    Icon(Icons.location_on, size: 17.7, color: iconColor),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      getTranslatedForCurrentUser(context, "xxlocationxx"),
                      style: style,
                      maxLines: 1,
                    ),
                  ],
                )
              : lastMessage[Dbkeys.messageType] == MessageType.contact.index
                  ? Row(
                      children: [
                        Icon(Icons.contact_page, size: 17.7, color: iconColor),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          getTranslatedForCurrentUser(context, "xxcontactxx"),
                          style: style,
                          maxLines: 1,
                        ),
                      ],
                    )
                  : lastMessage[Dbkeys.messageType] == MessageType.video.index
                      ? Row(
                          children: [
                            Icon(Icons.videocam, size: 18, color: iconColor),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              getTranslatedForCurrentUser(context, "xxvideoxx"),
                              style: style,
                              maxLines: 1,
                            ),
                          ],
                        )
                      : lastMessage[Dbkeys.messageType] ==
                              MessageType.image.index
                          ? Row(
                              children: [
                                Icon(Icons.image, size: 16, color: iconColor),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  getTranslatedForCurrentUser(
                                      context, "xximagexx"),
                                  style: style,
                                  maxLines: 1,
                                ),
                              ],
                            )
                          : SizedBox();
}
