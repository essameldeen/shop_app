import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _userToken;
  DateTime _expireDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _userToken != null) return _userToken;
    return null;
  }

  Future<void> _auhtentication(
      String email, String password, String urlSegamnt) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegamnt?key=AIzaSyDone-hmMlWHvhJFoYuF5WMsv3BA9C9gus";

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode(
            {
              'email': email,
              'password': password,
              'returnSecureToken': true,
            },
          ));
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _userToken = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> singUp(String email, String password) async {
    return _auhtentication(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _auhtentication(email, password, 'signInWithPassword');
  }
}
