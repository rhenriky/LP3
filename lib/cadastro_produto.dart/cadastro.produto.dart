import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _marcaController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();
  final _descricaoController = TextEditingController();
  File? _imagemFile;

  /// Escolhe uma imagem e armazena no Firebase Storage
  Future<String?> _uploadImagem(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('produtos/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Escolhe uma imagem da galeria
  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemFile = File(imagem.path);
      });
    }
  }

  /// Salva os dados do produto no Firestore
  Future<void> _salvarProduto() async {
    if (_nomeController.text.isEmpty ||
        _marcaController.text.isEmpty ||
        _categoriaController.text.isEmpty ||
        _precoController.text.isEmpty ||
        _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    String? imageUrl;
    if (_imagemFile != null) {
      imageUrl = await _uploadImagem(_imagemFile!);
    }

    await FirebaseFirestore.instance.collection('produtos').add({
      'nome': _nomeController.text,
      'marca': _marcaController.text,
      'categoria': _categoriaController.text,
      'preco': double.tryParse(_precoController.text) ?? 0.0,
      'descricao': _descricaoController.text,
      'imagem': imageUrl,
      'comentarios': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produto cadastrado com sucesso!")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _precoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preço',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição Detalhada',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Exibição da Imagem
            _imagemFile != null
                ? Image.file(
                    _imagemFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100),

            // Botão para Escolher Imagem
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Escolher Imagem'),
              onPressed: _escolherImagem,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _salvarProduto,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Salvar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
