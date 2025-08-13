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
  double _saldo = 1518.0;
  List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saldo = prefs.getDouble('saldo') ?? 1518.0;
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

  Future<void> _addGasto(String descricao, double valor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _gastos.add({"descricao": descricao, "valor": valor});
      _saldo -= valor;
    });
    await prefs.setDouble('saldo', _saldo);
    await prefs.setStringList(
        'gastos', _gastos.map((e) => "${e['descricao']}|${e['valor']}").toList());
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
        title: Text("Bem-vindo, ${widget.username}"),
        actions: [
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
          Text("Saldo restante: R\$ ${_saldo.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_gastos[index]['descricao']),
                  trailing: Text("- R\$ ${_gastos[index]['valor'].toStringAsFixed(2)}"),
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
