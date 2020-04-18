import 'package:Dimodo/screens/category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Dimodo/common/sizeConfig.dart';
import 'package:provider/provider.dart';
import 'common/config.dart' as config;
import 'common/constants.dart';
import 'models/order/cart.dart';
import 'models/category.dart';
import 'models/product/productModel.dart';
import 'screens/cart.dart';
import 'screens/home.dart';
import 'screens/user.dart';
import 'models/app.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'common/styles.dart';

class MainTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainTabsState();
  }
}

class MainTabsState extends State<MainTabs> with AfterLayoutMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  int currentPage = 0;
  String currentTitle = "Home";
  Color currentColor = Colors.deepPurple;
  bool isAdmin = false;
  List<Widget> _tabView = [];

  @override
  void afterFirstLayout(BuildContext context) {
    print("after first layout!!");
    loadTabBar();
    Provider.of<CategoryModel>(context, listen: false).getLocalCategories(
        context,
        lang: Provider.of<AppModel>(context, listen: false).locale);
  }

  Widget tabView(Map<String, dynamic> data) {
    switch (data['layout']) {
      case 'category':
        return CategoryScreen();
      case 'cart':
        return CartScreen();
      case 'profile':
        return UserScreen();
      case 'dynamic':
      default:
        return HomeScreen();
    }
  }

  void loadTabBar() {
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig['TabBar'] as List;
    for (var i = 0; i < tabData.length; i++) {
      setState(() {
        _tabView.add(tabView(Map.from(tabData[i])));
      });
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  List showCategories() {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    List<Widget> widgets = [];

    if (categories != null) {
      var list = categories.where((item) => item.parent == 0).toList();
      for (var index in list) {
        widgets.add(
          ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                index.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            children: getChildren(categories, index),
          ),
        );
      }
    }
    return widgets;
  }

  List getChildren(List<Category> categories, Category category) {
    List<Widget> list = [];
    var children = categories.where((o) => o.parent == category.id).toList();
    if (children.length == 0) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(category.name),
            padding: EdgeInsets.only(left: 20),
          ),
          onTap: () {
            ProductModel.showList(
                context: context, cateId: category.id, cateName: category.name);
          },
        ),
      );
    }
    return list;
  }

  bool checkIsAdmin() {
    if (loggedInUser.email == config.adminEmail) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    return isAdmin;
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    kSizeConfig = SizeConfig(screenSize);

    if (_tabView.length < 1) return Container();

    return Container(
        color: Colors.white,
        child: DefaultTabController(
          length: _tabView.length,
          child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: _tabView,
            ),
            bottomNavigationBar: Container(
              color: Colors.white,
              width: screenSize.width,
              child: SafeArea(
                bottom: true,
                child: FittedBox(
                  child: Container(
                    // padding: EdgeInsets.only(
                    //     bottom: MediaQuery.of(context).padding.bottom),
                    height: 50,
                    color: Colors.white,
                    width: screenSize.width /
                        (2 / (screenSize.height / screenSize.width)),
                    child: TabBar(
                      onTap: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      tabs: renderTabbar(),
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.white,
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  List<Widget> renderTabbar() {
    var totalCart =
        Provider.of<CartModel>(context, listen: false).totalCartQuantity;
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig['TabBar'] as List;
    List<Widget> list = [];

    tabData.asMap().forEach((index, item) {
      // final isAssetIcon = item["icon"].toString().contains("assets");
      list.add(Tab(
          // iconMargin: EdgeInsets.only(bottom: 0),
          child: Stack(children: <Widget>[
        Container(
          width: 35,
          padding: const EdgeInsets.all(6.0),
          child: SvgPicture.asset(
            currentPage == index ? item["active-icon"] : item["icon"],
            // color:  ? Colors.black : kDarkSecondary,
            width: 24 * kSizeConfig.containerMultiplier,
            height: 24 * kSizeConfig.containerMultiplier,
          ),
        ),
        if (totalCart > 0 && item["layout"] == "cart")
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 20,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 15,
              ),
              child: Text(
                totalCart.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ])));
    });

    return list;
  }
}