import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oenigma/firebase_options.dart';

// Importaremos nossas rotas e temas da pasta core
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Garante que os bindings do Flutter estejam prontos antes de iniciar coisas nativas (como Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase (Descomente quando configurar o Firebase CLI no seu projeto)

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // O ProviderScope é o "abraço" do Riverpod no seu app.
  // Ele permite que qualquer tela acesse os estados que vamos criar.
  runApp(const ProviderScope(child: OEnigmaApp()));
}

// Usamos ConsumerWidget do Riverpod em vez do StatelessWidget padrão
class OEnigmaApp extends ConsumerWidget {
  const OEnigmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutamos as configurações de rotas que criaremos no app_router.dart
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'O Enigma',
      debugShowCheckedModeBanner: false, // Tira aquela faixa de "Debug"
      theme: AppTheme.lightTheme, // Usaremos um tema centralizado
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respeita o tema do celular do usuário
      // Configuração do go_router
      routerConfig: router,
    );
  }
}
