import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../model/network/response/get_list_slider_image_response.dart';

class HomeSlider extends StatefulWidget {
  final Function(int) onChange;
  final List<ListSliderImage> items;
  const HomeSlider({Key? key,
    required this.onChange,
    required this.items,
  }) : super(key: key);

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {

  int activeIndex = 0;
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: CarouselSlider(
              items: widget.items.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(item.link.toString()),
                                ),
                              ),
                            );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                viewportFraction: 1,
                initialPage: 0,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayCurve: Curves.easeInOutCirc,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enableInfiniteScroll: true,
                onPageChanged:(index,__){
                  setActiveDot(index);
                },
              )
          )
        ),
        Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: activeIndex == index ? 15 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: activeIndex == index
                        ? Colors.black
                        : Colors.transparent,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class KPISlider extends StatefulWidget {
  final Function(int) onChange;
  final List<ListSliderImage> items;
  const KPISlider({Key? key,
    required this.onChange,
    required this.items,
  }) : super(key: key);

  @override
  State<KPISlider> createState() => _KPISliderState();
}

class _KPISliderState extends State<KPISlider> {

  int activeIndex = 0;
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
            height: 150,
            width: double.infinity,
            child: CarouselSlider(
                items: widget.items.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(item.link.toString()),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  viewportFraction: 1,
                  initialPage: 0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayCurve: Curves.easeInOutCirc,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enableInfiniteScroll: true,
                  onPageChanged:(index,__){
                    setActiveDot(index);
                  },
                )
            )
        ),
        Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: activeIndex == index ? 15 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: activeIndex == index
                        ? Colors.black
                        : Colors.transparent,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}