import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/product.dart';
import 'package:the_shop_app/providers/products_provider.dart';
import 'package:the_shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final List<Product> products =
        showFavs ? productsData.favItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          // whenever in a list/grid use this .value syntax of provider
          // or whenever u r using an already existing object .. in this case products[i]
          // for new objects (like the one in main.dart) use the create method
          value: products[i],
          child: ProductItem(
              // id: products[i].id,
              // imageUrl: products[i].imageUrl,
              // title: products[i].title,
              ),
        );
      },
    );
  }
}
