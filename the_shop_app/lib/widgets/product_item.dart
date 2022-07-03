import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/auth.dart';
import 'package:the_shop_app/providers/cart.dart';
import 'package:the_shop_app/providers/product.dart';
import 'package:the_shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
//   final String id;
//   final String title;
//   final String imageUrl;
//   ProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id, // any tag which should be unique
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(
                product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          // consumer is used to make a part of the widget tree to listen to changes and rebuild where as majority
          // of the widget tree does not rebuilds
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              // the child property is used to store a widget which does not gets rebuild when the data is changed
              // u can use the child property inside a builder to give a widget which does not rebuild
              // incase u dont have any child property then just give an underscore(_)
              onPressed: () async {
                try {
                  final authData = Provider.of<Auth>(context, listen: false);
                  await product.toggleFavoriteStatus(
                      authData.token, authData.userId);
                } catch (e) {
                  scaffold.showSnackBar(
                      SnackBar(content: Text('Couldn\'t update!')));
                }
              },
              icon: product.isFavorite
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
