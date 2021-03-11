class Depot {
  final String depotId;
  final String name;
  final String adress;
  final Map<String, double> coordinates;
  final String comuna;
  final String encargado;
  final String telephone;

  Depot(
      {this.depotId,
      this.name,
      this.adress,
      this.coordinates,
      this.comuna,
      this.encargado,
      this.telephone});
}
