import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:flutter/material.dart';

class TripItem extends StatelessWidget {
  final String notificationText;
  final String notificationTimestamp;
  final bool isRead;
  final TripStates notificationState;

  const TripItem(
      {Key key,
      this.notificationText,
      this.notificationTimestamp,
      this.isRead = false,
      this.notificationState})
      : super(key: key);
  Color getBarColor() {
    if (notificationState == TripStates.canceled) {
      return Colors.red;
    } else if (notificationState == TripStates.pending) {
      return Colors.yellow;
    } else if (notificationState == TripStates.finished) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }

  String get tripText {
    switch (notificationState) {
      case TripStates.canceled:
        return 'Cancelado';
      case TripStates.ongoing:
        return 'Actual';
      case TripStates.pending:
        return 'Pendiente';
      case TripStates.finished:
        return 'Finalizado';
      default:
        return 'Actual';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
        height: mediaQuery.size.height * 0.15,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Card(
            elevation: 5,
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  width: 12,
                  height: 70,
                  child: Container(
                    padding: EdgeInsets.only(left: 25),
                    color: getBarColor(),
                  ),
                ),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          tripText,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: getBarColor()),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              notificationText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(fontSize: 25),
                            ),
                          ),
                          Text(
                            notificationTimestamp,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontSize: 21),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ]))
              ],
            )));
  }
}
