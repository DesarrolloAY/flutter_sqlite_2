import 'package:flutter/material.dart';
import 'package:flutter_sqlite_2/database_helper.dart';
import 'libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _EditTituloLibro = TextEditingController();
  List<Libro> _items = [];

  @override
  void initState() {
    super.initState();
    _cargarListaLibros();
  }

  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);
    await _dbHelper.insertLibro(nuevoLibro);
    print("SE AGREGO UN NUEVO LIBRO");
    _cargarListaLibros();
    // Limpieza del campo donde se agrega el libro, luego de agregar uno
    _EditTituloLibro.clear();
  }

  void _mostrarVentajasAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Titulo"),
          content: TextField(
            controller: _EditTituloLibro,
            decoration: const InputDecoration(hintText: "Ingrese el titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  _agregarNuevoLibro(_EditTituloLibro.text.toString());
                  Navigator.of(context).pop();
                }
              },
              child: Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();
  }

  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estas seguro de que quieres elimnar este libro?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id);
                Navigator.of(context).pop();
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController _tituloController = TextEditingController(
      text: tituloActual,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modificar Titulo del Libro"),
          content: TextField(
            controller: _tituloController,
            decoration: InputDecoration(hintText: "Escribe el nuevo titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, _tituloController.text.toString());
                }
                Navigator.of(context).pop();
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final libro = _items[index];
          return ListTile(
            title: Text(libro.tituloLibro),
            subtitle: Text('ID: ${libro.id}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.grey),
              onPressed: () {
                _mostrarMensajeModificar(int.parse(libro.id.toString()));
              },
            ),
            onTap: () {
              _ventanaEditar(int.parse(libro.id.toString()), libro.tituloLibro);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarVentajasAgregar,
        child: Icon(Icons.add),
      ),
    );
  }
}
