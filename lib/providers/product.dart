import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String token, String userId) async {
    var oldValue = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(Uri.parse(url),
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavourite = oldValue;
        print(response.body);
        notifyListeners();
      }
    } catch (error) {
      isFavourite = oldValue;

      notifyListeners();
    }
  }
}
