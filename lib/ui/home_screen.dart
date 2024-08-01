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
    final List<Map<String, dynamic>> materiaMapList =
        await dbHelper.getMateriaMapList();
    setState(() {
      materias = materiaMapList
          .map(
            (e) => MateriaModel.fromMap(e),
          )
          .toList();
    });
  }

//Adiciona Materia
  _showFormDialog(MateriaModel? materia) {
    final _disciplinaController =
        TextEditingController(text: materia?.disciplina ?? "");
    final _notaController =
        TextEditingController(text: materia?.nota.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(materia == null ? "Adicionar Disciplina" : "Editar Disciplina"),
          content: Column(mainAxisSize: MainAxisSize.min,
              children: [
            TextField(
              controller: _disciplinaController,
              decoration: const InputDecoration(hintText: "disciplina"),
            ),
            TextField(
              controller: _notaController,
              decoration: const InputDecoration(hintText: "nota"),
              keyboardType: TextInputType.number,
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),),
            ElevatedButton(
                onPressed: () async {
                  final disciplina = _disciplinaController.text;
                  final nota = int.tryParse(_notaController.text);
                  if (disciplina.isNotEmpty && nota != null) {
                    if (materia == null) {
                      await dbHelper.insertMateria({"disciplina": disciplina, "nota": nota});
                      _updateMateriaMapList();
                    } else {
                      await dbHelper.updateMateria({
                        "id": materia.id,
                        "disciplina": disciplina,
                        "nota": nota
                      });
                      _updateMateriaMapList();
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(materia == null ? "Adicionar" : "Atualizar"),)
          ],
        );
      },
    );
  }
  _deleteMateria(int id)async{
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
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
            backgroundColor: const Color.fromARGB(255, 95, 0, 160),
      ),
    body: ListView.builder(
      itemCount: materias.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(materias[index].disciplina),
          subtitle: Text(materias[index].nota.toString()),
          tileColor: materias[index].nota < 5? Colors. red[100] : Colors.green[100],
          trailing: SizedBox(width: 100, child: Row(children: [
            IconButton(onPressed: () {
              _showFormDialog(materias[index]);
            }, icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {
              _deleteMateria(materias[index].id);
            }, icon: const Icon(Icons.delete))
          ],),
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton(onPressed:() {
      _showFormDialog(null);
      },backgroundColor: const Color.fromARGB(255, 95, 0, 160),
        child: const Icon(Icons.add),),
  );
 }
}
