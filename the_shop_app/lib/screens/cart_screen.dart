import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/cart.dart' show Cart;
import 'package:the_shop_app/providers/orders.dart';
import 'package:the_shop_app/widgets/cart_item.dart';
//this will only import the Cart class not the CartItem class to prevent the same class name clash

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}', // 2 decimal points
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    onPressed: () {
                      if (cart.totalAmount > 0) {
                        Provider.of<Orders>(context, listen: false).addOrder(
                            cart.items.values.toList(), cart.totalAmount);
                        cart.clearCart();
                      } else {
                        print('order nahi ho skta');
                      }
                    },
                    child: Text('ORDER NOW'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // you cannot use listview directly in column, so you have to wrap it inside an expanded widget
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, i) => CartItem(
                id: cart.items.values.toList()[i].id,
                // returns the values as a list
                price: cart.items.values.toList()[i].price,
                quantity: cart.items.values.toList()[i].quantity,
                title: cart.items.values.toList()[i].title,
                productId: cart.items.keys.toList()[i],
                // returns the keys as a list
              ),
            ),
          ),
        ],
      ),
    );
  }
}
