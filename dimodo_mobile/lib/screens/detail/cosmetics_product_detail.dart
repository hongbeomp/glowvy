import 'package:Dimodo/models/review.dart';
import 'package:Dimodo/models/reviews.dart';
import 'package:Dimodo/screens/detail/cosmetics_image_feature.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/styles.dart';
import '../../common/constants.dart';
import '../../models/product/product.dart';
import '../../models/app.dart';
import '../../models/product/productModel.dart';
import 'product_title.dart';
import 'package:Dimodo/widgets/customWidgets.dart';
import 'package:Dimodo/generated/i18n.dart';
import 'productOption.dart';
import 'image_feature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'reviewScreen.dart';
import 'review_card.dart';
import 'cartAction.dart';
import 'cosmetics_product_description.dart';
import '../../services/index.dart';
import '../../models/order/cart.dart';
import 'package:Dimodo/common/tools.dart';

class CosmeticsProductDetail extends StatefulWidget {
  final Product product;

  CosmeticsProductDetail({this.product});

  @override
  _CosmeticsProductDetailState createState() => _CosmeticsProductDetailState();
}

class _CosmeticsProductDetailState extends State<CosmeticsProductDetail> {
  bool isLoading = false;
  Size screenSize;
  var bottomPopupHeightFactor;
  final services = Services();

  List<String> tabList = [];
  Reviews metaReviews =
      Reviews(totalCount: 0, averageSatisfaction: 100, reviews: <Review>[]);

  bool isLoggedIn = false;
  int offset = 0;
  int limit = 3;
  ProductModel productModel;
  @override
  void initState() {
    super.initState();
    print("product name: ${widget.product.name}");
    // services.getReviews(widget.product.sid, offset, limit).then((onValue) {
    //   if (this.mounted) {
    //     setState(() {
    //       metaReviews = onValue;
    //     });
    //     offset += 3;
    //   }
    // });
    productModel = Provider.of<ProductModel>(context, listen: false);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Future<bool> getReviews() async {
  //   var loadedReviews =
  //       await services.getReviews(widget.product.sid, offset, limit);
  //   if (loadedReviews.reviews == null) {
  //     return true;
  //   } else if (loadedReviews.reviews.length == 0) {
  //     return true;
  //   }
  //   setState(() {
  //     isLoading = false;
  //     loadedReviews.reviews.forEach((element) {
  //       metaReviews.reviews.add(element);
  //     });
  //     //
  //   });
  //   offset += 3;
  //   return false;
  // }

  List<Widget> renderTabViews(Product product) {
    List<Widget> tabViews = [];

    tabList.asMap().forEach((index, name) {
      tabViews.add(SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          // This Builder is needed to provide a BuildContext that is "inside"
          // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
          // find the NestedScrollView.
          builder: (BuildContext context) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // The "controller" and "primary" members should be left
              // unset, so that the NestedScrollView can control this
              // inner scroll view.
              // If the "controller" property is set, then this scroll
              // view will not be associated with the NestedScrollView.
              // The PageStorageKey should be unique to this ScrollView;
              // it allows the list to remember its scroll position when
              // the tab view is not on the screen.
              key: PageStorageKey<String>(name),
              slivers: <Widget>[
                SliverOverlapInjector(
                  // This is the flip side of the SliverOverlapAbsorber above.
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int i) {
                      if (index == 0)
                        return CosmeticsProductDescription(product);
                      if (index == 1)
                        return productModel.showProductListByCategory(
                            cateId: 7,
                            sortBy: "sale_price",
                            limit: 200,
                            context: context);
                      // if (index == 2)
                      //   return ProductModel.showProductListByCategory(
                      //       cateId: 7, context: context);
                    },
                    childCount: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ));
    });
    return tabViews;
  }

  Future<void> showShippingInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user can tap anywhere to dismiss the popup!
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: DynamicText(
            S.of(context).shippingFeePolicy,
            style: kBaseTextStyle,
          ),
          actions: <Widget>[
            FlatButton(
              child: DynamicText(
                'Ok',
                style: kBaseTextStyle,
              ),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var cartModel = Provider.of<CartModel>(context);
    screenSize = MediaQuery.of(context).size;
    try {
      tabList = [];
      final tabs = Provider.of<AppModel>(context, listen: false)
          .appConfig['Tabs'] as List;
      for (var tab in tabs) {
        tabList.add(tab["name"]);
      }
    } catch (err) {
      isLoading = false;
      var message =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();

      print("error: $message");
    }

    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            bottom: false,
            top: false,
            child: Scaffold(
                //todo: check whether the item is loaded or not
                bottomNavigationBar: widget.product != null
                    ? ProductOption(widget.product, isLoggedIn)
                    : null,
                backgroundColor: Colors.white,
                body: DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      physics: ScrollPhysics(parent: BouncingScrollPhysics()),
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        var reviewHeight =
                            metaReviews.totalCount == 0 ? 0 : 110;

                        return [
                          SliverOverlapAbsorber(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                            child: SliverAppBar(
                              expandedHeight: screenSize.height * 0.52 * 0.7 +
                                  //title static heigt (31) and font sizes total 41 and 0.9 is the number for the height of the font
                                  //52 is the fontsizes of the service container texts.
                                  //115 is the static height of the service contaienr
                                  //40 is the tabbar height
                                  356 +
                                  reviewHeight,
                              brightness: Brightness.light,
                              leading: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 30,
                                  child: IconButton(
                                    icon: CommonIcons.arrowBackward,
                                  ),
                                ),
                              ),
                              actions: <Widget>[CartAction()],
                              backgroundColor: Colors.white,
                              pinned: true,
                              floating: false,
                              flexibleSpace: widget.product == null
                                  ? Container(
                                      height: kScreenSizeHeight,
                                      child: SpinKitThreeBounce(
                                          color: kPinkAccent,
                                          size: 23.0 *
                                              kSizeConfig.containerMultiplier),
                                    )
                                  : FlexibleSpaceBar(
                                      collapseMode: CollapseMode.pin,
                                      background: Column(
                                        children: <Widget>[
                                          CosmeticsImageFeature(
                                            widget.product,
                                          ),
                                          Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  ProductTitle(widget.product,
                                                      widget.product.name),
                                                  Container(
                                                    height: 5,
                                                    width: screenSize.width,
                                                    color: kDefaultBackground,
                                                  ),
                                                  Container(
                                                    width: screenSize.width,
                                                    color: Colors.white,
                                                    padding: EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        top: 20,
                                                        bottom: 20),
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          showShippingInfo(),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          DynamicText(
                                                              S
                                                                  .of(context)
                                                                  .shipFromKorea,
                                                              style: kBaseTextStyle.copyWith(
                                                                  fontSize: 13,
                                                                  color:
                                                                      kDarkSecondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          DynamicText(
                                                              S
                                                                      .of(
                                                                          context)
                                                                      .koreanShippingFee +
                                                                  "${Tools.getCurrecyFormatted(cartModel.calculateShippingFee(widget.product))}",
                                                              style: kBaseTextStyle.copyWith(
                                                                  fontSize: 12,
                                                                  color:
                                                                      kDarkAccent,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          SizedBox(height: 20),
                                                          DynamicText(
                                                              S
                                                                  .of(context)
                                                                  .importTaxIncluded,
                                                              style: kBaseTextStyle.copyWith(
                                                                  fontSize: 13,
                                                                  color:
                                                                      kDarkSecondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          DynamicText(
                                                              S
                                                                  .of(context)
                                                                  .importTaxFeeDescription,
                                                              style: kBaseTextStyle.copyWith(
                                                                  fontSize: 12,
                                                                  color:
                                                                      kDarkAccent,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 5,
                                                    width: screenSize.width,
                                                    color: kDefaultBackground,
                                                  ),
                                                  // GestureDetector(
                                                  //     onTap: () => Navigator.push(
                                                  //         context,
                                                  //         MaterialPageRoute(
                                                  //             builder: (context) =>
                                                  //                 ReviewScreen(
                                                  //                     metaReviews,
                                                  //                     getReviews))),
                                                  //     child: !isLoading
                                                  //         ? Container(
                                                  //             width:
                                                  //                 screenSize
                                                  //                     .width,
                                                  //             color: Colors
                                                  //                 .white,
                                                  //             child: Column(
                                                  //               children: <
                                                  //                   Widget>[
                                                  //                 Container(
                                                  //                   height:
                                                  //                       56,
                                                  //                   padding:
                                                  //                       EdgeInsets.symmetric(horizontal: 16),
                                                  //                   child:
                                                  //                       Row(
                                                  //                     children: <
                                                  //                         Widget>[
                                                  //                       DynamicText("${S.of(context).reviews} (${metaReviews.totalCount})",
                                                  //                           style: kBaseTextStyle.copyWith(fontSize: 12, color: kDarkSecondary, fontWeight: FontWeight.w600)),
                                                  //                       Spacer(),
                                                  //                       if (metaReviews.totalCount !=
                                                  //                           0)
                                                  //                         Row(
                                                  //                           crossAxisAlignment: CrossAxisAlignment.center,
                                                  //                           children: <Widget>[
                                                  //                             DynamicText(S.of(context).satisfaction + " ${metaReviews.averageSatisfaction}%", style: kBaseTextStyle.copyWith(fontSize: 12, color: kPinkAccent, fontWeight: FontWeight.w600)),
                                                  //                             CommonIcons.arrowForwardPink
                                                  //                           ],
                                                  //                         ),
                                                  //                     ],
                                                  //                   ),
                                                  //                 ),
                                                  //                 SizedBox(
                                                  //                     height:
                                                  //                         5),
                                                  //                 if (metaReviews
                                                  //                         .totalCount !=
                                                  //                     0)
                                                  //                   Padding(
                                                  //                     padding:
                                                  //                         const EdgeInsets.symmetric(horizontal: 10.0),
                                                  //                     child: ReviewCard(
                                                  //                         isPreview: true,
                                                  //                         context: context,
                                                  //                         review: metaReviews.reviews[0]),
                                                  //                   ),
                                                  //                 Container(
                                                  //                   height:
                                                  //                       5,
                                                  //                   width:
                                                  //                       kScreenSizeWidth,
                                                  //                   color:
                                                  //                       kDefaultBackground,
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           )
                                                  //         : Container(
                                                  //             width:
                                                  //                 screenSize
                                                  //                     .width,
                                                  //             height: 90,
                                                  //             child: CupertinoActivityIndicator(
                                                  //                 animating:
                                                  //                     true),
                                                  //           )),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                              bottom: widget.product == null
                                  ? null
                                  : TabBar(
                                      labelPadding:
                                          EdgeInsets.symmetric(horizontal: 0.0),
                                      isScrollable: false,
                                      indicatorColor: kPinkAccent,
                                      unselectedLabelColor: Colors.black,
                                      unselectedLabelStyle: kBaseTextStyle
                                          .copyWith(color: kDarkSecondary),
                                      labelStyle: kBaseTextStyle,
                                      labelColor: kPinkAccent,
                                      onTap: (index) {
                                        setState(() {});
                                      },
                                      tabs: renderTabbar(),
                                    ),
                            ),
                          )
                        ];
                      },
                      body: (widget.product == null)
                          ? Container(
                              height: 1,
                            )
                          : TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: renderTabViews(widget.product)),
                    )))));
  }

  List<Widget> renderTabbar() {
    List<Widget> list = [];

    tabList.asMap().forEach((index, item) {
      list.add(Container(
        alignment: Alignment.center,
        height: 40,
        child: Tab(
          text: item,
        ),
      ));
    });
    return list;
  }
}