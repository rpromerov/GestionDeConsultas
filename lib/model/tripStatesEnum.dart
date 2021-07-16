enum TripStates {
  canceled,
  ongoing,
  pending,
  finished,
  onRoute,
  onClient,
  toClient,
  departedClient,
  onLandfill,
  deposing,
  toDepot,
  onDepot,
  toConfirm,
  delayed
}

extension tripNames on TripStates {
  int get asInt {
    switch (this) {
      case TripStates.pending:
        return 0;
      case TripStates.canceled:
        return 99;
      case TripStates.onRoute:
        return 1;
      case TripStates.onClient:
        return 2;
      case TripStates.deposing:
        return 3;
      case TripStates.onLandfill:
        return 4;
      case TripStates.toDepot:
        return 5;
      case TripStates.onDepot:
        return 6;
      case TripStates.finished:
        return 7;
      case TripStates.delayed:
        return 8;
      case TripStates.toConfirm:
        return 97;
    }
  }

  String get asString {
    switch (this) {
      case TripStates.pending:
        return "Pendiente";
      case TripStates.canceled:
        return "Cancelado";
      case TripStates.onRoute:
        return "Hacia cliente";
      case TripStates.onClient:
        return "En cliente";
      case TripStates.deposing:
        return "Hacia vertedero";
      case TripStates.onLandfill:
        return "En vertedero";
      case TripStates.toDepot:
        return "Hacia depósito";
      case TripStates.onDepot:
        return "En depósito";
      case TripStates.finished:
        return "Finalizado";
      case TripStates.delayed:
        return "Atrasado";
      case TripStates.toConfirm:
        return "Por confirmar";
    }
  }
}
