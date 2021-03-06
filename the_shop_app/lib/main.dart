import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/helpers/custom_route.dart';
import 'package:the_shop_app/providers/auth.dart';
import 'package:the_shop_app/providers/cart.dart';
import 'package:the_shop_app/providers/orders.dart';
import 'package:the_shop_app/providers/products.dart';
import 'package:the_shop_app/screens/splash_screen.dart';
import 'package:the_shop_app/screens/auth_screen.dart';
import 'package:the_shop_app/screens/cart_screen.dart';
import 'package:the_shop_app/screens/edit_product_screen.dart';
import 'package:the_shop_app/screens/orders_screen.dart';
import 'package:the_shop_app/screens/product_detail_screen.dart';
import 'package:the_shop_app/screens/products_overview_screen.dart';
import 'package:the_shop_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          create: (ctx) => Products('', '', []),
        ),
        // proxy provider is used to rebuild a provider class using a previous provider
        // in this case we are rebuilding the products class by auth provider
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
            auth.userId,
          ),
          create: (ctx) => Orders('', [], ''),
        ),
      ],
      child: Consumer<Auth>(
        // whenever auth changes, material app is rebuilt
        // thus changing the homescreen accordingly
        // if the user is authenticated or not
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                // we cannot directly assign the CustomRoute
                //because we need to provide a transition builder not a route
                // so we add another class to helpers foldes CustomPageTransitionBuilder
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              })),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
