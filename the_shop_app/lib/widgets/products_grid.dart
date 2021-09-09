import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/models/product.dart';
import 'package:the_shop_app/providers/products_provider.dart';
import 'package:the_shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final List<Product> products = productsData.items;
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
        return ProductItem(
          id: products[i].id,
          imageUrl: products[i].imageUrl,
          title: products[i].title,
        );
      },
    );
  }
}
