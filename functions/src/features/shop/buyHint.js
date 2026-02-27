const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

exports.buyHint = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Faça login para comprar dicas.");
    }

    const uid = request.auth.uid;
    const { enigmaId, hintId } = request.data;
    const db = getFirestore("oenigma");

    return await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(uid);
        const hintRef = db.collection("hints").doc(hintId); // Dica global
        const unlockedHintRef = userRef.collection("unlocked_hints").doc(hintId); // Dica do usuário

        // Lemos os dados necessários
        const userSnap = await transaction.get(userRef);
        const hintSnap = await transaction.get(hintRef);
        const unlockedSnap = await transaction.get(unlockedHintRef);

        if (!hintSnap.exists) throw new HttpsError("not-found", "Dica não encontrada.");
        if (unlockedSnap.exists) throw new HttpsError("already-exists", "Você já comprou esta dica.");

        const userData = userSnap.data();
        const hintData = hintSnap.data();
        const custoMoedas = hintData.preco_moedas;

        // Validação de saldo
        if ((userData.saldo_moedas || 0) < custoMoedas) {
            throw new HttpsError("failed-precondition", "EnigmaCoins insuficientes. Compre mais na loja.");
        }

        // 1. Debita o saldo do usuário
        transaction.update(userRef, {
            saldo_moedas: FieldValue.increment(-custoMoedas)
        });

        // 2. Libera a dica para o usuário ler
        transaction.set(unlockedHintRef, {
            enigmaId: enigmaId,
            conteudo: hintData.conteudo, // Transfere o texto/url da imagem para o user
            compradoEm: FieldValue.serverTimestamp()
        });

        return { success: true, message: "Dica desbloqueada com sucesso!", conteudo: hintData.conteudo };
    });
});