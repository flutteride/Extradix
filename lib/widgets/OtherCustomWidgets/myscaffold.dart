//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class MyScaffold extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final GlobalKey? scaffoldkey;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? iconWidget3;
  final IconData? leadingIconData;
  final Function? leadingIconPress;
  final double? elevation;
  final IconData? icondata1;
  final Widget? iconWidget;
  final IconData? icondata2;
  final IconData? icondata3;
  final Function? icon1press;
  final double? titlespacing;
  final Function? icon2press;
  final Widget? bottom;
  final Function? icon3press;
  final Widget? floatingActionButton;
  final Color? subtitlecolor;
  final Color? iconTextColor;
  final Color? appbarColor;
  final Color? backgroundColor;
  final bool? isforcehideback;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Function? onbackpressed;
  MyScaffold(
      {this.subtitle,
      this.title,
      this.actions,
      this.iconWidget3,
      this.onbackpressed,
      this.iconWidget,
      this.iconTextColor,
      this.elevation,
      this.bottom,
      this.backgroundColor,
      this.icon1press,
      this.titlespacing,
      this.appbarColor,
      this.icon2press,
      this.subtitlecolor,
      this.isforcehideback,
      this.icon3press,
      this.icondata1,
      this.icondata2,
      this.icondata3,
      this.leadingIconData,
      this.leadingIconPress,
      this.floatingActionButtonLocation,
      this.floatingActionButton,
      this.body,
      this.scaffoldkey});
  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: widget.appbarColor ??
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Scaffold(
      bottomSheet: widget.bottom ?? null,
      key: widget.scaffoldkey,
      backgroundColor: widget.backgroundColor ?? Mycolors.backgroundcolor,
      appBar: AppBar(
        automaticallyImplyLeading:
            widget.isforcehideback == null || widget.isforcehideback == false
                ? true
                : false,
        leading:
            widget.isforcehideback == null || widget.isforcehideback == false
                ? IconButton(
                    onPressed: widget.leadingIconPress as void Function()? ??
                        () {
                          Navigator.pop(context);
                        },
                    icon: Icon(
                      widget.leadingIconData ?? LineAwesomeIcons.arrow_left,
                      color: widget.iconTextColor ?? Colors.black87,
                    ))
                : null,
        iconTheme: IconThemeData(
          color: widget.iconTextColor ?? Mycolors.grey,
        ),
        elevation: widget.elevation ?? 0.4,
        titleSpacing:
            widget.isforcehideback == null || widget.isforcehideback == false
                ? (widget.titlespacing ?? 0)
                : 20,
        title: widget.subtitle == null
            ? MtCustomfontBold(
                maxlines: widget.subtitle == null ? 2 : 1,
                lineheight: 1.2,
                text: widget.title ?? 'Title',
                overflow: TextOverflow.ellipsis,
                fontsize: 17.5,
                color: widget.iconTextColor ?? Mycolors.black,
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                MtCustomfontBold(
                  maxlines: 1,
                  lineheight: 1.3,
                  text: widget.title ?? 'Title',
                  overflow: TextOverflow.ellipsis,
                  fontsize: 16.5,
                  color: widget.iconTextColor ?? Mycolors.black,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 1, top: 2),
                    child: MtCustomfontRegular(
                      maxlines: 1,
                      lineheight: 1.5,
                      text: widget.subtitle ?? 'Sub-Title',
                      overflow: TextOverflow.ellipsis,
                      fontsize: 11.5,
                      color: widget.subtitlecolor ?? Mycolors.grey,
                    ))
              ]),
        backgroundColor: widget.appbarColor ?? Mycolors.whiteDynamic,
        actions: widget.actions ??
            [
              Container(
                margin: EdgeInsets.only(left: 10, right: 2, bottom: 14, top: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // widget.iconWidget3 != null
                    //     ? widget.iconWidget3
                    //     : widget.icondata3 == null
                    //         ? SizedBox(
                    //             height: 0,
                    //             width: 0,
                    //           )
                    //         : Container(
                    //             margin: EdgeInsets.only(left: 0, bottom: 3),
                    //             child: IconButton(
                    //               onPressed:
                    //                   widget.icon3press as void Function()?,
                    //               icon: Icon(
                    //                 widget.icondata3 ?? Icons.done,
                    //                 size: 22,
                    //                 color: widget.iconTextColor ??
                    //                     Mycolors.appbartexticon,
                    //               ),
                    //             )),
                    widget.icondata2 == null
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 0, bottom: 3),
                            child: IconButton(
                              onPressed: widget.icon2press as void Function()?,
                              icon: Icon(
                                widget.icondata2 ?? Icons.add,
                                size: 22,
                                color: widget.iconTextColor ?? Mycolors.grey,
                              ),
                            )),
                    widget.iconWidget != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: widget.iconWidget)
                        : widget.icondata1 == null
                            ? SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Container(
                                margin: EdgeInsets.only(left: 0, bottom: 3),
                                child: IconButton(
                                  onPressed:
                                      widget.icon1press as void Function()?,
                                  icon: Icon(
                                    widget.icondata1 ?? Icons.more_vert,
                                    size: 22,
                                    color:
                                        widget.iconTextColor ?? Mycolors.grey,
                                  ),
                                )),
                  ],
                ),
              ),
            ],
      ),
      body: widget.body ?? null,
      floatingActionButton: widget.floatingActionButton ?? null,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }
}
