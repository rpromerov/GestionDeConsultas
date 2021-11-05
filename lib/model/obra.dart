import 'package:Cosemar/model/equipment.dart';

class Obra {
  String nombre;
  String comuna;
  String direccion;
  double latitud;
  double longitud;
  String nombreEncargado;
  String telefono;
  String id;
  List<Equipment> equiposParaRetiro = [];

  Obra(
      {this.nombre,
      this.comuna,
      this.direccion,
      this.latitud,
      this.longitud,
      this.nombreEncargado,
      this.telefono,
      this.id,
      this.equiposParaRetiro});

  @override
  String toString() {
    // TODO: implement toString
    print(
      "nombre: $nombre, comuna: $comuna",
    );
  }
}
