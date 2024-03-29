//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

showDynamicModalBottomSheet({
  required BuildContext context,
  required List<Widget> widgetList,
  required String title,
  String? desc,
  bool? isextraMargin = true,
  bool isCentre = true,
  double padding = 7,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.001),
          child: GestureDetector(
            onTap: () {},
            child: DraggableScrollableSheet(
              initialChildSize: widgetList.length <= 2
                  ? 0.3
                  : widgetList.length > 7
                      ? 0.8
                      : widgetList.length * 0.069,
              minChildSize: 0.1,
              maxChildSize: 0.85,
              builder: (_, controller) {
                return Container(
                  padding: EdgeInsets.all(isextraMargin == true ? 20 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove,
                        color: Mycolors.grey,
                      ),
                      title == ""
                          ? SizedBox()
                          : Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Mycolors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: widgetList.length,
                          itemBuilder: (_, index) {
                            return widgetList[index];
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );

  // showModalBottomSheet<dynamic>(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext bc) {
  //       return Wrap(children: <Widget>[
  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.all(padding),
  //           child: Container(
  //             decoration: new BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: new BorderRadius.only(
  //                     topLeft: const Radius.circular(25.0),
  //                     topRight: const Radius.circular(25.0))),
  //             child: Column(
  //                 // mainAxisSize: MainAxisSize.max,
  //                 // mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: isCentre == true
  //                     ? CrossAxisAlignment.center
  //                     : CrossAxisAlignment.start,
  //                 children: widgetList),
  //           ),
  //         )
  //       ]);
  //     });
}
