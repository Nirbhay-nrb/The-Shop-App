import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:the_shop_app/models/http_exception.dart';
import 'package:the_shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items); // constructor

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items]; // spread operator - returns a copy of the object
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // [] on arguments they are optional and in case they are not given false will be the default value
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-99f95-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      url = Uri.parse(
        'https://shop-app-99f95-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken',
      );
      final favoriteResponse = await http.get(url);
      // Map with key as product id and value as isFavorite status
      final favData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      data.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              isFavorite: favData == null ? false : favData[prodId] ?? false,
              // ?? is null operator, i.e. if null it will take the value after ?? i.e. false
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-99f95-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            // passing the product as a map which is then encoded as JSON
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          },
        ),
      );
      print(json.decode(response
          .body)); // decoding the JSON object returned to us by the server

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
        // this is the unique id provided to us by firebase
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => id == element.id);
    final url = Uri.parse(
        'https://shop-app-99f95-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    try {
      // patch request merges the incoming data with the existing data
      // and also overwrites the data it already has for a particular key
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-99f95-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final indexOfProd = _items.indexWhere((element) => id == element.id);
    // storing the item in a separate variable
    var prod = _items[indexOfProd];
    // removing the item from list
    _items.removeAt(indexOfProd);
    notifyListeners();
    // deleting the item from server
    try {
      final response = await http.delete(url);
      // in case we have an error then we reinsert the item into the list
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
    } catch (e) {
      print(e);
      _items.insert(indexOfProd, prod);
      notifyListeners();
      throw e;
    }
    prod = null;
  }
}
