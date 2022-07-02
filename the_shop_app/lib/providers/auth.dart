import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  final String _apiKey = 'AIzaSyDx8HnTYsYn_oaT2r5NySAaiBRMCa_G9v0';
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    // if we have a token which is not expired then we return true
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_apiKey');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      // firebase returns the expiry duration in seconds,
      // so we need to calculate the expiry time by
      // adding the given duration to the current time
      _autoLogout();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    // 'return' is to return the future it will get from authenticate
    // so that we can load the spinner correctly on the auth screen
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // as there is only one change in signin and signup (thats the urlSegment)
    // we combine both the functions into one
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    // set a timer till the token expires and then autologout
    if (_authTimer != null) {
      // if a timer already exists then we should cancel that before putting a new one
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }
}
