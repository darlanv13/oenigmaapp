import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Se você nomeou o seu banco como 'oenigma', ajuste para: FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'oenigma')
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('E-mail não encontrado.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      } else if (e.code == 'invalid-email') {
        throw Exception('O e-mail fornecido é inválido.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Este usuário foi desativado.');
      }
      throw Exception(e.message ?? 'Erro ao fazer login.');
    } catch (e) {
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    try {
      // 1. Cria a conta de autenticação
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Se a conta foi criada com sucesso, cria o documento no banco de dados
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'telefone': phone,
          'chavePix': cpf, // CPF travado como chave PIX!
          'tipoChavePix': 'CPF',
          'saldo_carteira': 0.0,
          'saldo_moedas': 0,
          'enigmas_resolvidos_total': 0,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      // Traduzimos os erros mais comuns do Firebase para português
      if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está cadastrado.');
      } else if (e.code == 'weak-password') {
        throw Exception('A senha fornecida é muito fraca.');
      } else if (e.code == 'invalid-email') {
        throw Exception('O e-mail fornecido é inválido.');
      }
      throw Exception(e.message ?? 'Erro ao criar conta no Firebase.');
    } catch (e) {
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }
}
