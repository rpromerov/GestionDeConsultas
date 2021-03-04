enum TripStates {
  canceled,
  ongoing,
  pending,
  finished,
  onRoute,
  onClient,
  departedClient,
  deposing,
  toDepot,
  toConfirm
}

extension tripNames on TripStates {
  int get asInt {
    switch (this) {
      case TripStates.pending:
        return 0;
      case TripStates.canceled:
        return 99;
      case TripStates.ongoing:
        return 1;
      case TripStates.onRoute:
        return 2;
      case TripStates.onClient:
        return 3;
      case TripStates.departedClient:
        return 4;
      case TripStates.deposing:
        return 5;
      case TripStates.toDepot:
        return 6;
      case TripStates.finished:
        return 7;
      case TripStates.toConfirm:
        return 97;
    }
  }
}
