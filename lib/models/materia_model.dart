class MateriaModel {
  final int id;
  final String disciplina;
  final List<int> notas;
  final bool isSemestral;

  MateriaModel({
    required this.id,
    required this.disciplina,
    required this.notas,
    required this.isSemestral,
  });

  Map<String, dynamic> toMap() {
    return {
      'disciplina': disciplina,
      'notas': notas.join(','),
      'isSemestral': isSemestral ? 1 : 0,
    };
  }

  factory MateriaModel.fromMap(Map<String, dynamic> map) {
    return MateriaModel(
      id: map['id'],
      disciplina: map['disciplina'],
      notas: (map['notas'] as String).split(',').map((e) => int.parse(e)).toList(),
      isSemestral: map['isSemestral'] == 1,
    );
  }

  double calcularMedia() {
    return notas.isNotEmpty ? notas.reduce((a, b) => a + b) / notas.length : 0.0;
  }
}
