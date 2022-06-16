import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/cart.dart';
import 'package:the_shop_app/screens/cart_screen.dart';
import 'package:the_shop_app/widgets/app_drawer.dart';
import 'package:the_shop_app/widgets/badge.dart';
import 'package:the_shop_app/widgets/products_grid.dart';

import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool showFavoritesOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts();
    // you cannot run things with context in init state
    // for that use didChangeDependencies
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // this also runs before the build is created
    // and it supports the use of context
    // but this will however run multiple times,
    //so to avoid that maintain a variable to run this only once
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // we cannot use async in functions such as initState and didChangeDependencies
      // so to implement a loaded use 'then' function
      Provider.of<Products>(context, listen: false).fetchAndSetProducts().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  showFavoritesOnly = true;
                } else {
                  showFavoritesOnly = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(
              Icons.more_vert,
            ),
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemQuantityCount.toString(),
            ),
            child: IconButton(
              // this widget will not be rebuilt whenever the consumer rebuilds
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(showFavoritesOnly),
    );
  }
}
