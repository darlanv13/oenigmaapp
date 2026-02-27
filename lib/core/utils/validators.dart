class AppValidators {
  static String? validarCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CPF é obrigatório.';
    }

    // Remove tudo que não for número
    String cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) {
      return 'O CPF deve ter 11 dígitos.';
    }

    // Bloqueia CPFs com todos os números iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return 'CPF inválido.';
    }

    // Cálculo do primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = 11 - (soma % 11);
    int digito1 = resto >= 10 ? 0 : resto;
    if (digito1 != int.parse(cpf[9])) {
      return 'CPF inválido.';
    }

    // Cálculo do segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = 11 - (soma % 11);
    int digito2 = resto >= 10 ? 0 : resto;
    if (digito2 != int.parse(cpf[10])) {
      return 'CPF inválido.';
    }

    return null; // Retorna nulo se o CPF for verdadeiro
  }

  static String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O E-mail é obrigatório.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  static String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'O Telefone é obrigatório.';
    }
    if (value.length < 14) {
      return 'Digite um telefone válido.';
    }
    return null;
  }
}
