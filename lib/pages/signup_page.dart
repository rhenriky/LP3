import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:avl/services/user_services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  XFile? _imagemSelecionada;
  String? _imagemUrl;
  final bool _obscurePassword = true;
  bool _loading = false;

  /// Seleciona uma imagem da galeria
  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = imagem;
      });
    }
  }

  /// Faz upload da imagem para Firebase Storage
  Future<String?> _uploadImagem(XFile imagem) async {
    try {
      final File file = File(imagem.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('usuarios/${FirebaseAuth.instance.currentUser?.uid ?? DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

      return await ref.getDownloadURL();
    } catch (e) {
      _mostrarMensagem("❌ Erro ao fazer upload da imagem. Verifique sua conexão.");
      return null;
    }
  }

  /// Valida os campos antes de cadastrar
  bool _validarCampos() {
    if (userNameController.text.trim().isEmpty) {
      _mostrarMensagem("Digite seu nome.");
      return false;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
      _mostrarMensagem("Digite um e-mail válido.");
      return false;
    }
    if (passwordController.text.trim().isEmpty || passwordController.text.length < 6) {
      _mostrarMensagem("A senha deve ter pelo menos 6 caracteres.");
      return false;
    }
    if (phoneController.text.trim().isEmpty || phoneController.text.length < 9) {
      _mostrarMensagem("Digite um telefone válido.");
      return false;
    }
    if (_imagemSelecionada == null) {
      _mostrarMensagem("Selecione uma imagem de perfil.");
      return false;
    }
    return true;
  }

  /// Exibe uma mensagem na tela
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  /// Realiza o cadastro no Firebase
  Future<void> _registrar() async {
    if (!_validarCampos() || _loading) return;

    setState(() => _loading = true);

    _imagemUrl = await _uploadImagem(_imagemSelecionada!);
    if (_imagemUrl == null) {
      setState(() => _loading = false);
      return;
    }

    UserServices userServices = UserServices();
    bool sucesso = await userServices.signUp(
      userNameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      phoneController.text.trim(),
      _imagemUrl!,
    );

    if (sucesso) {
      _mostrarMensagem("✅ Cadastro realizado com sucesso!");
      Navigator.pop(context);
    } else {
      _mostrarMensagem("❌ Erro ao registrar. Tente novamente.");
    }

    setState(() => _loading = false);
  }

  /// Login com Google usando FirebaseAuth
  Future<void> _loginComGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensagem("❌ Erro ao fazer login com Google.");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📝 Registre-se!',
                style: TextStyle(
                    color: Color(0xFF0C7280),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Imagem de perfil
              Center(
                child: GestureDetector(
                  onTap: _selecionarImagem,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imagemSelecionada != null
                        ? FileImage(File(_imagemSelecionada!.path))
                        : null,
                    child: _imagemSelecionada == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Campos de entrada
              _buildTextField(controller: userNameController, label: 'Nome', icon: Icons.person),
              _buildTextField(controller: emailController, label: 'Email', icon: Icons.email),
              _buildTextField(controller: passwordController, label: 'Senha', icon: Icons.lock, obscure: true),
              _buildTextField(controller: phoneController, label: 'Telefone', icon: Icons.phone),
              const SizedBox(height: 20),

              // Botão de registro
              ElevatedButton(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              // Login com Google
              OutlinedButton(
                onPressed: _loginComGoogle,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: const Text("Login com Google",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget reutilizável para inputs de texto
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool obscure = false}) {
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
