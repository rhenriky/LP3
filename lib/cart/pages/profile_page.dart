import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nome = "Carregando...";
  String _email = "Carregando...";
  String _telefone = "Carregando...";
  String? _imagemCaminho;
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _comentarios = [];

  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  /// Carrega os dados do usuário e produtos salvos no SharedPreferences
  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nome = prefs.getString('userName') ?? "Usuário";
      _email = prefs.getString('userEmail') ?? "email@exemplo.com";
      _telefone = prefs.getString('userPhone') ?? "(00) 00000-0000";
      _imagemCaminho = prefs.getString('profileImage');
      _nomeController.text = _nome;

      final String? produtosString = prefs.getString('produtos');
      if (produtosString != null) {
        _produtos =
            List<Map<String, dynamic>>.from(json.decode(produtosString));
      }

      // Filtra todos os comentários feitos pelo usuário
      for (var produto in _produtos) {
        if (produto.containsKey('comentarios')) {
          for (var comentario in produto['comentarios']) {
            _comentarios.add({
              'produto': produto['nome'],
              'comentario': comentario['comentario'],
              'avaliacao': comentario['avaliacao'],
            });
          }
        }
      }
    });
  }

  /// Salva o nome atualizado no SharedPreferences
  Future<void> _salvarNome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nomeController.text);

    setState(() {
      _nome = _nomeController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nome atualizado com sucesso!")),
    );
  }

  /// Permite escolher e atualizar a imagem de perfil
  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemCaminho = imagem.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', imagem.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagem de perfil atualizada!")),
      );
    }
  }

  /// Faz logout limpando os dados do usuário
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto do usuário
            Center(
              child: GestureDetector(
                onTap: _escolherImagem,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imagemCaminho != null
                      ? FileImage(File(_imagemCaminho!))
                      : null,
                  child: _imagemCaminho == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nome do Usuário (Editável)
            const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text("Nome:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite seu nome",
              ),
            ),
            const SizedBox(height: 10),

            // Email do Usuário (Apenas Visualização)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("E-mail:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(_email),
            ),
            const SizedBox(height: 10),

            // Telefone do Usuário (Apenas Visualização)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Telefone:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(_telefone),
            ),
            const SizedBox(height: 20),

            // Botão para salvar apenas o nome
            ElevatedButton(
              onPressed: _salvarNome,
              child: const Text('Salvar Nome'),
            ),
            const SizedBox(height: 20),

            // Lista de produtos cadastrados pelo usuário
            const Divider(),
            const Text("Produtos Cadastrados",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _produtos.isEmpty
                ? const Text("Nenhum produto cadastrado.")
                : Column(
                    children: _produtos.map((produto) {
                      return ListTile(
                        leading: produto['imagem'] != null
                            ? Image.memory(base64Decode(produto['imagem']),
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 50),
                        title: Text(produto['nome']),
                        subtitle: Text(produto['descricao']),
                      );
                    }).toList(),
                  ),
            const Divider(),

            // Lista de comentários feitos pelo usuário
            const Text("Comentários Realizados",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _comentarios.isEmpty
                ? const Text("Nenhum comentário realizado.")
                : Column(
                    children: _comentarios.map((comentario) {
                      return ListTile(
                        leading: const Icon(Icons.comment, color: Colors.blue),
                        title: Text(comentario['produto']),
                        subtitle: Text(
                            "⭐ ${comentario['avaliacao']} - ${comentario['comentario']}"),
                      );
                    }).toList(),
                  ),
            const Divider(height: 20),

            // Botão de Logout
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sair da Conta",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
