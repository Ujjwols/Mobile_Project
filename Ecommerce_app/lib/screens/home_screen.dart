import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Ecommerce_app/models/category_model.dart';
import 'package:Ecommerce_app/models/product_model.dart';
import 'package:Ecommerce_app/viewmodels/auth_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/category_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/product_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthViewModel _authViewModel;
  late CategoryViewModel _categoryViewModel;
  late ProductViewModel _productViewModel;

  List<CategoryModel> _filteredCategories = [];
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _categoryViewModel = Provider.of<CategoryViewModel>(context, listen: false);
      _productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      refresh();
    });
    super.initState();
  }

  Future<void> refresh() async {
    _categoryViewModel.getCategories();
    _productViewModel.getProducts();
    _authViewModel.getMyProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CategoryViewModel, AuthViewModel, ProductViewModel>(
      builder: (context, categoryVM, authVM, productVM, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40), // Increased gap from top
                // _buildSearchBar(),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filteredProducts = [];
                          });
                        },
                        child: Text(
                          'Show All',
                          style: TextStyle(fontSize: 17, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _buildCategoryList(categoryVM.categories),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Our Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                _buildProductList(_filteredProducts.isNotEmpty
                    ? _filteredProducts
                    : productVM.products),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildSearchBar() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20),
  //     child: TextFormField(
  //       onChanged: (value) {
  //         // Filter products based on search query
  //         List<ProductModel> filteredProducts = _productViewModel.products
  //             .where((product) =>
  //         product.productName?.toLowerCase().contains(value.toLowerCase()) ?? false)
  //             .toList();
  //
  //         // Update UI with filtered products
  //         setState(() {
  //           _filteredProducts = filteredProducts;
  //         });
  //       },
  //       decoration: InputDecoration(
  //         hintText: 'Search...',
  //         prefixIcon: Icon(Icons.search),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(25),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    // Remove duplicate categories based on their id
    List<CategoryModel> uniqueCategories = categories.toSet().toList();

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: uniqueCategories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Filter products based on selected category
              List<ProductModel> filteredProducts = _productViewModel.products
                  .where((product) => product.categoryId == uniqueCategories[index].id)
                  .toList();

              // Update UI with filtered products
              setState(() {
                _filteredProducts = filteredProducts;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(uniqueCategories[index].imageUrl ?? ''),
                  ),
                  SizedBox(height: 5),
                  Text(uniqueCategories[index].categoryName ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed("/single-product", arguments: products[index].id);
          },
          child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: products[index].imageUrl != null && products[index].imageUrl!.isNotEmpty
                      ? Image.network(
                    products[index].imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  products[index].productName ?? '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Rs. " + (products[index].productPrice ?? '').toString(),
                  style: TextStyle(fontSize: 20, color: Colors.green), // Changed color to green
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
