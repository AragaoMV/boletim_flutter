import 'package:cadastro_notas/models/materia_model.dart';
import 'package:cadastro_notas/services/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MateriaModel> materias = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    _updateMateriaMapList();
    super.initState();
  }

  _updateMateriaMapList() async {
    final List<MateriaModel> materiaList = await dbHelper.getMateriaList();
    setState(() {
      materias = materiaList;
    });
  }

  _showFormDialog(MateriaModel? materia) {
    final _disciplinaController = TextEditingController(text: materia?.disciplina ?? "");
    final _notasControllers = materia?.notas.map((nota) => TextEditingController(text: nota.toString())).toList() ??
        [TextEditingController(), TextEditingController()];
    bool _isSemestral = materia?.isSemestral ?? true;

    if (!_isSemestral) {
      while (_notasControllers.length < 4) {
        _notasControllers.add(TextEditingController());
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(materia == null ? "Adicionar Disciplina" : "Editar Disciplina"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _disciplinaController,
                    decoration: const InputDecoration(hintText: "Disciplina"),
                  ),
                  SwitchListTile(
                    title: const Text("Semestral"),
                    value: _isSemestral,
                    onChanged: (bool value) {
                      setState(() {
                        _isSemestral = value;
                        if (_isSemestral) {
                          while (_notasControllers.length > 2) {
                            _notasControllers.removeLast();
                          }
                        } else {
                          while (_notasControllers.length < 4) {
                            _notasControllers.add(TextEditingController());
                          }
                        }
                      });
                    },
                  ),
                  for (var i = 0; i < (_isSemestral ? 2 : 4); i++)
                    TextField(
                      controller: _notasControllers[i],
                      decoration: InputDecoration(hintText: "Nota ${i + 1}"),
                      keyboardType: TextInputType.number,
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final disciplina = _disciplinaController.text;
                final notas = _notasControllers.map((controller) => int.tryParse(controller.text)).toList();
                if (disciplina.isNotEmpty && notas.every((nota) => nota != null)) {
                  final newMateria = MateriaModel(
                    id: materia?.id ?? 0, // Use 0 for new entries, ID will be auto-generated
                    disciplina: disciplina,
                    notas: List<int>.from(notas.map((nota) => nota!)),
                    isSemestral: _isSemestral,
                  );
                  if (materia == null) {
                    await dbHelper.insertMateria(newMateria);
                  } else {
                    await dbHelper.updateMateria(newMateria.toMap()..['id'] = materia.id);
                  }
                  _updateMateriaMapList();
                  Navigator.pop(context);
                }
              },
              child: Text(materia == null ? "Adicionar" : "Atualizar"),
            ),
          ],
        );
      },
    );
  }



  _deleteMateria(int id) async {
    await dbHelper.deleteMateria(id);
    _updateMateriaMapList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Boletim de Notas"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500,
        ),
        backgroundColor: const Color.fromARGB(255, 95, 0, 160),
      ),
      body: ListView.builder(
        itemCount: materias.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(materias[index].disciplina),
            subtitle: Text('Média: ${materias[index].calcularMedia()}'),
            tileColor: materias[index].calcularMedia() < 5 ? Colors.red[100] : Colors.green[100],
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showFormDialog(materias[index]);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteMateria(materias[index].id);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormDialog(null);
        },
        backgroundColor: const Color.fromARGB(255, 95, 0, 160),
        child: const Icon(Icons.add),
      ),
    );
  }
}
