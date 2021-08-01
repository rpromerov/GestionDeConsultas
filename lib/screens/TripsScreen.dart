import 'package:Cosemar/Widgets/notificationItem.dart';
import 'package:Cosemar/model/trip.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum TripFilters { canceled, pending, finished, all }

class TripsScreen extends StatefulWidget {
  static const routeName = '/TripsScreen';

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  TripFilters currentFilter = TripFilters.all;
  var didSetup = false;
  var filteredTrips = List<Trip>();

  void sortTrips() {
    filteredTrips.sort((a, b) {
      return a.programmedDepartureTime.compareTo(b.programmedDepartureTime) * 1;
    });
    final pmTrips = filteredTrips
        .where((trip) => trip.programmedDepartureTime.hour > 12)
        .toList();
    final amTrips = filteredTrips
        .where((trip) => trip.programmedDepartureTime.hour <= 12)
        .toList();
    filteredTrips = amTrips + pmTrips;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!didSetup) {
      filteredTrips = [];
      final NetworkProvider networkProvider =
          Provider.of<NetworkProvider>(context);
      filteredTrips = networkProvider.trips;
      sortTrips();
      didSetup = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NetworkProvider networkProvider =
        Provider.of<NetworkProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Viajes'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 35,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StateButton(
                            func: () {
                              setState(() {
                                currentFilter = TripFilters.all;
                                filteredTrips = networkProvider.trips;
                                sortTrips();
                              });
                            },
                            text: 'Todos',
                            buttonFilter: TripFilters.all,
                            currentFilter: currentFilter,
                          ),
                          VerticalDivider(
                            thickness: 1.5,
                          ),
                          StateButton(
                            func: () {
                              setState(() {
                                currentFilter = TripFilters.pending;
                                filteredTrips = networkProvider.trips
                                    .where((trip) =>
                                        trip.stateEnum == TripStates.pending)
                                    .toList();
                                sortTrips();
                              });
                            },
                            text: 'Pendientes',
                            buttonFilter: TripFilters.pending,
                            currentFilter: currentFilter,
                          ),
                          VerticalDivider(
                            thickness: 1.5,
                          ),
                          StateButton(
                            func: () {
                              setState(() {
                                currentFilter = TripFilters.finished;
                                filteredTrips = networkProvider.trips
                                    .where((trip) =>
                                        trip.stateEnum == TripStates.finished)
                                    .toList();
                                sortTrips();
                              });
                            },
                            text: 'Completados',
                            currentFilter: currentFilter,
                            buttonFilter: TripFilters.finished,
                          ),
                          VerticalDivider(
                            thickness: 1.5,
                          ),
                          StateButton(
                            func: () {
                              setState(() {
                                currentFilter = TripFilters.canceled;
                                filteredTrips = networkProvider.trips
                                    .where((trip) =>
                                        trip.stateEnum == TripStates.canceled)
                                    .toList();
                                sortTrips();
                              });
                            },
                            text: 'Cancelados',
                            currentFilter: currentFilter,
                            buttonFilter: TripFilters.canceled,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var trip in filteredTrips)
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                TripDetailScreen.routeName,
                                arguments: trip),
                            child: TripItem(
                              isRead: false,
                              notificationState: trip.stateEnum,
                              notificationText: networkProvider
                                  .fetchObraByID(trip.obras[0].id)
                                  .nombre,
                              notificationTimestamp: DateFormat.jm()
                                  .format(trip.programmedArrivalTime),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}

class StateButton extends StatelessWidget {
  final Function func;
  final String text;
  final TripFilters buttonFilter;
  final TripFilters currentFilter;

  const StateButton(
      {Key key, this.func, this.text, this.buttonFilter, this.currentFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              color: buttonFilter == currentFilter
                  ? Theme.of(context).accentColor
                  : Colors.black45)),
      onPressed: () => func(),
    );
  }
}
