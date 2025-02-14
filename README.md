📱 App de Avaliação - LP3
📌 Sobre o Projeto
Este é um aplicativo Flutter desenvolvido para a disciplina de Linguagem de Programação 3 (LP3). O objetivo do projeto é criar um sistema de avaliação, onde usuários podem se autenticar, avaliar itens e visualizar suas avaliações.

O app utiliza Firebase para autenticação e armazenamento de dados, garantindo uma experiência segura e dinâmica.

🚀 Tecnologias Utilizadas
O projeto foi construído com as seguintes tecnologias:

Flutter - Framework para desenvolvimento mobile
Dart - Linguagem de programação
Firebase Authentication - Gerenciamento de usuários
Firebase Firestore - Banco de dados NoSQL em tempo real
Provider / Riverpod - Gerenciamento de estado (caso usado)
Material Design - Interface moderna e responsiva
📂 Estrutura do Projeto
css
Copiar
Editar
📦 avl
 ┣ 📂 lib
 ┃ ┣ 📂 mainpage
 ┃ ┃ ┗ 📜 main_page.dart
 ┃ ┣ 📂 pages
 ┃ ┃ ┣ 📜 login_page.dart
 ┃ ┃ ┗ 📜 register_page.dart
 ┃ ┣ 📂 services
 ┃ ┃ ┗ 📜 firebase_options.dart
 ┃ ┣ 📜 main.dart
 ┗ 📜 pubspec.yaml
🔧 Como Executar o Projeto
1️⃣ Pré-requisitos
Antes de começar, certifique-se de ter:

Flutter instalado (>=3.x.x)
Conta e projeto configurado no Firebase
Chave de configuração do Firebase (google-services.json ou firebase_options.dart)
2️⃣ Clonar o Repositório
sh
Copiar
Editar
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
3️⃣ Instalar Dependências
sh
Copiar
Editar
flutter pub get
4️⃣ Configurar o Firebase
Certifique-se de adicionar o google-services.json (Android) e GoogleService-Info.plist (iOS) corretamente.

5️⃣ Rodar o App
sh
Copiar
Editar
flutter run
🔐 Funcionalidades
✅ Autenticação com Firebase (Login e Cadastro)
✅ Avaliação de itens (Notas e Comentários)
✅ Armazenamento de avaliações no Firestore
✅ Interface Responsiva
✅ Controle de Estado

🛠️ Melhorias Futuras
📌 Implementar um sistema de feedback visual das avaliações
📌 Criar um painel administrativo para gerenciar avaliações
📌 Melhorar a experiência do usuário com animações

📌 Autor
👨‍💻 [Rodrigo Henriky]
📧 [R.henriky@prontomail.com]
🔗 [https://www.linkedin.com/in/rodrigo-henriky-5a4145268/https://github.com/rhenriky/]

📌 Trabalho desenvolvido para a disciplina de LP3 - Linguagem de Programação 3