//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/open_settings.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/widgets/VideoPicker/VideoPicker.dart';

class MultiDocumentPicker extends StatefulWidget {
  MultiDocumentPicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.writeMessage,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;

  @override
  _MultiDocumentPickerState createState() => new _MultiDocumentPickerState();
}

class _MultiDocumentPickerState extends State<MultiDocumentPicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<PlatformFile> seletedFiles = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (seletedFiles.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    int index = seletedFiles.indexWhere((file) =>
        File(file.path!).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureMultiPageDoc(bool isAddOnly) async {
    final observer = Provider.of<Observer>(this.context, listen: false);

    error = null;

    try {
      FilePickerResult? files = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);

      if (files != null) {
        if (files.files.length > 1) {
          seletedFiles = files.files;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (files.files.length == 1) {
          if (File(files.files[0].path!).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                '${getTranslatedForCurrentUser(this.context, 'xxmaxfilesizexx')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslatedForCurrentUser(this.context, 'xxselectedfilesizexx')} ${(File(files.files[0].path!).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              seletedFiles = files.files;
            });
          }
        }
      }
    } catch (e) {
      Utils.toast('Cannot Send this Document type');
      Navigator.of(this.context).pop();
    }
  }

  Widget _buildSingleFile({File? file}) {
    if (file != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.yellow[900],
            size: 74,
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Text(
              basename(seletedFiles[0].path!).toString(),
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Mycolors.black,
              ),
            ),
          )
        ],
      );
    } else {
      return new Text(getTranslatedForCurrentUser(this.context, 'xxtakefilexx'),
          style: new TextStyle(
            fontSize: 18.0,
            color: Mycolors.black,
          ));
    }
  }

  Widget _buildMultiDocLoading() {
    return Container(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currentUploadingIndex + 1}/${seletedFiles.length}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: Mycolors.secondary),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            getTranslatedForCurrentUser(this.context, 'xxsendingxx'),
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Mycolors.black),
          )
        ],
      )),
      color: Colors.white.withOpacity(0.8),
    );
  }

  Widget _buildMultiDoc() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (seletedFiles.length > 0) {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: seletedFiles.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: Colors.yellow[900],
                          size: 44,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            basename(seletedFiles[i].path!).toString(),
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                  File(seletedFiles[i].path!).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsetsDirectional.all(10),
                              child: Text(
                                '${getTranslatedForCurrentUser(this.context, 'xxmaxfilesizexx')} ${observer.maxFileSizeAllowedInMB}MB\n${getTranslatedForCurrentUser(this.context, 'xxselectedfilesizexx')} ${(File(seletedFiles[i].path!).lengthSync() / 1000000).round()}MB',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          seletedFiles.removeAt(i);
                          if (seletedFiles.length <= 1) {
                            mode = "single";
                          }
                        });
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: new BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: new Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // decoration: BoxDecoration(
              //     color: Colors.amber, borderRadius: BorderRadius.circular(15)),
            );
          });
    } else {
      return new Text(getTranslatedForCurrentUser(this.context, 'xxtakefilexx'),
          style: new TextStyle(
            fontSize: 18.0,
            color: Mycolors.black,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Utils.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
            leading: IconButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: Mycolors.black,
              ),
            ),
            title: new Text(
              seletedFiles.length > 0
                  ? '${seletedFiles.length} ${getTranslatedForCurrentUser(this.context, 'xxselectedxx')}'
                  : widget.title,
              style: TextStyle(
                fontSize: 18,
                color: Mycolors.black,
              ),
            ),
            backgroundColor: Colors.white,
            actions: seletedFiles.length != 0 && !isLoading
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Mycolors.black,
                        ),
                        onPressed: checkTotalNoOfFilesIfExceeded() == false
                            ? (checkIfAnyFileSizeExceeded() == false
                                ? () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    uploadEach(0);
                                  }
                                : () {
                                    final observer = Provider.of<Observer>(
                                        this.context,
                                        listen: false);
                                    Utils.toast(getTranslatedForCurrentUser(
                                            context, 'xxilesizeexceededxx') +
                                        ': ${observer.maxFileSizeAllowedInMB}MB');
                                  })
                            : () {
                                Utils.toast(
                                    '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                              }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            mode == 'single'
                ? new Expanded(
                    child: new Center(
                        child: error != null
                            ? fileSizeErrorWidget(error!)
                            : _buildSingleFile(
                                file: seletedFiles.length > 0
                                    ? File(seletedFiles[0].path!)
                                    : null)))
                : new Expanded(child: new Center(child: _buildMultiDoc())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && seletedFiles.length > 1
                    ? _buildMultiDocLoading()
                    : Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Mycolors.secondary)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  uploadEach(int index) async {
    if (index > seletedFiles.length) {
      Navigator.of(this.context).pop();
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await widget
          .callback(File(seletedFiles[index].path!),
              timestamp: messagetime, totalFiles: seletedFiles.length)
          .then((fileUrl) async {
        await widget.writeMessage!(fileUrl, messagetime).then((value) {
          if (seletedFiles.last == seletedFiles[index]) {
            Navigator.of(this.context).pop();
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
    }
  }

  Widget _buildButtons() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  new Key('multi'),
                  Icons.add,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Utils.checkAndRequestPermission(Permission.photos)
                              .then((res) {
                            if (res == true) {
                              captureMultiPageDoc(false);
                            } else if (res == false) {
                              Utils.showRationale(getTranslatedForCurrentUser(
                                  this.context, 'xxpgixx'));
                              Navigator.pushReplacement(
                                  this.context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings()));
                            } else {}
                          });
                        }
                      : () {
                          Utils.toast(
                              '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      child: new IconButton(
          key: key,
          icon: Icon(
            icon,
            size: 30.0,
          ),
          color: Mycolors.primary,
          onPressed: onPressed as void Function()?),
    );
  }
}
