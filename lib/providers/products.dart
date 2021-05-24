import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _myProducts = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  // bool _onlyIsFavourites = false;

  List<Product> get myProducts {
    // if (_onlyIsFavourites) {
    //   return _myProducts.where((element) => element.isFavourite).toList();
    // }
    return [..._myProducts];
  }

  List<Product> get favouritesProduct {
    return _myProducts.where((element) => element.isFavourite).toList();
  }

  // void showOnlyFavourites() {
  //   _onlyIsFavourites = true;
  // }
  //
  // void showAll() {
  //   _onlyIsFavourites = false;
  // }

  Future<void> addProduct(Product product) {
    var url = Uri.https(
        'fluter-project-default-rtdb.firebaseio.com', '/products');

    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'desc': product.description,
              'image': product.imageUrl,
              'price': product.price,
              'isFavourite': product.isFavourite,
            }))
        .then((response) {
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );

      _myProducts.add(newProduct);
      notifyListeners();
    }).catchError((error) {
      print(error);
      throw error;
    });
  }

  Product findById(String id) {
    return _myProducts.firstWhere((element) => element.id == id);
  }

  void updateProduct(String id, Product productUpdated) {
    final index = _myProducts.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _myProducts[index] = productUpdated;
      notifyListeners();
    }
  }

  void removeProduct(String id) {
    _myProducts.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
