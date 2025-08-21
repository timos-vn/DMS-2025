import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../model/network/response/ticket_detail_history_response.dart';
import '../../utils/images.dart';

class CustomCarousel extends StatefulWidget {
  final List<String> items;

  // ignore: use_key_in_widget_constructors
  const CustomCarousel({required this.items});

  @override
  // ignore: library_private_types_in_public_api
  _CustomCarouselState createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int activeIndex = 0;
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: widget.items.isEmpty
              ? Image.asset(noWallpaper, fit: BoxFit.cover,)
              : CarouselSlider(
              items: widget.items.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child:
                          Image(
                            image: NetworkImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                // enlargeCenterPage: true,
                onPageChanged:(index,__){
                  setActiveDot(index);
                },
                scrollDirection: Axis.horizontal,
              )
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(widget.items.length, (idx) {
                return activeIndex == idx ? const ActiveDot() : const InactiveDot();
              })),
        )
      ],
    );
  }
}

class CustomCarouselObject extends StatefulWidget {
  final List<ImageListTicketDetailHistory> items;

  // ignore: use_key_in_widget_constructors
  const CustomCarouselObject({required this.items});

  @override
  // ignore: library_private_types_in_public_api
  _CustomCarouselObjectState createState() => _CustomCarouselObjectState();
}

class _CustomCarouselObjectState extends State<CustomCarouselObject> {
  int activeIndex = 0;
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: widget.items.isEmpty
              ? Image.asset(noWallpaper, fit: BoxFit.cover,)
              : CarouselSlider(
              items: widget.items.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child:
                          Image(
                            image: NetworkImage(item.pathL.toString()),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                // enlargeCenterPage: true,
                onPageChanged:(index,__){
                  setActiveDot(index);
                },
                scrollDirection: Axis.horizontal,
              )
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(widget.items.length, (idx) {
                return activeIndex == idx ? const ActiveDot() : const InactiveDot();
              })),
        )
      ],
    );
  }
}

class ActiveDot extends StatelessWidget {
  const ActiveDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 25,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class InactiveDot extends StatelessWidget {
  const InactiveDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
