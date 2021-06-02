import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _userToken;
  DateTime _expireDate;
  String _userId;
  Timer timer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _userToken != null) return _userToken;
    return null;
  }

  String get userId {
    return _userId;
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
      _autoLogOut();
      notifyListeners();
      final instance = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'userId': _userId,
        'expireDate': _expireDate.toIso8601String(),
      });
      instance.setString('userData', userData);
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

  Future<bool> tryAutoLogin() async {
    final instance = await SharedPreferences.getInstance();

    if (!instance.containsKey('userData')) {
      return false;
    } else {
      final userData = instance.get('userData');
      final data = json.decode(userData) as Map<String, dynamic>;
      _expireDate = DateTime.parse(data['expireDate']);
      if (_expireDate.isBefore(DateTime.now())) {
        return false;
      }
      _userToken = data['token'];
      _userId = data['userId'];
      _autoLogOut();
      notifyListeners();
      return true;
    }
  }

  Future<void> logOut() async {
    _userToken = null;
    _userId = null;
    _expireDate = null;
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    notifyListeners();
    final instance = await SharedPreferences.getInstance();
    instance.clear();
  }

  void _autoLogOut() {
    if (timer != null) {
      timer.cancel();
    }
    final expire = _expireDate.difference(DateTime.now()).inSeconds;
    timer = Timer(Duration(seconds: expire), logOut);
  }
}
