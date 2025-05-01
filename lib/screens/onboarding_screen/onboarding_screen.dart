import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import '../auth/login_screen.dart';



class onBoardingScreen extends StatefulWidget {
  const onBoardingScreen({Key? key}) : super(key: key);
  @override
  _onBoarding createState() => _onBoarding();
}

class _onBoarding extends State<onBoardingScreen> {
  PageController _controller = PageController();
  bool onLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [introPage1(), introPage2(), introPage3()],
          ),
          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //skip
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text("skip"),
                ),

                SmoothPageIndicator(controller: _controller, count: 3),
                //next
                onLastPage
                    ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return  LoginPage();
                            },
                          ),
                        );
                      },
                      child: Text("done"),
                    )
                    : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: Duration(microseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text("next"),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
