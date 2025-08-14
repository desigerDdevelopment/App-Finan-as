import 'package:app/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _saldo = 0.0;
  double _salarioMensal = 0.0;
  String _username = "";
  List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? widget.username;
      _salarioMensal = prefs.getDouble('salary') ?? 1518.0;
      _saldo = prefs.getDouble('saldo') ?? _salarioMensal;

      List<String>? savedExpenses = prefs.getStringList('gastos');
      if (savedExpenses != null) {
        _gastos = savedExpenses
            .map((e) => {
                  "descricao": e.split('|')[0],
                  "valor": double.parse(e.split('|')[1])
                })
            .toList();
      }
    });
  }

  Future<void> _saveGastos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'gastos', _gastos.map((e) => "${e['descricao']}|${e['valor']}").toList());
    await prefs.setDouble('saldo', _saldo);
  }

  Future<void> _addGasto(String descricao, double valor) async {
    setState(() {
      _gastos.add({"descricao": descricao, "valor": valor});
      _saldo -= valor;
    });
    await _saveGastos();
  }

  Future<void> _editarGasto(int index) async {
    TextEditingController descController =
        TextEditingController(text: _gastos[index]['descricao']);
    TextEditingController valorController =
        TextEditingController(text: _gastos[index]['valor'].toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Gasto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
            TextField(controller: valorController, decoration: const InputDecoration(labelText: "Valor"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              double oldValor = _gastos[index]['valor'];
              double novoValor = double.tryParse(valorController.text) ?? oldValor;

              setState(() {
                _gastos[index]['descricao'] = descController.text;
                _gastos[index]['valor'] = novoValor;
                _saldo += oldValor - novoValor; // Ajusta o saldo
              });
              await _saveGastos();
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirGasto(int index) async {
    setState(() {
      _saldo += _gastos[index]['valor'];
      _gastos.removeAt(index);
    });
    await _saveGastos();
  }

  Future<void> _editarUsuario() async {
    TextEditingController nomeController = TextEditingController(text: _username);
    TextEditingController salarioController = TextEditingController(text: _salarioMensal.toStringAsFixed(2));

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuário"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: salarioController, decoration: const InputDecoration(labelText: "Salário Mensal"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              double novoSalario = double.tryParse(salarioController.text) ?? _salarioMensal;

              setState(() {
                _username = nomeController.text;
                _salarioMensal = novoSalario;
                _saldo = novoSalario; // reinicia saldo com novo salário
              });

              await prefs.setString('username', _username);
              await prefs.setDouble('salary', _salarioMensal);
              await prefs.setDouble('saldo', _saldo);

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _showAddGastoDialog() {
    TextEditingController descController = TextEditingController();
    TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adicionar Gasto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
            TextField(controller: valorController, decoration: const InputDecoration(labelText: "Valor"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (descController.text.isNotEmpty && valorController.text.isNotEmpty) {
                _addGasto(descController.text, double.parse(valorController.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("Bem-vindo"),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                username: _username,
                salary: _salarioMensal,
              ),
            ),
          );

          if (result != null) {
            setState(() {
              _username = result["username"];
              _salarioMensal = result["salary"];
              _saldo = _salarioMensal;
            });
          }
        },
        child: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            _username.isNotEmpty ? _username[0].toUpperCase() : "?",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      },
    )
  ],
),

      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 10),
          Text("Salário Mensal: R\$ ${_salarioMensal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("Saldo restante: R\$ ${_saldo.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_gastos[index]['descricao']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editarGasto(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _excluirGasto(index),
                      ),
                    ],
                  ),
                  subtitle: Text("R\$ ${_gastos[index]['valor'].toStringAsFixed(2)}"),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGastoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
