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
          color: Theme.of(context).accentColor,
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
        title: Container(
            width: mediaQuery.size.width * 0.6,
            child: Image.asset('Assets/images/cosemarText.png')),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proximos Viajes',
                  style: textStyle.headline6,
                ),
                OutlineButton(onPressed: () {}, child: Text('Ver todos'))
              ],
            ),
            Container(
                height: mediaQuery.size.height * 0.35,
                child: Column(
                  children: [
                    NextTripCard(
                      mediaQuery: mediaQuery,
                      textStyle: textStyle,
                      destination: 'Tottus',
                      origin: 'Cosemar',
                      time: '9:00AM',
                      state: TripStates.canceled,
                    ),
                    NextTripCard(
                      mediaQuery: mediaQuery,
                      textStyle: textStyle,
                      destination: 'Unimarc',
                      origin: 'Cosemar',
                      time: '10:00AM',
                      state: TripStates.pending,
                    ),
                    NextTripCard(
                      mediaQuery: mediaQuery,
                      textStyle: textStyle,
                      destination: 'Municipalidad',
                      origin: 'Cosemar',
                      time: '05:30PM',
                      state: TripStates.pending,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

enum TripStates { canceled, ongoing, pending }

class NextTripCard extends StatelessWidget {
  final TripStates state;
  final String origin;
  final String destination;
  final String time;
  const NextTripCard(
      {Key key,
      @required this.mediaQuery,
      @required this.textStyle,
      @required this.destination,
      @required this.origin,
      @required this.time,
      @required this.state})
      : super(key: key);

  final MediaQueryData mediaQuery;
  final TextTheme textStyle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: state == TripStates.pending ? Colors.yellow : Colors.red,
        padding: EdgeInsets.all(15),
        height: mediaQuery.size.height * 0.10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  origin,
                  style: textStyle.headline5.copyWith(fontSize: 17),
                ),
                Icon(Icons.arrow_right_alt),
                Text(
                  destination,
                  style: textStyle.headline5.copyWith(fontSize: 17),
                )
              ],
            ),
            Text(
              time,
              style: textStyle.headline6,
            )
          ],
        ),
      ),
    );
  }
}
