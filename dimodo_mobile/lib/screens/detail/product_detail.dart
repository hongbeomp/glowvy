import 'package:Dimodo/models/review.dart';
import 'package:Dimodo/models/reviews.dart';
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
import 'product_description.dart';
import '../../services/index.dart';
import '../../models/order/cart.dart';
import 'package:Dimodo/common/tools.dart';

class ProductDetail extends StatefulWidget {
  final Product product;

  ProductDetail({this.product});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool isLoading = false;
  Size screenSize;
  var bottomPopupHeightFactor;
  final services = Services();

  List<String> tabList = [];
  Reviews metaReviews =
      Reviews(totalCount: 0, averageSatisfaction: 100, reviews: <Review>[]);

  Future<Product> product;
  bool isLoggedIn = false;
  int offset = 0;
  int limit = 3;
  ProductModel productModel;
  @override
  void initState() {
    super.initState();
    services.getReviews(widget.product.sid, offset, limit).then((onValue) {
      if (this.mounted) {
        setState(() {
          metaReviews = onValue;
        });
        offset += 3;
      }
    });
    productModel = Provider.of<ProductModel>(context, listen: false);
  }

  void didChangeDependencies() {
    product =
        Provider.of<ProductModel>(context).getProduct(id: widget.product.sid);
    super.didChangeDependencies();
  }

  Future<bool> getReviews() async {
    var loadedReviews =
        await services.getReviews(widget.product.sid, offset, limit);
    if (loadedReviews.reviews == null) {
      return true;
    } else if (loadedReviews.reviews.length == 0) {
      return true;
    }
    setState(() {
      isLoading = false;
      loadedReviews.reviews.forEach((element) {
        metaReviews.reviews.add(element);
      });
      //
    });
    offset += 3;
    return false;
  }

  // List<Widget> renderTabViews(Product product) {
  //   List<Widget> tabViews = [];

  //   tabList.asMap().forEach((index, name) {
  //     tabViews.add(SafeArea(
  //       top: false,
  //       bottom: false,
  //       child: Builder(
  //         // This Builder is needed to provide a BuildContext that is "inside"
  //         // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
  //         // find the NestedScrollView.
  //         builder: (BuildContext context) {
  //           return CustomScrollView(
  //             physics: const AlwaysScrollableScrollPhysics(),
  //             // The "controller" and "primary" members should be left
  //             // unset, so that the NestedScrollView can control this
  //             // inner scroll view.
  //             // If the "controller" property is set, then this scroll
  //             // view will not be associated with the NestedScrollView.
  //             // The PageStorageKey should be unique to this ScrollView;
  //             // it allows the list to remember its scroll position when
  //             // the tab view is not on the screen.
  //             key: PageStorageKey<String>(name),
  //             slivers: <Widget>[
  //               SliverOverlapInjector(
  //                 // This is the flip side of the SliverOverlapAbsorber above.
  //                 handle:
  //                     NestedScrollView.sliverOverlapAbsorberHandleFor(context),
  //               ),
  //               SliverList(
  //                 delegate: SliverChildBuilderDelegate(
  //                   (BuildContext context, int i) {
  //                     if (index == 0) return ProductDescription(product);
  //                     if (index == 1)
  //                       return productModel.showProductListByCategory(
  //                           cateId: 7,
  //                           sortBy: "sale_price",
  //                           limit: 200,
  //                           context: context);
  //                     // if (index == 2)
  //                     //   return ProductModel.showProductListByCategory(
  //                     //       cateId: 7, context: context);
  //                   },
  //                   childCount: 1,
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ));
  //   });
  //   return tabViews;
  // }

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
          child: FutureBuilder<Product>(
              future: product,
              builder: (BuildContext context, AsyncSnapshot<Product> snapshot) {
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    elevation: 0,
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
                    backgroundColor: Colors.transparent,
                  ),
                  //todo: check whether the item is loaded or not
                  bottomNavigationBar: snapshot.data != null
                      ? ProductOption(snapshot.data, isLoggedIn)
                      : null,
                  backgroundColor: Colors.white,

                  body: (snapshot.data == null)
                      ? Container(
                          height: 1,
                        )
                      : ListView(
                          padding: EdgeInsets.only(top: 0),
                          children: <Widget>[
                            ImageFeature(
                              snapshot.data,
                            ),
                            Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ProductTitle(
                                      snapshot.data,
                                    ),
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
                                        onTap: () => showShippingInfo(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            DynamicText(
                                                S.of(context).shipFromKorea,
                                                style: kBaseTextStyle.copyWith(
                                                    fontSize: 13,
                                                    color: kDarkSecondary,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            DynamicText(
                                                S
                                                        .of(context)
                                                        .koreanShippingFee +
                                                    "${Tools.getCurrecyFormatted(cartModel.calculateShippingFee(snapshot.data))}",
                                                style: kBaseTextStyle.copyWith(
                                                    fontSize: 12,
                                                    color: kDarkAccent,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            SizedBox(height: 20),
                                            DynamicText(
                                                S.of(context).importTaxIncluded,
                                                style: kBaseTextStyle.copyWith(
                                                    fontSize: 13,
                                                    color: kDarkSecondary,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            DynamicText(
                                                S
                                                    .of(context)
                                                    .importTaxFeeDescription,
                                                style: kBaseTextStyle.copyWith(
                                                    fontSize: 12,
                                                    color: kDarkAccent,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 5,
                                      width: screenSize.width,
                                      color: kDefaultBackground,
                                    ),
                                    GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReviewScreen(metaReviews,
                                                        getReviews))),
                                        child: !isLoading
                                            ? Container(
                                                width: screenSize.width,
                                                color: Colors.white,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      height: 56,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16),
                                                      child: Row(
                                                        children: <Widget>[
                                                          DynamicText(
                                                              "${S.of(context).reviews} (${metaReviews.totalCount})",
                                                              style: kBaseTextStyle.copyWith(
                                                                  fontSize: 12,
                                                                  color:
                                                                      kDarkSecondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          Spacer(),
                                                          if (metaReviews
                                                                  .totalCount !=
                                                              0)
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                DynamicText(
                                                                    S.of(context).satisfaction +
                                                                        " ${metaReviews.averageSatisfaction}%",
                                                                    style: kBaseTextStyle.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            kPinkAccent,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
                                                                CommonIcons
                                                                    .arrowForwardPink
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    if (metaReviews
                                                            .totalCount !=
                                                        0)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        child: ReviewCard(
                                                            isPreview: true,
                                                            context: context,
                                                            review: metaReviews
                                                                .reviews[0]),
                                                      ),
                                                    Container(
                                                      height: 5,
                                                      width: kScreenSizeWidth,
                                                      color: kDefaultBackground,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                width: screenSize.width,
                                                height: 90,
                                                child:
                                                    CupertinoActivityIndicator(
                                                        animating: true),
                                              )),
                                  ],
                                )),
                            ProductDescription(snapshot.data),
                          ],
                        ),
                );
              }),
        ));
  }
}
