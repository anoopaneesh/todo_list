import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/providers/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorDark
              ],
              end: Alignment.topLeft,
              begin: Alignment.bottomRight,
            ),
          ),
          height: mediaQuery.height,
          width: mediaQuery.width,
        ),
        SingleChildScrollView(
          child: Container(
            width: mediaQuery.width,
            height: mediaQuery.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Text('ToDo',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(height: 30,),
                Container(child: AuthInput(),padding: const EdgeInsets.symmetric(horizontal: 10),),
                Spacer()
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

enum AuthState {
  Login,
  SignUp,
}

class AuthInput extends StatefulWidget {
  @override
  _AuthInputState createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  var _authState = AuthState.Login;
  var _isLoading = false;
  final GlobalKey<FormState> _formKey = new GlobalKey();
  Map<String, String> _userCredentials = {
    'email': '',
    'pass': '',
  };
  var _passwordController = TextEditingController();
  void _showErrorDialog(String message){
    showDialog(context: context,builder: (ctx) => AlertDialog(
      title:Text(' An Error Occured'),
      content: Text(message),
      actions: [
        FlatButton(onPressed: () => Navigator.of(ctx).pop(), child:Text('Ok') )
      ],
    ));
  }
  void _switchAuthState() {
    if (_authState == AuthState.Login) {
      setState(() {
        _authState = AuthState.SignUp;
      });
    } else {
      setState(() {
        _authState = AuthState.Login;
      });
    }
  }

  Future<void> _onSubmit() async{
    setState(() {
      _isLoading = true;
    });
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    print(_userCredentials);
    try{
      if (_authState == AuthState.Login) {
        await Provider.of<AuthProvider>(context, listen: false)
            .logIn(_userCredentials['email'], _userCredentials['pass']);
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(_userCredentials['email'], _userCredentials['pass']);
      }
    }catch(error){
      _showErrorDialog(error.message);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget CustomText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _authState == AuthState.Login ?300 :350,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _userCredentials['email'] = value,
                  validator: (value) {
                    if (value == "" || !value.contains('@')) {
                      return "invalid email";
                    }
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                  onSaved: (value) => _userCredentials['pass'] = value,
                  validator: (value) {
                    if (value == "" || value.length < 5) {
                      return "Password Too short";
                    }
                  },
                ),
                if (_authState == AuthState.SignUp)
                  TextFormField(
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords not match";
                      }
                    },
                  ),
                SizedBox(height: 20,),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _onSubmit(),
                  child: _isLoading?
                      CircularProgressIndicator()
                      :_authState == AuthState.Login
                      ? CustomText('Login')
                      : CustomText('SignUp'),
                ),
                FlatButton(
                    onPressed: _switchAuthState,
                    child: _authState == AuthState.Login
                        ? Text(
                            'Not a memeber? SignUp',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        : Text('Already a user? Login',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
