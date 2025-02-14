import 'package:avl/mainpage/main_pege.dart';
import 'package:avl/pages/signup_page.dart';
import 'package:avl/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  /// Exibe uma mensagem na tela
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Valida email e senha antes de tentar login
  bool _validarCampos() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _mostrarMensagem("Digite um e-mail válido.");
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      _mostrarMensagem("A senha deve ter pelo menos 6 caracteres.");
      return false;
    }
    return true;
  }

  /// Tenta fazer login com email e senha
  Future<void> _login() async {
    if (!_validarCampos() || _loading) return;

    setState(() => _loading = true);
    try {
      UserServices userServices = UserServices();
      bool sucesso = await userServices.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (sucesso) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainPege()));
      } else {
        _mostrarMensagem("Erro ao fazer login. Verifique suas credenciais.");
      }
    } catch (e) {
      _mostrarMensagem("Erro: ${e.toString()}");
    }
    setState(() => _loading = false);
  }

  /// Login com Google (mantendo foto do Google)
  Future<void> _loginComGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        // Verifica se o usuário já existe no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Se não existir, adiciona ao Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'userName': user.displayName ?? '',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'profileImageUrl': user.photoURL ?? '',
          });
        }
      }

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainPege()));
    } catch (e) {
      _mostrarMensagem("Erro ao fazer login com Google.");
    }
    setState(() => _loading = false);
  }

  /// Recuperação de senha
  Future<void> _recuperarSenha() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _mostrarMensagem("Digite um e-mail válido para recuperar a senha.");
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      _mostrarMensagem("E-mail de recuperação enviado com sucesso!");
    } catch (e) {
      _mostrarMensagem("Erro ao enviar e-mail de recuperação.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const MainPege();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo ou imagem de destaque
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                        'assets/images/videos/avalia__es-de-produtos.jpg',
                        height: 200,
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 30),

                // Texto de boas-vindas
                const Text(
                  'Bem-vindo ao App de Avaliação de Produtos',
                  style: TextStyle(
                      color: Color(0xFF0C7280),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Senha (com botão de mostrar/ocultar)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Esqueceu a senha?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _recuperarSenha,
                    child: const Text('Esqueceu a senha?',
                        style: TextStyle(
                            color: Color(0xFF0838B2),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),

                // Botão de login
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Login com Google
                OutlinedButton(
                  onPressed: _loginComGoogle,
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/videos/Logo-Google-G.png',
                          width: 30),
                      const SizedBox(width: 10),
                      _loading
                          ? const CircularProgressIndicator()
                          : const Text("Login com Google",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link para cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ainda não tem conta?'),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage())),
                      child: const Text('Registre-se!',
                          style: TextStyle(
                              color: Color(0xFF082775),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
