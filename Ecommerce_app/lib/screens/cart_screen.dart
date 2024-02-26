import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Ecommerce_app/models/cart_model.dart';
import 'package:Ecommerce_app/repositories/cart_repositories.dart';
import 'package:Ecommerce_app/viewmodels/auth_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/global_ui_viewmodel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;

  List<CartItem> items = [];

  Future<void> getCartItems() async {
    final response = await CartRepository().getCart();
    setState(() {
      items = response.items;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getCartItems();
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Cart'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/addtocart.jpg",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (items == null)
                            Center(child: Text("Something went wrong"))
                          else if (items.isEmpty)
                            Center(child: Text("Please add items to your cart"))
                          else
                            _buildCartItemList(),
                        ],
                      ),
                    ),
                    SizedBox(height: 40), // Increased gap between the items and the total section
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.green, // Set green background color
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: _buildTotalItemsAndPrice(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItemList() {
    return Column(
      children: items.map(
            (e) => InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              "/single-product",
              arguments: e.product.id!,
            );
          },
          child: Card(
            elevation: 5, // Add elevation for a raised effect
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Add margin
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              dense: true,
              trailing: IconButton(
                iconSize: 25,
                onPressed: () {
                  CartRepository().removeItemFromCart(e.product).then((value) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Deleted from cart")));
                    getCartItems();
                  });
                },
                icon: Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                ),
              ),
              leading: Container(
                width: 120, // Increased image width
                height: 120, // Increased image height
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: e.product.imageUrl != null && e.product.imageUrl!.isNotEmpty
                      ? Image.network(
                    e.product.imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/images/logo.png', // Provide a default image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                e.product.productName ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    'Price: ${e.product.productPrice}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green, // Make price text green
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          CartRepository().removeFromCart(e.product).then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Removed from cart")));
                            getCartItems();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(e.quantity.toString()),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          CartRepository().addToCart(e.product, 1).then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Added to cart")));
                            getCartItems();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildTotalItemsAndPrice() {
    int total = 0;
    num totalPrice = 0;

    items.forEach((element) {
      total += element.quantity;
      totalPrice += (element.product.productPrice ?? 0) * element.quantity;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Items: $total",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to white
          ),
        ),
        Text(
          "Total Price: \$${totalPrice.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to white
          ),
        ),
      ],
    );
  }
}
