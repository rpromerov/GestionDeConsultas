import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    var greetingCard = Card(
        elevation: 2,
        child: Container(
            height: mediaQuery.size.height * 0.08,
            margin: EdgeInsets.all(10),
            child: FittedBox(
              child: Text(
                'Bienvenido John Doe',
                style: textStyle.headline4,
              ),
            )));

    var currentTripCard = Card(
      child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
          height: mediaQuery.size.height * 0.15,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Viaje actual',
                        style: textStyle.headline5,
                      ),
                      Row(
                        children: [
                          Text('Cosemar'),
                          Icon(Icons.arrow_right_alt),
                          Text('Jumbo')
                        ],
                      )
                    ],
                  ),
                ),
                RaisedButton(
                    color: Theme.of(context).buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {},
                    child: Text(
                      'Ver',
                      style: textStyle.button,
                    ))
              ])),
    );

    var receptionButton = RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {},
      child: Container(
        padding: EdgeInsets.all(10),
        height: mediaQuery.size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Realizar recepción',
              style: textStyle.button.copyWith(fontSize: 20),
            ),
            Icon(
              Icons.arrow_forward,
              size: 25,
            ),
          ],
        ),
      ),
    );

    var allTripsCard = Card(
      child: Text('Estadisticas de viajes'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('COSEMAR'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {})
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            //greetingCard,
            SizedBox(
              height: mediaQuery.size.height * 0.0,
            ),
            receptionButton,
            SizedBox(
              height: mediaQuery.size.height * 0.02,
            ),
            currentTripCard,
            SizedBox(height: mediaQuery.size.height * 0.05),
            Row(
              children: [
                Text(
                  'Proximos Viajes',
                  style: textStyle.headline6,
                ),
              ],
            ),
            Container(
                height: mediaQuery.size.height * 0.35,
                child: Column(
                  children: [
                    Container(
                      child: Card(
                        child: Container(
                          child: Row(
                            children: [
                              Text('Cosemar'),
                              Icon(Icons.arrow_right_alt),
                              Text('Jumbo')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
