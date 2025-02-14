import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avl/cadastro_produto.dart/cadastro.produto.dart';
import 'package:avl/visualizar_produto.dart/visul_page.dart';

class ProdutoListPage extends StatefulWidget {
  const ProdutoListPage({super.key});

  @override
  _ProdutoListPageState createState() => _ProdutoListPageState();
}

class _ProdutoListPageState extends State<ProdutoListPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  /// Obtém o ID do usuário autenticado e carrega os produtos
  Future<void> _carregarUsuario() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  /// Remove um produto do Firestore
  Future<void> _removerProduto(String produtoId) async {
    await FirebaseFirestore.instance.collection('produtos').doc(produtoId).delete();
  }

  /// Calcula a média das avaliações do produto
  double _calcularMediaAvaliacoes(Map<String, dynamic> produto) {
    List<dynamic> comentarios = produto['comentarios'] ?? [];
    if (comentarios.isEmpty) return 0.0;

    double totalEstrelas = 0;
    for (var comentario in comentarios) {
      totalEstrelas += (comentario['avaliacao'] ?? 0).toDouble();
    }
    return totalEstrelas / comentarios.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Meus Produtos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produtos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '❌ Nenhum produto cadastrado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          final produtos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index].data() as Map<String, dynamic>;
              final String produtoId = produtos[index].id;
              final double mediaEstrelas = _calcularMediaAvaliacoes(produto);
              final List<dynamic> comentarios = produto['comentarios'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: produto['imagem'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            produto['imagem'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 60);
                            },
                          ),
                        )
                      : const Icon(Icons.image, size: 60),
                  title: Text(
                    produto['nome'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto['descricao'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      _buildEstrelas(mediaEstrelas),
                      const SizedBox(height: 5),

                      // Exibir os últimos 2 comentários (se houver)
                      if (comentarios.isNotEmpty) ...[
                        for (var i = 0; i < (comentarios.length > 2 ? 2 : comentarios.length); i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.comment, size: 16, color: Colors.blue),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "⭐ ${comentarios[i]['avaliacao']} - ${comentarios[i]['comentario']}",
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisualizarProdutoPage(produto: produto),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmarRemocao(produtoId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroProdutoPage()),
          );
          if (resultado == true) {
            setState(() {}); // Recarrega a tela
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Novo Produto"),
      ),
    );
  }

  /// Constrói o widget de estrelas de avaliação
  Widget _buildEstrelas(double mediaEstrelas) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < mediaEstrelas.round() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }

  /// Exibe um diálogo de confirmação antes de remover um produto
  void _confirmarRemocao(String produtoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠ Remover Produto"),
        content: const Text("Tem certeza que deseja remover este produto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _removerProduto(produtoId);
              Navigator.pop(context);
            },
            child: const Text("Remover", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
