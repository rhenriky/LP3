import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  File? _imagemSelecionada;
  String? _imagemCaminho;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  /// Carrega as configurações salvas no SharedPreferences
  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _nomeController.text = prefs.getString('userName') ?? "Usuário";
      _imagemCaminho = prefs.getString('profileImage');
    });
  }

  /// Salva as configurações no SharedPreferences
  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('userName', _nomeController.text);
    if (_imagemSelecionada != null) {
      await prefs.setString('profileImage', _imagemSelecionada!.path);
    }
  }

  /// Seleciona uma imagem da galeria
  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
        _imagemCaminho = imagem.path;
      });
      _salvarPreferencias();
    }
  }

  /// Altera a senha do usuário
  Future<void> _alterarSenha() async {
    if (_senhaAtualController.text.isEmpty ||
        _novaSenhaController.text.isEmpty) {
      _mostrarMensagem("⚠ Preencha todos os campos.");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _senhaAtualController.text,
      );

      // Reautenticação antes de alterar a senha
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_novaSenhaController.text);

      _mostrarMensagem("✅ Senha alterada com sucesso!");
      _senhaAtualController.clear();
      _novaSenhaController.clear();
    } catch (e) {
      _mostrarMensagem("❌ Erro ao alterar senha: ${e.toString()}");
    }
  }

  /// Realiza logout do usuário
  Future<void> _logout() async {
    bool confirmarSaida = await _mostrarDialogoConfirmacao();
    if (!confirmarSaida) return;

    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  /// Exibe uma mensagem de feedback na tela
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  /// Exibe um diálogo de confirmação antes de sair da conta
  Future<bool> _mostrarDialogoConfirmacao() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Sair da Conta"),
            content: const Text("Tem certeza que deseja sair da sua conta?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Sair", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙ Configurações")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar do usuário
            Center(
              child: GestureDetector(
                onTap: _selecionarImagem,
                child: CircleAvatar(
                  radius: 50,
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

            // Nome do usuário
            _buildTextField(
                controller: _nomeController,
                label: "Nome do Usuário",
                icon: Icons.person),

            const SizedBox(height: 20),

            // Alternar Tema (Modo Escuro)
            ListTile(
              leading: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text("Modo Escuro"),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  _salvarPreferencias();
                },
              ),
            ),
            const Divider(),

            // Ativar/Desativar Notificações
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notificações"),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _salvarPreferencias();
                },
              ),
            ),
            const Divider(),

            // Alteração de senha
            const Text("🔑 Alterar Senha",
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTextField(
                controller: _senhaAtualController,
                label: "Senha Atual",
                icon: Icons.lock,
                obscure: true),
            _buildTextField(
                controller: _novaSenhaController,
                label: "Nova Senha",
                icon: Icons.lock_outline,
                obscure: true),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _alterarSenha,
              child: const Text("Salvar Nova Senha"),
            ),
            const SizedBox(height: 20),

            // Botão de Logout
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("🚪 Sair da Conta",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget reutilizável para inputs de texto
  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
