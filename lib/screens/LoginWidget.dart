import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/model/trip.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmptyUserFieldNotice = false;
  bool _showEmptyPasswordNotice = false;
  var _rememberMe = false;

  var _didLoadData = false;
  NetworkProvider networkProvider = null;

  void checkTextControllers() {
    if (_userController.text.isEmpty) {
      setState(() {
        _showEmptyUserFieldNotice = true;
      });
    } else {
      setState(() {
        _showEmptyUserFieldNotice = false;
      });
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _showEmptyPasswordNotice = true;
      });
    } else {
      _showEmptyPasswordNotice = false;
    }
    if (_showEmptyPasswordNotice || _showEmptyUserFieldNotice) {
      return;
    }
  }

  void showErrorDialog(BuildContext ctx, String errorText) {
    showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text('Error iniciando sesión'),
              content: Text(errorText),
              actions: [
                FlatButton(
                  child: Text('Continuar'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  void _goToDashboard(BuildContext ctx) async {
    networkProvider.setUserEmail(_userController.text);
    networkProvider
        .login(_userController.text, _passwordController.text)
        .then((response) =>
            Navigator.pushReplacementNamed(ctx, Dashboard.routeName))
        .catchError((error) {
      showErrorDialog(ctx, error.toString());
    });
  }

  String get getNoticeText {
    if (_showEmptyPasswordNotice && _showEmptyUserFieldNotice) {
      return 'Debe ingresar usuario y contraseña';
    } else if (_showEmptyPasswordNotice) {
      return 'Debe ingresar una contraseña';
    } else if (_showEmptyUserFieldNotice) {
      return 'Debe ingresar usuario';
    } else {
      return '';
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_didLoadData) {
      networkProvider = Provider.of<NetworkProvider>(context, listen: true);
      networkProvider.connectionStatus = ConnectionStatus.connecting;
      networkProvider.trips = [];
      networkProvider.currentTrip = Trip();
      networkProvider.currentObra = Obra();
      networkProvider.loadData().then((_) {
        setState(() {
          _userController.text = networkProvider.userEmail;
          _rememberMe = networkProvider.saveEmail;
          networkProvider.connectionStatus = ConnectionStatus.disconnected;
        });

        if (networkProvider.token != null) {
          _goToDashboard(context);
        }
      });

      _didLoadData = true;
    }
  }

  // final debugController =
  //     TextEditingController(text: NetworkProvider.getServerIp);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            child: Image.asset(
              "Assets/images/background.png",
              fit: BoxFit.fitHeight,
            ),
            height: mediaQuery.size.height,
            width: mediaQuery.size.width,
          ),
          SingleChildScrollView(
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
                  // TextField(
                  //   decoration: InputDecoration(labelText: "DEBUG: SERVER IP"),
                  //   onSubmitted: (value) {
                  //     NetworkProvider.serverIp = value;
                  //     print("Server IP is now ${NetworkProvider.getServerIp}");
                  //   },
                  //   controller: debugController,
                  // ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: networkProvider.connectionStatus ==
                            ConnectionStatus.connecting
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Card(
                            color: Colors.white,
                            elevation: 10,
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  if (_showEmptyPasswordNotice ||
                                      _showEmptyUserFieldNotice)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          getNoticeText,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  TextField(
                                    controller: _userController,
                                    decoration:
                                        InputDecoration(labelText: 'Usuario'),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  TextField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                        labelText: 'Contraseña'),
                                    obscureText: true,
                                    onSubmitted: (_) {
                                      _goToDashboard(context);
                                    },
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                this._rememberMe = value;
                                                networkProvider.saveEmail =
                                                    value;
                                              });
                                            },
                                          ),
                                          Text('Recordarme')
                                        ],
                                      ),
                                      RaisedButton(
                                        color: Theme.of(context).accentColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        onPressed: () =>
                                            _goToDashboard(context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            'Ingresar',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white),
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
                  Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          "12/12/21",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Spacer(),
                        Text(
                          "v1.10.1",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
