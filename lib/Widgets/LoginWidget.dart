import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  var rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 90),
              child: Image.asset('Assets/images/cosemarLogo.png'),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userController,
                        decoration: InputDecoration(labelText: 'Usuario'),
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                      ),
                      Container(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    this.rememberMe = value;
                                  });
                                },
                              ),
                              Text('Recordarme')
                            ],
                          ),
                          RaisedButton(
                            color: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                'Ingresar',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
