import 'package:Dimodo/widgets/customWidgets.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../common/constants.dart';
import '../common/config.dart' as config;
import '../common/styles.dart';
import '../common/sizeConfig.dart';
import 'package:Dimodo/generated/i18n.dart';

class OnBoardScreen extends StatefulWidget {
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  List<Widget> pages = [];
  final isRequiredLogin = config.kAdvanceConfig['IsRequiredLogin'];
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Widget loginWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image.asset(
          "assets/images/fogg-order-completed.png",
          height: 200,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  'Sign In',
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              Text(
                "    |    ",
                style: TextStyle(color: kTeal400, fontSize: 20.0),
              ),
              GestureDetector(
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ],
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    kSizeConfig = SizeConfig(screenSize);

    for (int i = 0; i < config.onBoardingData.length; i++) {
      var page = Container(
        color: kDefaultBackground,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 60),
            //make the image fit
            Container(
              width: screenSize.width,
              child: Image.asset(
                config.onBoardingData[i]['image'],
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(config.onBoardingData[i]['title'],
                          textAlign: TextAlign.center,
                          style: kBaseTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kDefaultFontColor,
                            decoration: TextDecoration.none,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            DynamicText(config.onBoardingData[i]['desc'],
                style: kBaseTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kDarkSecondary,
                    decoration: TextDecoration.none,
                    fontSize: 12)),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (i == 2)
                      MaterialButton(
                          elevation: 0,
                          minWidth: 180,
                          color: kDarkAccent,
                          height: 48,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                          ),
                          child: Text(S.of(context).getStarted,
                              style: kBaseTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white)),
                          onPressed: () {
                            Navigator.pushNamed(context, "/home");
                          }),
                    Padding(
                        padding: const EdgeInsets.only(
                          top: 33,
                          left: 16,
                          right: 16,
                          bottom: 40.0,
                        ),
                        child: SmoothPageIndicator(
                          controller: _pageController, // PageController
                          count: 3,
                          effect: SlideEffect(
                              spacing: 5.0,
                              radius: 5,
                              dotWidth: 5.0,
                              dotHeight: 5.0,
                              paintStyle: PaintingStyle.fill,
                              strokeWidth: 1.0,
                              dotColor: Colors.grey,
                              activeDotColor:
                                  kDarkAccent), // your preferred effect
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      pages.add(page);
    }
    return Container(
      color: kDefaultBackground,
      height: kSizeConfig.screenHeight,
      child: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, i) {
            return pages[i];
          },
          itemCount: pages.length, // Can be null
        ),
      ),
    );
  }
}
