class MateriaModel {
  final int id;
  final String materia;
  final int nota;

  MateriaModel({required this.id, required this.materia, required this.nota});

  Map<String, dynamic> toMap() {
    return {"id": id, "materia": materia, "nota": nota};
  }

  factory MateriaModel.fromMap(Map<String, dynamic> map) {
    return MateriaModel(
        id: map["id"], materia: map["materia"], nota: map["nota"]);
  }
}
