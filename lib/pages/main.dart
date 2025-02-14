import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avl/cadastro_produto.dart/cadastro.produto.dart';
import 'package:avl/visualizar_produto.dart/visul_page.dart';
import 'package:avl/cadastro_produto.dart/produto_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> produtos = [];
  bool _carregando = true; // Para exibir um loader enquanto os produtos são carregados

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  /// Carrega os produtos do SharedPreferences
  Future<void> _carregarProdutos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? produtosString = prefs.getString('produtos');
    if (produtosString != null) {
      setState(() {
        produtos = List<Map<String, dynamic>>.from(json.decode(produtosString));
      });
    }
    setState(() => _carregando = false);
  }

  /// Abre a tela de cadastro e recarrega a lista ao retornar
  Future<void> _abrirCadastroProduto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroProdutoPage()),
    );
    if (resultado == true) {
      _carregarProdutos();
    }
  }

  /// Abre a lista de produtos
  void _abrirListaProdutos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProdutoListPage()),
    );
  }

  /// Abre um produto específico para visualização
  void _abrirVisualizarProduto() {
    if (produtos.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarProdutoPage(produto: produtos[0]),
        ),
      );
    } else {
      _mostrarMensagem("❌ Nenhum produto cadastrado para visualizar.");
    }
  }

  /// Exibe um alerta ao usuário
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏠 Gerenciamento de Produtos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _carregando
            ? const Center(child: CircularProgressIndicator()) // Loader ao carregar
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBotao(
                    icone: Icons.add_box,
                    titulo: "Cadastrar Produto",
                    cor: Colors.green,
                    onPress: _abrirCadastroProduto,
                  ),
                  const SizedBox(height: 20),
                  _buildBotao(
                    icone: Icons.list,
                    titulo: "Lista de Produtos",
                    cor: Colors.blue,
                    onPress: _abrirListaProdutos,
                  ),
                  const SizedBox(height: 20),
                  _buildBotao(
                    icone: Icons.search,
                    titulo: "Visualizar Produto",
                    cor: Colors.orange,
                    onPress: _abrirVisualizarProduto,
                  ),
                ],
              ),
      ),
    );
  }

  /// Widget para criar os botões de ação
  Widget _buildBotao({
    required IconData icone,
    required String titulo,
    required Color cor,
    required VoidCallback onPress,
  }) {
    return ElevatedButton.icon(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icone, size: 28),
      label: Text(
        titulo,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
