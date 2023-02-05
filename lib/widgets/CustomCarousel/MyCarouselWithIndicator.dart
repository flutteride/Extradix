//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyCarouselWithIndicator extends StatefulWidget {
  final List imageslist;
  final Color dotcolorselected;
  final Color dotcolorunselected;
  final Function(int i) onClick;
  const MyCarouselWithIndicator({
    Key? key,
    required this.imageslist,
    required this.dotcolorselected,
    required this.dotcolorunselected,
    required this.onClick,
  }) : super(key: key);

  @override
  _MyCarouselWithIndicatorState createState() =>
      _MyCarouselWithIndicatorState();
}

class _MyCarouselWithIndicatorState extends State<MyCarouselWithIndicator> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<Widget> imageSliders = [];
  @override
  void initState() {
    super.initState();
    imageSliders = widget.imageslist
        .map((item) => InkWell(
              onTap: () {
                widget.onClick(
                    widget.imageslist.indexWhere((element) => element == item));
              },
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item,
                            fit: BoxFit.cover, width: 1000.0, height: 500.0),
                        // Positioned(
                        //   bottom: 0.0,
                        //   left: 0.0,
                        //   right: 0.0,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(
                        //         colors: [
                        //           Color.fromARGB(200, 0, 0, 0),
                        //           Color.fromARGB(0, 0, 0, 0)
                        //         ],
                        //         begin: Alignment.bottomCenter,
                        //         end: Alignment.topCenter,
                        //       ),
                        //     ),
                        //     padding: EdgeInsets.symmetric(
                        //         vertical: 10.0, horizontal: 20.0),
                        //     child: Text(
                        //       'No. ${widget.imageslist.indexOf(item)} image',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 20.0,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselSlider(
            items: imageSliders,
            carouselController: _controller,
            options: CarouselOptions(
                disableCenter: true,
                viewportFraction: 1,
                autoPlay: true,
                enlargeCenterPage: false,
                aspectRatio: 2.3,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageslist.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 7.0,
                  height: 7.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : _current == entry.key
                                  ? widget.dotcolorselected
                                  : widget.dotcolorunselected)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ]);
  }
}
