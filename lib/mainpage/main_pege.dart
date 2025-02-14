import 'package:avl/cadastro_produto.dart/produto_list_page.dart';
import 'package:avl/cart/pages/cart_page.dart';
import 'package:avl/cart/pages/profile_page.dart';
import 'package:avl/cart/pages/settings.dart';
import 'package:avl/pages/main.dart';
import 'package:avl/visualizar_produto.dart/visul_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainPege extends StatefulWidget {
  const MainPege({super.key});

  @override
  State<MainPege> createState() => _MainPegeState();
}

class _MainPegeState extends State<MainPege> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: <Widget>[
        const HomePage(),
        const ProfilePage(),
        const ProdutoListPage(),
        const CartPage(),
        const SettingsPage(),
        const VisualizarProdutoPage(
          produto: {},
        ),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(
              icon: Icon(Icons.production_quantity_limits), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'comentarios'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'configurações'),
        ],
      ),
    );
  }
}
