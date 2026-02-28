import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oenigma/features/auth/presentation/controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Máscaras de formatação visual
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  void _realizarCadastro() {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String senha = _passwordController.text;
      final String cpfLimpo = _cpfMask.getUnmaskedText();
      final String phoneLimpo = _phoneMask.getUnmaskedText();

      // Chama o Riverpod para processar
      ref
          .read(authControllerProvider.notifier)
          .registerUser(
            email: email,
            password: senha,
            cpf: cpfLimpo,
            phone: phoneLimpo,
            onSuccess: () {
              // Se deu certo, mostra mensagem e manda ele de volta pro jogo!
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta criada com sucesso! Bem-vindo!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Como usamos o "Deferred Authentication", mandamos ele direto pra Home ou pra tela que ele estava tentando acessar
              while (context.canPop()) {
                context.pop();
              }
              context.pushReplacementNamed('home');
            },
            onError: (erro) {
              // Se deu erro (ex: email repetido), mostra em vermelho
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(erro), backgroundColor: Colors.red),
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Junte-se à Caçada!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu CPF será usado exclusivamente como sua Chave PIX para os saques. Preencha com atenção.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo de E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(FontAwesomeIcons.envelope),
                  border: OutlineInputBorder(),
                ),
                validator: AppValidators.validarEmail,
              ),
              const SizedBox(height: 16),

              // Campo de CPF (Com máscara e validador matemático)
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfMask], // Aplica a formatação
                decoration: const InputDecoration(
                  labelText: 'CPF (Sua Chave PIX)',
                  prefixIcon: Icon(FontAwesomeIcons.idCard),
                  border: OutlineInputBorder(),
                ),
                validator: AppValidators.validarCPF,
              ),
              const SizedBox(height: 16),

              // Campo de Telefone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                decoration: const InputDecoration(
                  labelText: 'Telefone (WhatsApp)',
                  prefixIcon: Icon(FontAwesomeIcons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: AppValidators.validarTelefone,
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(FontAwesomeIcons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'A senha deve ter pelo menos 6 caracteres.',
              ),
              const SizedBox(height: 32),

              // Escuta o estado do AuthController
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authControllerProvider);

                  if (authState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ElevatedButton(
                    onPressed: _realizarCadastro,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Finalizar Cadastro',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
