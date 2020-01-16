import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; //bib para fazer as requisições.
import 'dart:async'; //para tornar assyncrono as funções.
import 'dart:convert'; //conversões json etc

//link de get pra requisitar os dados da api HgBrasil
const request =
    "https://api.hgbrasil.com/finance/quotations?format=json&key=b6b6cce5";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

//função para coletar map de infos futuras
Future<Map> getData() async {
  http.Response response = await http.get(request); //retorna um dado futuro
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double dollar;
  double euro;

  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2); //this.dollar é usado para pegar a variavel externa da função
    euroController.text = (dollar * this.dollar/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro/dollar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de moeda"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar os dados =(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(25.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber,
                          ),
                          builderTextField(
                              "Real", "R\$ ", realController, _realChanged),
                          Divider(),
                          builderTextField("Dolar", "US\$ ", dollarController,
                              _dollarChanged),
                          Divider(),
                          builderTextField(
                              "Euros", "€ ", euroController, _euroChanged),
                        ],
                      ),
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget builderTextField(
    String label, String currencies, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 25.0,
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: currencies,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: f,
  );
}
