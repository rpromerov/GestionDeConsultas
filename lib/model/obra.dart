import 'package:Cosemar/model/equipment.dart';
import 'package:Cosemar/model/tarros.dart';

class Obra {
  String nombre;
  String comuna;
  String direccion;
  double latitud;
  double longitud;
  String nombreEncargado;
  String telefono;
  String id;
  Tarros tarros;
  List<Equipment> equiposParaRetiro = [];
  int onServerIndex;
  String idServicio;

  Obra(
      {this.nombre,
      this.comuna,
      this.tarros,
      this.direccion,
      this.latitud,
      this.longitud,
      this.nombreEncargado,
      this.telefono,
      this.id,
      this.equiposParaRetiro,
      this.onServerIndex,
      this.idServicio});

  @override
  String toString() {
    // TODO: implement toString
    print(
      "nombre: $nombre, comuna: $comuna",
    );
  }
}
