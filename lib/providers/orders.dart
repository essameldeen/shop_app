import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> items;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.items,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _items = [];
  final String token;
  final String userId;

  Orders(this.token, this.userId, this._items);

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> fetchDataFromServer() async {
    final List<OrderItem> loadedOrder = [];
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';

    try {
      final response = await http.get(Uri.parse(url));
      final responseDate = json.decode(response.body) as Map<String, dynamic>;
      if (responseDate == null) {
        return;
      }
      responseDate.forEach((orderId, orderData) {
        loadedOrder.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            items: (orderData['products'] as List<dynamic>)
                .map((element) => CartItem(
                      id: element['id'],
                      price: element['price'],
                      quantity: element['quantity'],
                      title: element['title'],
                    ))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      _items = loadedOrder.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';

    final timeStamp = DateTime.now();

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'price': e.price,
                    'quantity': e.quantity,
                    'title': e.title,
                  })
              .toList()
        }),
      );
      _items.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              items: products,
              dateTime: DateTime.now()));

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
