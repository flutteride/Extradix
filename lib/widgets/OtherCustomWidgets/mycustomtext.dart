//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/MyRegisteredFonts.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:flutter/material.dart';

// ignore: todo
//TODO--------- Custom font Texts---(Your Fav font in Popular languages)-------

class MtCustomfontLight extends StatefulWidget {
  final String? text;
  final double? lineheight;
  final double? fontsize;
  final bool? isitalic;
  final Color? color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final TextDirection? textdirection;
  final TextAlign? textalign;
  final int? maxlines;
  MtCustomfontLight(
      {this.text,
      this.isitalic,
      this.weight,
      this.color,
      this.fontsize,
      this.lineheight,
      this.textdirection,
      this.overflow,
      this.maxlines,
      this.textalign});
  @override
  _MtCustomfontLightState createState() => _MtCustomfontLightState();
}

class _MtCustomfontLightState extends State<MtCustomfontLight> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text ?? '',
        textDirection: widget.textdirection ?? TextDirection.ltr,
        overflow: widget.overflow ?? TextOverflow.visible,
        maxLines: widget.maxlines ?? 10,
        textAlign: widget.textalign ?? TextAlign.left,
        style: TextStyle(
            fontSize: widget.fontsize ?? 12,
            color: widget.color ?? Mycolors.grey,
            height: widget.lineheight ?? 1,
            fontFamily: MyRegisteredFonts.altLight,
            // fontWeight: widget.weight ?? FontWeight.normal,
            fontStyle:
                widget.isitalic == true ? FontStyle.italic : FontStyle.normal));
  }
}

class MtCustomfontRegular extends StatefulWidget {
  final String? text;
  final double? lineheight;
  final double? fontsize;
  final bool? isitalic;
  final Color? color;
  final TextDecoration? decoration;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final TextDirection? textdirection;
  final TextAlign? textalign;
  final int? maxlines;
  MtCustomfontRegular(
      {this.text,
      this.isitalic,
      this.weight,
      this.decoration,
      this.color,
      this.fontsize,
      this.lineheight,
      this.textdirection,
      this.overflow,
      this.maxlines,
      this.textalign});
  @override
  _MtCustomfontRegularState createState() => _MtCustomfontRegularState();
}

class _MtCustomfontRegularState extends State<MtCustomfontRegular> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text ?? 'Text',
        textDirection: widget.textdirection ?? TextDirection.ltr,
        overflow: widget.overflow ?? TextOverflow.visible,
        maxLines: widget.maxlines ?? 1000,
        textAlign: widget.textalign ?? TextAlign.left,
        style: TextStyle(
            decoration: widget.decoration ?? null,
            fontSize: widget.fontsize ?? 16,
            color: widget.color ?? Mycolors.grey,
            height: widget.lineheight ?? 1,
            fontFamily: MyRegisteredFonts.regular,
            // fontWeight: widget.weight ?? FontWeight.normal,
            fontStyle:
                widget.isitalic == true ? FontStyle.italic : FontStyle.normal));
  }
}

class MtCustomfontBold extends StatefulWidget {
  final String? text;
  final double? lineheight;
  final double? fontsize;
  final double? letterspacing;
  final bool? isitalic;
  final Color? color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final TextDirection? textdirection;
  final TextAlign? textalign;
  final int? maxlines;
  final bool? isNullColor;
  MtCustomfontBold(
      {this.text,
      this.isitalic,
      this.weight,
      this.color,
      this.fontsize,
      this.letterspacing,
      this.lineheight,
      this.textdirection,
      this.overflow,
      this.isNullColor,
      this.maxlines,
      this.textalign});
  @override
  _MtCustomfontBoldState createState() => _MtCustomfontBoldState();
}

class _MtCustomfontBoldState extends State<MtCustomfontBold> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text ?? 'Text',
        textDirection: widget.textdirection ?? TextDirection.ltr,
        overflow: widget.overflow ?? TextOverflow.visible,
        maxLines: widget.maxlines ?? 1000,
        textAlign: widget.textalign ?? TextAlign.left,
        style: widget.isNullColor == true
            ? TextStyle(
                fontSize: widget.fontsize ?? 20,
                height: widget.lineheight ?? 1,
                fontFamily: MyRegisteredFonts.bold,
                fontStyle: widget.isitalic == true
                    ? FontStyle.italic
                    : FontStyle.normal)
            : TextStyle(
                fontSize: widget.fontsize ?? 20,
                color: widget.color ?? null,
                height: widget.lineheight ?? 1,
                fontFamily: MyRegisteredFonts.bold,
                fontStyle: widget.isitalic == true
                    ? FontStyle.italic
                    : FontStyle.normal));
  }
}

class MtCustomfontBoldExtra extends StatefulWidget {
  final String? text;
  final double? lineheight;
  final double? fontsize;
  final bool? isitalic;
  final Color? color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final TextDirection? textdirection;
  final TextAlign? textalign;
  final int? maxlines;
  MtCustomfontBoldExtra(
      {this.text,
      this.isitalic,
      this.weight,
      this.color,
      this.fontsize,
      this.lineheight,
      this.textdirection,
      this.overflow,
      this.maxlines,
      this.textalign});
  @override
  _MtCustomfontBoldExtraState createState() => _MtCustomfontBoldExtraState();
}

class _MtCustomfontBoldExtraState extends State<MtCustomfontBoldExtra> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text ?? '',
        textDirection: widget.textdirection ?? TextDirection.ltr,
        overflow: widget.overflow ?? TextOverflow.visible,
        maxLines: widget.maxlines ?? 1000,
        textAlign: widget.textalign ?? TextAlign.left,
        style: TextStyle(
            fontSize: widget.fontsize ?? 18,
            color: widget.color ?? Mycolors.black,
            height: widget.lineheight ?? 1,
            fontFamily: MyRegisteredFonts.black,
            // fontWeight: widget.weight ?? FontWeight.w800,
            fontStyle:
                widget.isitalic == true ? FontStyle.italic : FontStyle.normal));
  }
}

class MtCustomfontBoldSemi extends StatefulWidget {
  final String? text;
  final double? lineheight;
  final double? fontsize;
  final bool? isitalic;
  final Color? color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final TextDirection? textdirection;
  final TextAlign? textalign;
  final int? maxlines;
  final double? letterspacing;
  MtCustomfontBoldSemi(
      {this.text,
      this.isitalic,
      this.weight,
      this.color,
      this.fontsize,
      this.letterspacing,
      this.lineheight,
      this.textdirection,
      this.overflow,
      this.maxlines,
      this.textalign});
  @override
  _MtCustomfontBoldSemiState createState() => _MtCustomfontBoldSemiState();
}

class _MtCustomfontBoldSemiState extends State<MtCustomfontBoldSemi> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text ?? '',
        textDirection: widget.textdirection ?? TextDirection.ltr,
        overflow: widget.overflow ?? TextOverflow.visible,
        maxLines: widget.maxlines ?? 1000,
        textAlign: widget.textalign ?? TextAlign.left,
        style: TextStyle(
            // letterSpacing: widget.letterspacing ?? null,
            fontSize: widget.fontsize ?? 18,
            color: widget.color ?? Mycolors.black,
            fontFamily: MyRegisteredFonts.semiBold,
            height: widget.lineheight ?? 1,
            // fontWeight: widget.weight ?? FontWeight.w600,
            fontStyle:
                widget.isitalic == true ? FontStyle.italic : FontStyle.normal));
  }
}
