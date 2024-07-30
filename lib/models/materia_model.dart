class MateriaModel {
  final int id;
  final String disciplina;
  final int nota;

  MateriaModel(
      {required this.id, required this.disciplina, required this.nota});

  Map<String, dynamic> toMap() {
    return {"id": id, "disciplina": disciplina, "nota": nota};
  }

  factory MateriaModel.fromMap(Map<String, dynamic> map) {
    return MateriaModel(
        id: map["id"], disciplina: map["disciplina"], nota: map["nota"]);
  }
}
