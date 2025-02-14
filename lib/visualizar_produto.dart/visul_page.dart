import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisualizarProdutoPage extends StatefulWidget {
  final Map<String, dynamic> produto;

  const VisualizarProdutoPage({super.key, required this.produto});

  @override
  _VisualizarProdutoPageState createState() => _VisualizarProdutoPageState();
}

class _VisualizarProdutoPageState extends State<VisualizarProdutoPage> {
  final _comentarioController = TextEditingController();
  int _avaliacao = 3;
  List<dynamic> _comentarios = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  /// Obtém o ID do usuário autenticado e carrega os comentários
  Future<void> _carregarUsuario() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      _carregarComentarios();
    }
  }

  /// Carrega os comentários do produto para o usuário autenticado
  Future<void> _carregarComentarios() async {
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? comentariosString = prefs.getString('comentarios_$userId');

    if (comentariosString != null) {
      List<Map<String, dynamic>> comentarios =
          List<Map<String, dynamic>>.from(json.decode(comentariosString));

      setState(() {
        _comentarios = comentarios
            .where((c) => c['produto'] == widget.produto['nome'])
            .toList();
      });
    }
  }

  /// Adiciona um novo comentário ao produto
  Future<void> _adicionarComentario() async {
    if (_comentarioController.text.trim().isEmpty) {
      _mostrarMensagem("Digite um comentário antes de enviar.");
      return;
    }

    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> comentarios = [];

    final String? comentariosString = prefs.getString('comentarios_$userId');
    if (comentariosString != null) {
      comentarios =
          List<Map<String, dynamic>>.from(json.decode(comentariosString));
    }

    final novoComentario = {
      'produto': widget.produto['nome'],
      'comentario': _comentarioController.text.trim(),
      'avaliacao': _avaliacao,
    };

    comentarios.add(novoComentario);

    await prefs.setString('comentarios_$userId', json.encode(comentarios));

    setState(() {
      _comentarios.add(novoComentario);
      _comentarioController.clear();
      _avaliacao = 3;
    });

    _mostrarMensagem("Comentário adicionado com sucesso!");
  }

  /// Exibe uma mensagem de feedback na tela
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.produto['nome'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Center(
              child: widget.produto['imagem'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(widget.produto['imagem']),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 15),

            // Nome do produto
            Text(
              widget.produto['nome'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Descrição do produto
            Text(
              widget.produto['descricao'],
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),

            // Campo de comentário
            const Text(
              "Deixe seu comentário:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite seu comentário...",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            // Seletor de estrelas para avaliação
            const Text(
              "Avaliação:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _avaliacao ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _avaliacao = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),

            // Botão de comentar
            ElevatedButton.icon(
              onPressed: _adicionarComentario,
              icon: const Icon(Icons.send),
              label: const Text("Enviar Comentário"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const Divider(height: 30),

            // Lista de comentários
            const Text(
              "Seus Comentários:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _comentarios.isEmpty
                ? const Center(
                    child: Text("Ainda não há comentários."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comentarios.length,
                    itemBuilder: (context, index) {
                      final comentario = _comentarios[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading:
                              const Icon(Icons.comment, color: Colors.blue),
                          title: Text(
                            comentario['comentario'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Row(
                            children: List.generate(
                              5,
                              (starIndex) => Icon(
                                starIndex < comentario['avaliacao']
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
