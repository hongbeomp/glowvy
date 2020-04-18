import 'package:Dimodo/models/order/cartItem.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../product/product.dart';
import '../product/product.dart';
import '../address/address.dart';
import '../user/userModel.dart';
import '../address/billing.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../services/index.dart';
import '../../common/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartModel with ChangeNotifier {
  CartModel() {
    updateFees();
  }

  Address address;
  Billing billing;
  String currency;
  double shippingFeePerItem = 70000;
  double totalShippingFee = 0;
  double totalServiceFee = 0;
  double totalImportTax = 0;
  double subTotalFee = 0;
  double totalFee = 0;
  double subTotal = 0;
  Services _services = Services();

  // The productIDs and product Object currently in the cart.
  Map<int, CartItem> cartItems = {};

  // The IDs and quantities of products currently in the cart.

  int get totalCartQuantity =>
      cartItems.values.fold(0, (v, e) => v + e.quantity);

  // ===========================================================================
  // CART Manipulation
  // ===========================================================================
  // Adds a product to the cart.
  void addProductToCart(
      {CartItem cartItem, UserModel userModel, isSaveLocal = true}) async {
    var key = cartItem.optionId;
    print("Adding this product: ${cartItem.product.salePrice}");
    if (!cartItems.containsKey(key)) {
      cartItems[key] = cartItem;
      cartItems[key].quantity = cartItem.quantity;
    } else {
      cartItems[key].quantity += cartItem.quantity;
    }
    var count = await _services.createCartItem(cartItem, userModel);

    notifyListeners();
  }

  void addCartItems(Map<int, CartItem> cartItems) {
    this.cartItems = cartItems;
    updateFees();
  }

  void updateQuantity(int key, int quantity, UserModel userModel) async {
    if (cartItems.containsKey(key)) {
      cartItems[key].quantity = quantity;
      updateQuantityCartLocal(key: key, quantity: quantity);
      var count = await _services.updateCartItem(cartItems[key], userModel);
      updateFees();
      notifyListeners();
    }
  }

  // Removes an item from the cart.
  void removeItemFromCart(int key, UserModel userModel) async {
    if (cartItems.containsKey(key)) {
      removeProductLocal(key);
      if (cartItems[key].quantity == 1) {
        var count = await _services.deleteCartItem(cartItems[key], userModel);

        cartItems.remove(key);
      } else {
        cartItems[key].quantity--;
      }
    }

    notifyListeners();
  }

  // Returns the Product instance matching the provided id.
  CartItem getCartItemById(int id) {
    return cartItems[id];
  }

  // Removes everything from the cart.
  void clearCart() {
    clearCartLocal();
    cartItems.clear();
    notifyListeners();
  }

  void updateFees() async {
    // getShippingAddress();
    getCartDataFromLocal();
    getCurrency();
    getShippingFee();
    // getImportTax();
    getSubTotal();
    getServiceFee();
    getTotal();
  }

  Future<CartModel> getAllCartItems(UserModel userModel) async {
    if (userModel.isLoggedIn) {
      var items = await _services.allCartItems(userModel);
      if (items != null) {
        items.forEach((item) {
          cartItems[item.optionId] = item;
        });
      }
    }
    notifyListeners();

    return this;
  }

  void saveCartToLocal(CartItem cartItem) async {
    final LocalStorage storage = new LocalStorage("Dimodo");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.add(cartItem.toJson());
        } else {
          items = [cartItem.toJson()];
        }
        await storage.setItem(kLocalKey["cart"], items);
      }
    } catch (err) {
      print(err);
    }
  }

  void updateQuantityCartLocal({int key, int quantity = 1}) async {
    final LocalStorage storage = new LocalStorage("Dimodo");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        List results = [];
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            //update cartItem
            var cartItem = CartItem.fromJson(item);
            cartItem.quantity = quantity;

            results.add(cartItem.toJson());
          }
        }
        await storage.setItem(kLocalKey["cart"], results);
      }
    } catch (err) {
      print(err);
    }
  }

  void getCartDataFromLocal() async {
    final LocalStorage storage = new LocalStorage("Dimodo");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.forEach((item) {
            addProductToCart(
                cartItem: CartItem.fromJson(item["cart"]), isSaveLocal: false);
          });
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void clearCartLocal() async {
    final LocalStorage storage = new LocalStorage("Dimodo");
    try {
      final ready = await storage.ready;
      if (ready) {
        storage.deleteItem(kLocalKey["cart"]);
      }
    } catch (err) {
      print(err);
    }
  }

  void removeProductLocal(int key) async {
    final LocalStorage storage = new LocalStorage("Dimodo");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            //update cartItem
            var cartItem = CartItem.fromJson(item);
            if (item != null) {
              if (item["quantity"] == 1) {
                items.remove(item);
              } else {
                item["quantity"]--;
              }
            }
          }
          await storage.setItem(kLocalKey["cart"], items);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future getCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  void changeCurrency(value) {
    currency = value;
  }
  // ===========================================================================
  // FEEs
  // ===========================================================================

  double getSubTotal() {
    subTotal = cartItems.keys.fold(0.0, (sum, key) {
      String price =
          Tools.getPriceProductValue(cartItems[key].product, currency);
      // print("subtotal item price: $price");
      if (price.isNotEmpty) {
        subTotalFee = sum + double.parse(price) * cartItems[key].quantity;
        return subTotalFee;
      }
      return sum;
    });
    subTotalFee = subTotal;
    print("subtotal??? $subTotal");
    return subTotal;
  }

  double getServiceFee() {
    totalServiceFee = subTotalFee * 0.08;
    return totalServiceFee;
  }

  double getShippingFee() {
    totalShippingFee = totalCartQuantity * shippingFeePerItem;
    return totalShippingFee;
  }

  double getTotal() {
    // print("subTotal: $subTotalFee");
    totalFee = getSubTotal() + getServiceFee() + getShippingFee();
    // print("getTotal: $totalFee");

    return totalFee;
  }

  double getImportTax() {
    double importTaxPerItem = 16000;
    totalImportTax = totalCartQuantity * importTaxPerItem;
    return totalImportTax;
  }
}
