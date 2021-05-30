import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  String token;

  List<Product> _myProducts = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  Products(this.token, this._myProducts);

  // bool _onlyIsFavourites = false;
  Future<void> addInitValueInServer() async {
    final url = Uri.https('fluter-project-default-rtdb.firebaseio.com',
        '/products.json?auth=$token');
    _myProducts.forEach((element) async {
      final response = await http.post(url,
          body: json.encode({
            'title': element.title,
            'desc': element.description,
            'image': element.imageUrl,
            'price': element.price,
            'isFavourite': element.isFavourite,
          }));
    });
  }

  List<Product> get myProducts {
    // if (_onlyIsFavourites) {
    //   return _myProducts.where((element) => element.isFavourite).toList();
    // }
    return [..._myProducts];
  }

  List<Product> get favouritesProduct {
    return _myProducts.where((element) => element.isFavourite).toList();
  }

  Future<void> fetchDataFromServer() async {
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) return;
      final List<Product> productsFromServer = [];
      data.forEach((prodId, productData) {
        productsFromServer.add(Product(
          id: prodId,
          title: productData['title'],
          description: productData['desc'],
          imageUrl: productData['image'],
          price: productData['price'],
          isFavourite: productData['isFavourite'],
        ));
      });

      _myProducts = productsFromServer;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'desc': product.description,
            'image': product.imageUrl,
            'price': product.price,
            'isFavourite': product.isFavourite,
          }));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _myProducts.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _myProducts.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product productUpdated) async {
    final index = _myProducts.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final urlUpdate =
          'https://fluter-project-default-rtdb.firebaseio.com/products/$id.json?auth=$token';
      await http.patch(Uri.parse(urlUpdate),
          body: json.encode({
            'title': productUpdated.title,
            'desc': productUpdated.description,
            'image': productUpdated.imageUrl,
            'price': productUpdated.price,
          }));

      _myProducts[index] = productUpdated;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String id) async {
    final urldelete =
        'https://fluter-project-default-rtdb.firebaseio.com/products/$id.json?auth=$token';
    var productRemoved = findById(id);
    final index = _myProducts.indexWhere((element) => element.id == id);
    _myProducts.removeAt(index);
    notifyListeners();
    final response = await http.delete((Uri.parse(urldelete)));
    print(response.statusCode);
    if (response.statusCode >= 400) {
      _myProducts.insert(index, productRemoved);
      notifyListeners();
      throw HttpException("Product not deleted!");
    }
    productRemoved = null;
  }
}
