const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

// Disparado sempre que um novo documento for criado na coleção 'users'
exports.onCreateUser = onDocumentCreated("users/{userId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        logger.log("Nenhum dado associado ao evento.");
        return;
    }

    const userData = snapshot.data();

    // Evita loop infinito caso o documento já tenha customId ou for uma atualização disfarçada
    if (userData.customId) return;

    // Pegar o nome (se não tiver, usa 'USR')
    let namePart = 'USR';
    if (userData.nome && typeof userData.nome === 'string') {
        const cleanName = userData.nome.trim().replace(/[^a-zA-Z]/g, '').toUpperCase();
        if (cleanName.length >= 3) {
            namePart = cleanName.substring(0, 3);
        } else if (cleanName.length > 0) {
            namePart = cleanName.padEnd(3, 'X');
        }
    }

    // Pegar CPF (chavePix) (se não tiver, usa 00000)
    let cpfPart = '00000';
    if (userData.chavePix && typeof userData.chavePix === 'string') {
        const cleanCpf = userData.chavePix.replace(/\D/g, ''); // só números
        if (cleanCpf.length >= 5) {
            cpfPart = cleanCpf.substring(0, 5);
        } else if (cleanCpf.length > 0) {
            cpfPart = cleanCpf.padEnd(5, '0');
        }
    }

    const customId = `${namePart}${cpfPart}`;

    logger.log(`Gerando customId para o usuário ${event.params.userId}: ${customId}`);

    // Atualiza o documento adicionando o customId
    return snapshot.ref.update({
        customId: customId
    });
});
