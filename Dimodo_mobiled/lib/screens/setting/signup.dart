import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Dimodo/models/user/user.dart';
import 'package:Dimodo/models/user/userModel.dart';

import 'package:Dimodo/generated/i18n.dart';
import 'package:Dimodo/common/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Dimodo/widgets/login_animation.dart';
import 'package:Dimodo/widgets/customWidgets.dart';

class SignupScreen extends StatefulWidget {
  final bool fromCart;
  SignupScreen({this.fromCart = false});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String fullName, email, password;
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  bool isChecked = false;
  var parentContext;

  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  void _welcomeDiaLog(User user) {
    var email = user.email;
    _snackBar('Welcome $email!');
    Navigator.of(context).pop();
  }

  void _failMess(message) {
    _snackBar(message);
  }

  void _snackBar(String text) {
    final snackBar = SnackBar(
      content: DynamicText(
        '$text',
        style: kBaseTextStyle.copyWith(color: Colors.white),
      ),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {}
  }

  _loginFacebook(context) async {
    //showLoading();
    _playAnimation();
    Provider.of<UserModel>(context, listen: false).loginFB(
      success: (user) {
        //hideLoading();
        _stopAnimation();
        _welcomeMessage(user, context);
      },
      fail: (message) {
        //hideLoading();
        _stopAnimation();
        _failMessage(message, context);
      },
    );
  }

  void _welcomeMessage(user, context) {
    if (widget.fromCart) {
      Navigator.of(context).pop(user);
    } else {
      final snackBar = SnackBar(
          content: DynamicText(S.of(context).welcome + ' ${user.name} !',
              style: kBaseTextStyle));
      Scaffold.of(context).showSnackBar(snackBar);
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacementNamed('/setting');
      });
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: DynamicText('Warning: $message', style: kBaseTextStyle),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle buttonTextStyle =
        Theme.of(context).textTheme.button.copyWith(fontSize: 16);
    final screenSize = MediaQuery.of(context).size;
    parentContext = context;

    _submitRegister(fullName, email, password) {
      print("registering: ${fullName + " " + email + " " + password}");
      if (!email.contains("@")) {
        _snackBar('Please input valid email format');
      } else if (fullName == null || email == null || password == null) {
        _snackBar('Please input fill in all fields');
      } else {
        Provider.of<UserModel>(context, listen: false).createUser(
            fullName: fullName,
            password: password,
            email: email,
            success: _welcomeDiaLog,
            fail: _failMess);
      }
    }

    _loginGoogle(context) async {
      _playAnimation();
      Provider.of<UserModel>(context, listen: false).loginGoogle(
        success: (user) {
          //hideLoading();
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          //hideLoading();
          _stopAnimation();
          _failMessage(message, context);
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Brightness.light,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container(),
        actions: <Widget>[
          FlatButton(
            child: DynamicText(S.of(context).login,
                style: buttonTextStyle.copyWith(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          )
        ],
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(children: [
            ListenableProvider.value(
              value: Provider.of<UserModel>(context, listen: false),
              child: Consumer<UserModel>(builder: (context, model, child) {
                return Container(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  width: screenSize.width,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 0.0),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DynamicText(
                                S.of(parentContext).signup,
                                style: kBaseTextStyle.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 23.0),
                      Container(
                          width: screenSize.width,
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              color: kPureWhite),
                          child: // Group 6
                              Center(
                            child: TextField(
                              onChanged: (value) => fullName = value,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: S.of(parentContext).fullName,
                                hintStyle: kBaseTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kDarkSecondary.withOpacity(0.5),
                                ),
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          )),
                      SizedBox(height: 12.0),
                      Container(
                          width: screenSize.width,
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              color: kPureWhite),
                          child: // Group 6
                              Center(
                            child: TextField(
                              controller: _emailController,
                              onChanged: (value) => email = value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: S.of(parentContext).enterYourEmail,
                                hintStyle: kBaseTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kDarkSecondary.withOpacity(0.5),
                                ),
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          )),
                      SizedBox(height: 12.0),
                      Container(
                          width: screenSize.width,
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              color: kPureWhite),
                          child: // Group 6
                              Center(
                            child: TextField(
                              onChanged: (value) => password = value,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: S.of(parentContext).password,
                                hintStyle: kBaseTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kDarkSecondary.withOpacity(0.5),
                                ),
                                contentPadding: EdgeInsets.only(left: 20),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 16.0,
                      ),
                      SizedBox(height: 10),
                      StaggerAnimation(
                          titleButton: S.of(context).signup,
                          buttonController: _loginButtonController.view,
                          onTap: () {
                            _submitRegister(fullName, email, password);
                          }),
                      SizedBox(
                        height: 24.0,
                      ),
                      DynamicText(S.of(context).loginWithSNS,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400)),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            color: kLightPink,
                            minWidth: screenSize.width / 2 - 24,
                            height: 48,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25.0)),
                            onPressed: () => _loginFacebook(context),
                            child: Icon(
                              FontAwesomeIcons.facebookF,
                              color: kPinkAccent,
                              size: 24.0,
                            ),
                            elevation: 0.0,
                          ),
                          SizedBox(width: 16),
                          MaterialButton(
                            color: kLightPink,
                            minWidth: screenSize.width / 2 - 24,
                            height: 48,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25.0)),
                            onPressed: () => _loginGoogle(context),
                            child: Icon(
                              FontAwesomeIcons.google,
                              color: Colors.red,
                              size: 24.0,
                            ),
                            elevation: 0.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}