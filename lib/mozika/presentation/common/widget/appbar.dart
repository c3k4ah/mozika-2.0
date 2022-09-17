import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final CustomSize _size = CustomSize();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _size.width(context) * .024),
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              currentIndex = index;
              HapticFeedback.lightImpact();
            });
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              SizedBox(
                width: _size.width(context) * .2125,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: index == currentIndex ? 35 : 0,
                    width: index == currentIndex
                        ? _size.width(context) * .2125
                        : 0,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? Colors.black.withOpacity(.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Container(
                width: _size.width(context) * .2125,
                alignment: Alignment.center,
                child: Icon(
                  listOfIcons[index],
                  size: _size.width(context) * .076,
                  color: index == currentIndex ? Colors.black : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List listOfIcons = [
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.settings_rounded,
    Icons.person_rounded,
  ];
}
