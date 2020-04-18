import 'dart:async';
import 'dart:ui';

import 'package:Dimodo/models/address/address.dart';
import 'package:Dimodo/screens/cart.dart';
import 'package:Dimodo/screens/category.dart';
import 'package:Dimodo/screens/categories/sub_category.dart';
import 'package:Dimodo/screens/checkout/orderSubmitted.dart';
import 'package:Dimodo/screens/detail/product_detail.dart';
import 'package:Dimodo/screens/orders.dart';
import 'package:Dimodo/screens/setting/shipping_address.dart';
import 'package:Dimodo/screens/setting/reset_password.dart';
import 'package:Dimodo/screens/setting/manage_address.dart';
import 'package:after_layout/after_layout.dart';
import 'screens/staticLaunchScreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/i18n.dart';
import 'models/app.dart';
import 'models/order/cart.dart';
import 'models/category.dart';
import 'models/order/orderModel.dart';
import 'models/address/addressModel.dart';
import 'models/payment_method.dart';
import 'models/product/productModel.dart';
import 'models/product/recent_product.dart';
import 'models/search.dart';
import 'models/shipping_method.dart';
import 'models/user/userModel.dart';
import 'models/wishlist.dart';
import 'screens//setting/login.dart';
import 'screens/onboard_screen.dart';
import 'screens/setting/signup.dart';
import 'services/index.dart';
import 'tabbar.dart';
import 'package:Dimodo/screens/setting/forgot_password.dart';
import 'screens/settings.dart';
import 'package:flutter/services.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class Dimodo extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<Dimodo> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light) // Or Brightness.dark
        );

    /// For Flare Image
    if (kSplashScreen.lastIndexOf('flr') > 0) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: SplashScreen.navigate(
          name: kSplashScreen,
          startAnimation: 'Dimodo',
          backgroundColor: Colors.white,
          next: (object) => MyApp(),
          until: () => Future.delayed(Duration(seconds: 2)),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: CustomSplash(
        imagePath: kSplashScreen,
        backGroundColor: kLightPink,
        animationEffect: 'fade-in',
        home: MyApp(),
        duration: 2500,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DimodoState();
  }
}

class DimodoState extends State<MyApp> with AfterLayoutMixin {
  final _app = AppModel();
  final _product = ProductModel();
  final _category = CategoryModel();
  final _wishlist = WishListModel();
  final _user = UserModel();
  final _productDetail = ProductDetail();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _order = OrderModel();
  final _search = SearchModel();
  final _recent = RecentModel();
  bool isFirstSeen = false;
  bool isChecking = true;
  bool isLoggedIn = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    Services().setAppConfig(serverConfig);
    _app.loadAppConfig();

    isFirstSeen = await checkFirstSeen();
    isLoggedIn = await checkLogin();
    setState(() {
      isChecking = false;
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen)
      return false;
    else {
      prefs.setBool('seen', true);
      return true;
    }
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  Widget renderFirstScreen() {
    if (isFirstSeen) return OnBoardScreen();
    if (kAdvanceConfig['IsRequiredLogin'] && !isLoggedIn) return LoginScreen();
    return MainTabs();
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(),
        ),
      );
    }

    return ChangeNotifierProvider<AppModel>.value(
      value: _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Container(
              color: Colors.white,
            );
          }
          return MultiProvider(
            providers: [
              Provider<ProductModel>.value(value: _product),
              Provider<CategoryModel>.value(value: _category),
              Provider<UserModel>.value(value: _user),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<ShippingMethodModel>.value(value: _shippingMethod),
              Provider<PaymentMethodModel>.value(value: _paymentMethod),
              Provider<OrderModel>.value(value: _order),
              Provider<SearchModel>.value(value: _search),
              Provider<RecentModel>.value(value: _recent),
              ChangeNotifierProvider(create: (_) => AddressModel()),
              ChangeNotifierProvider(create: (_) => UserModel()),
              ChangeNotifierProvider(create: (_) => CartModel()),
              ChangeNotifierProvider(create: (_) => CategoryModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: new Locale(
                  Provider.of<AppModel>(context, listen: false).locale, ""),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              localeListResolutionCallback:
                  S.delegate.listResolution(fallback: const Locale('en', '')),
              home: renderFirstScreen(),
              onGenerateRoute: (settings) {
                final arguments = settings.arguments;
                switch (settings.name) {
                  case '/add_address':
                    if (arguments is Address) {
                      print("arguments: ${arguments.toJson}");
                      // the details page for one specific user
                      return MaterialPageRoute<bool>(
                          builder: (BuildContext context) => ShippingAddress(
                                address: arguments,
                              ));
                    } else {
                      // a route showing the list of all users
                      return MaterialPageRoute<bool>(
                          builder: (BuildContext context) => ShippingAddress());
                    }
                    break;

                  default:
                    return null;
                }
              },
              routes: <String, WidgetBuilder>{
                "/home": (context) => MainTabs(),
                "/login": (context) => LoginScreen(),
                "/register": (context) => SignupScreen(),
                "/cart": (context) => CartScreen(),
                // '/wishlist': (context) => WishList(),
                // '/checkout': (context) => Checkout(),
                '/orders': (context) => OrdersScreen(),
                '/order_submitted': (context) => OrderSubmitted(),
                '/manage_address': (context) => ManageShippingScreen(),

                // '/notify': (context) => Notifications(),
                '/setting': (context) => SettingScreen(),
                '/category': (context) => CategoryScreen(),
                // '/add_address': (context) => ShippingAddress(),

                '/sub_category': (context) => SubCategoryScreen(),
                '/forgot_password': (context) => ForgotPasswordScreen(),
                '/reset_password': (context) => ResetPasswordScreen(),
              },
              theme: Provider.of<AppModel>(context, listen: false).darkTheme
                  ? buildDarkTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"]))
                  : buildLightTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"])),
            ),
          );
        },
      ),
    );
  }
}