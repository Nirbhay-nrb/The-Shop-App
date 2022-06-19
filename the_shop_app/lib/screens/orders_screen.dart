import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/orders.dart' show Orders;
import 'package:the_shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // var _isInit = true;
  // var _isLoading = false;

  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }
  // you can use this in a stateful widget .. but if u want a statelesswidget
  // then use FutureBuilder (more elegant way doing the same thing)
  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            // we are done fetching the data
            if (dataSnapShot.error != null) {
              // error has occured
              return Center(
                child: Text('Error occured'),
              );
            } else {
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                return RefreshIndicator(
                  onRefresh: () => _refreshOrders(context),
                  child: ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(
                      orderData.orders[i],
                    ),
                  ),
                );
              });
            }
          }
        },
      ),
    );
  }
}
