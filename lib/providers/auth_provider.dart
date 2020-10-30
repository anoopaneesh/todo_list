import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class AuthProvider with ChangeNotifier{
  static const API_KEY = "AIzaSyCbjs1ydn50z6NTaUMSIh02bvQQXg9kWgs";

  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth{
    return token() != null;
  }
  String token(){
    if(token != null &&  _expiryDate!= null && _expiryDate.isAfter(DateTime.now()) ){
      return _token;
    }
    return null;
  }
  String get userId{
    return _userId;
  }

  Future<void> signUp(String email , String password) async{
    final url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY";
    try{
      final respone = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(respone.body);
      if(responseData['error'] != null){
        throw Exception(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds:int.parse(responseData['expiresIn'])));
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token':_token,
        'userId' : _userId,
        'expiry' : _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    }catch(error){
      throw error;
    }
  }

  Future<void> logIn(String email , String password) async{
    final url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY";
    try{
      final respone = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(respone.body);
      if(responseData['error'] != null){
        throw Exception(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds:int.parse(responseData['expiresIn'])));
      notifyListeners();
      final userData = json.encode({
        'token':_token,
        'userId' : _userId,
        'expiry' : _expiryDate.toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', userData);
    }catch(error){
      throw error;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) return false;
    final userData = json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate = DateTime.parse(userData['expiry']);
    if(expiryDate.isBefore(DateTime.now())) return false;
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
  }

}