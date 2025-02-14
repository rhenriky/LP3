import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _comentarios = [];

  @override
  void initState() {
    super.initState();
    _carregarComentarios();
  }

  /// Carrega os comentários do SharedPreferences
  Future<void> _carregarComentarios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? produtosString = prefs.getString('produtos');

    if (produtosString != null) {
      List<Map<String, dynamic>> produtos =
          List<Map<String, dynamic>>.from(json.decode(produtosString));

      List<Map<String, dynamic>> produtosComComentarios = [];

      for (var produto in produtos) {
        if (produto.containsKey('comentarios') &&
            (produto['comentarios'] as List).isNotEmpty) {
          for (var comentario in produto['comentarios']) {
            produtosComComentarios.add({
              'nome': produto['nome'],
              'imagem': produto['imagem'],
              'comentario': comentario['comentario'],
              'avaliacao': comentario['avaliacao'],
            });
          }
        }
      }

      setState(() {
        _comentarios = produtosComComentarios;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: _comentarios.isEmpty
          ? const Center(
              child: Text(
                'Nenhum comentário encontrado!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _comentarios.length,
              itemBuilder: (context, index) {
                final comentario = _comentarios[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    leading: comentario['imagem'] != null
                        ? Image.memory(base64Decode(comentario['imagem']),
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    title: Text(comentario['nome'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comentário: ${comentario['comentario']}",
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < (comentario['avaliacao'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
