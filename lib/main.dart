import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(ListaApp());
}

class ListaApp extends StatefulWidget {
  @override
  _ListaAppState createState() => _ListaAppState();
}

class _ListaAppState extends State<ListaApp> {
  List _tarefas = [];
  Map<String, dynamic> _removidos;
  int _removidoPosicao;

  final _tarefaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lerDados().then((dados) {
      setState(() {
        _tarefas = json.decode(dados);
      });
    });
  }

  void _addTarefa() {
    if (_tarefaController.text.isNotEmpty) {
      setState(() {
        Map<String, dynamic> novaTarefa = Map();
        novaTarefa["titulo"] = _tarefaController.text;
        _tarefaController.text = "";
        novaTarefa["concluido"] = false;
        _tarefas.add(novaTarefa);
        _salvarDados();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista'),
          backgroundColor: Colors.blue[600],
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _tarefaController,
                      decoration: InputDecoration(
                        labelText: 'Nova Tarefa',
                        labelStyle: TextStyle(
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    child: Text('+'),
                    textColor: Colors.white,
                    onPressed: _addTarefa,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _tarefas.length,
                itemBuilder: BuildTarefa,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget BuildTarefa(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_tarefas[index]["titulo"]),
        value: _tarefas[index]["concluido"],
        secondary: CircleAvatar(
          child: Icon(
            _tarefas[index]["concluido"] ? Icons.check : Icons.error,
          ),
        ),
        onChanged: (checked) {
          setState(() {
            _tarefas[index]["concluido"] = checked;
            _salvarDados();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _removidos = Map.from(_tarefas[index]);
          _removidoPosicao = index;
          _tarefas.removeAt(index);
          _salvarDados();

          final snack = SnackBar(
            content: Text("Tarefa \"${_removidos["titulo"]}\" removida."),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _tarefas.insert(_removidoPosicao, _removidos);
                  _salvarDados();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _pegarArquivo() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/lista_de_tarefas.json");
  }

  Future<File> _salvarDados() async {
    String dados = json.encode(_tarefas);
    final arquivo = await _pegarArquivo();
    return arquivo.writeAsString(dados);
  }

  Future<String> _lerDados() async {
    try {
      final arquivo = await _pegarArquivo();
      return arquivo.readAsString();
    } catch (e) {
      return e;
    }
  }
}
