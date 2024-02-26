import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Ecommerce_app/models/favorite_model.dart';
import 'package:Ecommerce_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../repositories/cart_repositories.dart';
import '../../viewmodels/global_ui_viewmodel.dart';
import '../../viewmodels/single_product_viewmodel.dart';

class SingleProductScreen extends StatefulWidget {
  const SingleProductScreen({Key? key}) : super(key: key);

  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleProductViewModel>(
      create: (_) => SingleProductViewModel(),
      child: SingleProductBody(),
    );
  }
}

class SingleProductBody extends StatefulWidget {
  const SingleProductBody({Key? key}) : super(key: key);

  @override
  State<SingleProductBody> createState() => _SingleProductBodyState();
}

class _SingleProductBodyState extends State<SingleProductBody> {
  late SingleProductViewModel _singleProductViewModel;
  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;
  String? productId;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _singleProductViewModel = Provider.of<SingleProductViewModel>(context, listen: false);
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
      final args = ModalRoute.of(context)!.settings.arguments.toString();
      setState(() {
        productId = args;
      });
      print(args);
      getData(args);
    });
    super.initState();
  }

  Future<void> getData(String productId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.getFavoritesUser();
      await _singleProductViewModel.getProducts(productId);
    } catch (e) {}
    _ui.loadState(false);
  }

  Future<void> favoritePressed(FavoriteModel? isFavorite, String productId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.favoriteAction(isFavorite, productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Favorite updated.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong. Please try again.")));
      print(e);
    }
    _ui.loadState(false);
  }

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer2<SingleProductViewModel, AuthViewModel>(
      builder: (context, singleProductVM, authVm, child) {
        return singleProductVM.product == null
            ? Scaffold(
          body: Container(
            child: Text("Error"),
          ),
        )
            : singleProductVM.product!.id == null
            ? Scaffold(
          body: Center(
            child: Container(
              child: Text("Please wait..."),
            ),
          ),
        )
            : Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            height: 70,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border(
                top: BorderSide(width: 1, color: Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (quantity > 1) {
                        quantity -= 1;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.remove,
                      size: 24,
                      color: Colors.green,
                    ),
                  ),
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      quantity += 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.green,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    CartRepository()
                        .addToCart(singleProductVM.product!, quantity)
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to cart sucessfully")));
                    });
                  },
                  child: Text(
                    "Add to cart",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Color(0xFFE6E6E6),
            actions: [
              Builder(builder: (context) {
                FavoriteModel? isFavorite;
                try {
                  isFavorite = authVm.favorites.firstWhere(
                          (element) => element.productId == singleProductVM.product!.id);
                } catch (e) {}

                return IconButton(
                  onPressed: () {
                    print(singleProductVM.product!.id!);
                    favoritePressed(isFavorite, singleProductVM.product!.id!);
                  },
                  icon: Icon(
                    Icons.favorite,
                    size: 30, // Increased icon size
                    color: isFavorite != null ? Colors.red : Colors.grey,
                  ),
                );
              })
            ],
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  singleProductVM.product!.imageUrl.toString(),
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/logo.png',
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    );
                  },
                ),
                SizedBox(
                  height: 0.5,
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(color: Colors.white24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rs. " + singleProductVM.product!.productPrice.toString(),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.green,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        singleProductVM.product!.productName.toString(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        singleProductVM.product!.productDescription.toString(),
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
