import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:flutter/material.dart';

class NextTripCard extends StatelessWidget {
  final TripStates state;
  final String origin;
  final String destination;
  final String time;
  final int tripType;
  const NextTripCard(
      {Key key,
      @required this.mediaQuery,
      @required this.textStyle,
      @required this.destination,
      @required this.origin,
      @required this.time,
      @required this.state,
      @required this.tripType})
      : super(key: key);

  final MediaQueryData mediaQuery;
  final TextTheme textStyle;

  Color getBarColor() {
    if (state == TripStates.canceled) {
      return Colors.red;
    } else if (state == TripStates.pending) {
      return Colors.yellow;
    } else if (state == TripStates.finished) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getBarColor();
    return Card(
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 10,
            height: 50,
            child: Container(
              padding: EdgeInsets.only(left: 25),
              color: color,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 0, right: 15, top: 15, bottom: 15),
            height: mediaQuery.size.height * 0.13,
            width: mediaQuery.size.width * 0.8,
            child: SizedBox.expand(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: mediaQuery.size.width * 0.55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            children: [
                              Text(
                                destination,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    textStyle.headline5.copyWith(fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                        if (tripType == 2)
                          Text(
                            "Carga trasera",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle.headline5.copyWith(fontSize: 15),
                          )
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: textStyle.headline6,
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
