import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/cart.dart';
import 'package:the_shop_app/providers/products_provider.dart';
import 'package:the_shop_app/screens/product_detail_screen.dart';
import 'package:the_shop_app/screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
        },
      ),
    );
  }
}
