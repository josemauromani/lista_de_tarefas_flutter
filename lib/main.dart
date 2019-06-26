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
  final _tarefaController = TextEditingController();

  void _addTarefa() {
    if (_tarefaController.text.isNotEmpty) {
      setState(() {
        Map<String, dynamic> novaTarefa = Map();
        novaTarefa["titulo"] = _tarefaController.text;
        _tarefaController.text = "";
        novaTarefa["concluido"] = false;
        _tarefas.add(novaTarefa);
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
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_tarefas[index]["titulo"]),
                    value: _tarefas[index]["concluido"],
                    secondary: CircleAvatar(
                      child: Icon(
                        _tarefas[index]["concluido"]
                            ? Icons.check
                            : Icons.error,
                      ),
                    ),
                    onChanged: (checked){
                      setState((){
                        _tarefas[index]["concluido"] = checked;
                      });
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<File> _pegarArquivo() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/data.json");
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
