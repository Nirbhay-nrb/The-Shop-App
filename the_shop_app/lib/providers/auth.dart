import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String _apiKey = 'AIzaSyDx8HnTYsYn_oaT2r5NySAaiBRMCa_G9v0';

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
}
