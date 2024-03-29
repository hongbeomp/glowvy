import 'package:Dimodo/common/colors.dart';
import 'package:Dimodo/common/constants.dart';
import 'package:Dimodo/common/widgets.dart';
import 'package:Dimodo/models/category.dart';
import 'package:Dimodo/models/product/brand.dart';
import 'package:Dimodo/models/product/product_model.dart';
import 'package:Dimodo/models/product/review_model.dart';
import 'package:Dimodo/screens/error_indicator.dart';
import 'package:Dimodo/widgets/cosmetics_request_button.dart';
import 'package:Dimodo/widgets/product/product_card.dart';
import 'package:Dimodo/widgets/product/cosmetics_review_thumb_card.dart';
import 'package:Dimodo/widgets/product/list_page.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../models/product/product.dart';

class PaginatedProductListView extends StatefulWidget {
  final ListPage<Product> initialPage;

  final Brand brand;
  final Category category;

  final bool showRank;
  final bool isFromReviewSearch;
  final dynamic fetchProducts;
  final ListPreferences listPreferences;
  final bool showPadding;
  final bool showNoMoreItemsIndicator;
  final bool disableSrolling;
  final bool saveHistory;

  final Function onProductTap;

  const PaginatedProductListView({
    this.initialPage,
    this.showRank = false,
    this.isFromReviewSearch = false,
    this.brand,
    this.category,
    this.fetchProducts,
    this.listPreferences,
    this.showPadding = false,
    this.disableSrolling = false,
    this.saveHistory = false,
    this.showNoMoreItemsIndicator = true,
    this.onProductTap,
  });

  @override
  _PaginatedProductListViewState createState() =>
      _PaginatedProductListViewState();
}

class _PaginatedProductListViewState extends State<PaginatedProductListView>
    with AfterLayoutMixin {
  ProductModel productModel;
  final _pagingController = PagingController<int, Product>(firstPageKey: 0);

  @override
  void initState() {
    super.initState();

    productModel = Provider.of<ProductModel>(context, listen: false);
    productModel.clearPaginationHistory();

    _pagingController.addPageRequestListener((pageKey) {
      print('listen');
      _fetchPage(pageKey);
    });
  }

  @override
  void didUpdateWidget(PaginatedProductListView oldWidget) {
    // if (oldWidget.listPreferences != widget.listPreferences) {
    //   _pagingController.refresh();
    // }
    // if (oldWidget.initialPage != widget.initialPage) {
    //   _pagingController.refresh();
    // }
    if (oldWidget.brand != widget.brand) {
      _pagingController.refresh();
    }
    if (oldWidget.category != widget.category) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    print('fetching new page..');

    if (_pagingController.nextPageKey != null) {
      try {
        ListPage<Product> newPage;
        if (widget.brand != null) {
          newPage = await productModel.getProductsByBrand(widget.brand);
        } else if (widget.category != null) {
          newPage = await productModel.getProductsByCategory(widget.category);
        }

        if (newPage != null) {
          final isLastPage = newPage.itemList.isEmpty ||
              newPage.itemList.length < 10 ||
              newPage.isLastPage(_pagingController?.itemList?.length ?? 0);
          if (isLastPage) {
            print('last page');
            _pagingController.appendLastPage(newPage.itemList);
          } else {
            print('added new page');
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(newPage.itemList, nextPageKey);
          }
        } else {
          print('new page is null');
        }
      } catch (error) {
        print(error);
        _pagingController.error = error;
      }
    }
  }

  showIndicator() {
    //1. start timer
    //2. if the result is not loaded, setState and show indicator
    //3. else, containe
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final paginatedListView = PagedListView.separated(
      addAutomaticKeepAlives: false,
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: widget.disableSrolling
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      builderDelegate: PagedChildBuilderDelegate<Product>(
          itemBuilder: (context, product, index) {
            return ProductCard(
              ranking: widget.showRank ? index : null,
              showDivider: index != _pagingController.itemList.length - 1,
              product: product,
              saveHistory: widget.saveHistory,
            );
          },
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                error: _pagingController.error,
                onTryAgain: () => _pagingController.refresh(),
              ),
          noItemsFoundIndicatorBuilder: (context) => Column(
                children: [
                  Container(height: 41),
                  Center(
                    child: Text(
                      'không tìm thấy sản phẩm',
                      style: textTheme.bodyText2.copyWith(color: kTertiaryGray),
                    ),
                  ),
                  CosmeticsRequestBtn(),
                ],
              ),
          noMoreItemsIndicatorBuilder: (context) =>
              widget.showNoMoreItemsIndicator &&
                      _pagingController.itemList.length > 4
                  ? Padding(
                      padding: const EdgeInsets.only(top: 28.0, bottom: 28),
                      child: SvgPicture.asset(
                        'assets/icons/heart-ballon.svg',
                        width: 30,
                        height: 42,
                      ),
                    )
                  : Container(),
          firstPageProgressIndicatorBuilder: (context) => Container(
              width: screenSize.width,
              height: screenSize.height / 3,
              child: Center(child: kIndicator())),
          newPageProgressIndicatorBuilder: (context) => Container(
                height: screenSize.height / 10,
                child: Center(child: kIndicator()),
              )),
      pagingController: _pagingController,
      padding: widget.showPadding
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.zero,
      separatorBuilder: (context, index) => const SizedBox(
        height: 0,
      ),
    );

    return widget.disableSrolling
        ? paginatedListView
        : Scrollbar(
            thickness: kScrollbarThickness,
            child: paginatedListView,
          );
  }
}
