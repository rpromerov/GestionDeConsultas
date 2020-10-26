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
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 20),
          alignment: Alignment.center,
          height: mediaQuery.size.height,
          child: Column(
            children: [
              SizedBox(
                height: mediaQuery.size.height * 0.1,
              ),
              Container(
                height: mediaQuery.size.height * 0.3,
                child: Image.asset('Assets/images/cosemarLogo.png'),
              ),
              SizedBox(
                height: mediaQuery.size.height * 0.05,
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
      ),
    );
  }
}
