const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

exports.withdrawFunds = onCall(async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Não autorizado.");

    const uid = request.auth.uid;
    const { valorSaque, chavePix } = request.data;
    const db = getFirestore("oenigma");

    // Validação básica
    if (valorSaque < 20) {
        throw new HttpsError("invalid-argument", "O valor mínimo para saque é R$ 20,00.");
    }

    return await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(uid);
        const userSnap = await transaction.get(userRef);
        const userData = userSnap.data();

        // Evita que o usuário tente sacar mais do que tem
        if ((userData.saldo_carteira || 0) < valorSaque) {
            throw new HttpsError("failed-precondition", "Saldo insuficiente.");
        }

        // 1. Debita o valor IMEDIATAMENTE do saldo do app
        transaction.update(userRef, {
            saldo_carteira: FieldValue.increment(-valorSaque)
        });

        // 2. Cria o pedido na fila de saques para você aprovar/pagar
        const withdrawalRef = db.collection("withdraw_requests").doc();
        transaction.set(withdrawalRef, {
            uid: uid,
            valor: valorSaque,
            chavePix: chavePix,
            status: "PENDENTE", // Pode ser PENDENTE, PAGO, RECUSADO
            solicitadoEm: FieldValue.serverTimestamp()
        });

        return { success: true, message: "Saque solicitado! Em breve o valor estará na sua conta." };
    });
});