import 'package:Dimodo/common/constants.dart';
import 'package:Dimodo/models/user/userModel.dart';
import 'package:Dimodo/widgets/baumann_quiz.dart';
import 'package:Dimodo/widgets/customWidgets.dart';
import 'package:Dimodo/widgets/popup_services.dart';
import 'package:Dimodo/widgets/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Dimodo/common/styles.dart';
import 'package:Dimodo/generated/i18n.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class FeedbackCenter extends StatefulWidget {
  @override
  _FeedbackCenterState createState() => _FeedbackCenterState();
}

class _FeedbackCenterState extends State<FeedbackCenter> {
  Size screenSize;
  UserModel userModel;
  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            elevation: 0,
            title: Text(
              "Phản hồi",
              style: kBaseTextStyle.copyWith(
                  color: kPrimaryBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            // expandedHeight: screenSize.height * 0.3,
            brightness: Brightness.light,
            leading: CommonIcons.backIcon(context, kPrimaryBlue),
            backgroundColor: kQuaternaryBlue),
        body: SafeArea(
          bottom: false,
          child: Container(
            width: screenSize.width,
            color: kQuaternaryBlue,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.only(bottom: 30),
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Container(
                        height: 160,
                        color: kQuaternaryBlue,
                      ),
                      GestureDetector(
                        onTap: () => PopupServices.showSurvey(context),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20.0, right: 20, bottom: 30),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: kSecondaryBlue),
                            padding: EdgeInsets.only(
                                left: 16, right: 30, top: 14, bottom: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "Thích/không thích ứng dụng?",
                                      style: kBaseTextStyle.copyWith(
                                          color: kPrimaryBlue,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Làm khảo sát bây giờ",
                                      style: kBaseTextStyle.copyWith(
                                          color: kPrimaryBlue,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                SvgPicture.asset("assets/icons/arrow-more.svg")
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 0,
                          child: SvgPicture.asset(
                              "assets/icons/blue-big-logo.svg")),
                      Positioned(
                          top: 0,
                          left: screenSize.width / 2 + 58,
                          child: SvgPicture.asset(
                              "assets/icons/light-blue-star.svg"))
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SvgPicture.asset(
                        "assets/icons/nolt-illustration.svg",
                        width: screenSize.width,
                      ),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 15),
                              Text(
                                "Để giúp Glowvy phát triển hơn, bạn có thể:",
                                style: kBaseTextStyle.copyWith(
                                    color: kDarkSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextWithIcon(
                                  "Đề xuất tính năng bạn muốn thêm vào trong ứng dụng",
                                  "assets/icons/blue-smiley-face.svg"),
                              TextWithIcon(
                                  "Chia sẻ câu chuyện của bạn về trải nghiệm tốt/không tốt khi mua mỹ phẩm",
                                  "assets/icons/blue-smiley-face.svg"),
                              TextWithIcon(
                                  "Bình chọn cho bất cứ tính năng nào bạn yêu thích",
                                  "assets/icons/blue-smiley-face.svg"),
                              TextWithIcon(
                                  "Theo dõi quá trình phát triển của Glowvy",
                                  "assets/icons/blue-smiley-face.svg"),
                              SizedBox(height: 36),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebView(
                                              url:
                                                  "https://glowvy.nolt.io/newest",
                                            ))),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      color: kPrimaryBlue),
                                  width: screenSize.width,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Phát triển Glowvy",
                                    style: kBaseTextStyle.copyWith(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(height: 54),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 24),
                            SvgPicture.asset(
                              "assets/icons/email-illustration.svg",
                              width: screenSize.width,
                            ),
                            // CustomPaint(
                            //     size: Size(screenSize.width, 231), //2
                            //     painter:
                            //         ProfileCardPainter(color: kQuaternaryBlue)),
                            Container(
                              color: kQuaternaryBlue,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 48, right: 48),
                                    child: Text(
                                      "Có vấn đề với ứng dụng? Hãy gửi mail cho nhà phát triển! Glowvy team sẽ phản hồi nhanh nhất có thể.",
                                      textAlign: TextAlign.center,
                                      style: kBaseTextStyle.copyWith(
                                          color: kDarkSecondary,
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(height: 22),
                                  GestureDetector(
                                    onTap: () async => await FlutterMailer.send(
                                        MailOptions(
                                            body: '',
                                            subject:
                                                'Làm thế nào chúng tôi có thể cải thiện ứng dụng cho bạn?',
                                            recipients: [
                                          'hbpfreeman@gmail.com'
                                        ])),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 48, right: 48),
                                      child: Container(
                                          height: 48,
                                          alignment: Alignment.center,
                                          child: Text(
                                              "Liên hệ nhà phát triển Glowvy",
                                              textAlign: TextAlign.center,
                                              style: kBaseTextStyle.copyWith(
                                                  color: kPrimaryBlue,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: kSecondaryBlue,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class TextWithIcon extends StatelessWidget {
  final text;
  final iconPath;
  TextWithIcon(this.text, this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(iconPath),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              style: kBaseTextStyle.copyWith(
                  color: kDarkSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCardPainter extends CustomPainter {
  //2
  ProfileCardPainter({@required this.color});

  //3
  final Color color;

  //4
  @override
  void paint(Canvas canvas, Size size) {
    //1
    final shapeBounds = Rect.fromLTRB(0, 0, size.width, size.height);

    final curvedShapeBounds = Rect.fromLTRB(
      shapeBounds.left,
      shapeBounds.top,
      shapeBounds.right,
      shapeBounds.bottom,
    );

//2
    _drawCurvedShape(canvas, curvedShapeBounds, shapeBounds);
  }

  void _drawCurvedShape(Canvas canvas, Rect bounds, Rect avatarBounds) {
    //1
    final paint = Paint()..color = color;
    //2
    final handlePoint = Offset(bounds.left + (bounds.width * 0.75), bounds.top);

    //3
    final curvePath = Path()
      ..moveTo(bounds.topLeft.dx, bounds.topLeft.dy) //4
      ..lineTo(bounds.bottomLeft.dx, bounds.bottomLeft.dy) //6
      ..lineTo(bounds.bottomRight.dx, bounds.bottomRight.dy) //7
      ..lineTo(bounds.topRight.dx, 51) //7
      ..quadraticBezierTo(handlePoint.dx, handlePoint.dy, bounds.topLeft.dx,
          bounds.topLeft.dy) //8
      ..close(); //9

    //10
    canvas.drawPath(curvePath, paint);
  }

  //5qq
  @override
  bool shouldRepaint(ProfileCardPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
