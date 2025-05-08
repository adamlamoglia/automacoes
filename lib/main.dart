import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload PDF',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Upload PDF para n8n'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedFile;
  bool _isUploading = false;
  String _statusMessage = '';

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _statusMessage = 'Arquivo selecionado: ${result.files.single.name}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao selecionar arquivo: $e';
      });
    }
  }

  Future<void> _uploadToN8n() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = 'Por favor, selecione um arquivo PDF primeiro';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = 'Enviando arquivo...';
    });

    try {
      // Substitua esta URL pela URL do seu webhook do n8n
      final url = Uri.parse('SUA_URL_DO_N8N_AQUI');
      
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      setState(() {
        _isUploading = false;
        if (response.statusCode == 200) {
          _statusMessage = 'Arquivo enviado com sucesso!';
        } else {
          _statusMessage = 'Erro ao enviar arquivo: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Erro ao enviar arquivo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickPDF,
              icon: const Icon(Icons.file_upload),
              label: const Text('Selecionar PDF'),
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Text(
                'Arquivo selecionado: ${_selectedFile!.path.split('/').last}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadToN8n,
              icon: const Icon(Icons.send),
              label: const Text('Enviar para n8n'),
            ),
            const SizedBox(height: 20),
            if (_isUploading)
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
