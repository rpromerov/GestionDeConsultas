class Equipment {
  String equipmentID;
  String internalID;
  String name;
  String typeOfEquipment;
  double acceptedWeight;
  String state;

  Equipment(
      {this.equipmentID,
      this.internalID,
      this.name,
      this.typeOfEquipment,
      this.acceptedWeight,
      this.state});

  String toString() {
    return "${this.equipmentID} - ${this.name}";
  }
}
