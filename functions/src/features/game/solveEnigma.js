const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { isLocationValid } = require("../../utils/antiCheat");

exports.solveEnigma = onCall(async (request) => {
    // 1. Verifica se o usuário está logado
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Você precisa estar logado para jogar.");
    }

    const uid = request.auth.uid;
    const { enigmaId, qrCodeScanned, userLat, userLon } = request.data;
    const db = getFirestore("oenigma");

    // 2. Usamos uma Transação para evitar concorrência (Race Conditions)
    return await db.runTransaction(async (transaction) => {
        const enigmaRef = db.collection("enigmas").doc(enigmaId);
        const userRef = db.collection("users").doc(uid);
        const userProgressRef = userRef.collection("solved_enigmas").doc(enigmaId);

        const enigmaSnap = await transaction.get(enigmaRef);
        const progressSnap = await transaction.get(userProgressRef);

        if (!enigmaSnap.exists) {
            throw new HttpsError("not-found", "Enigma não encontrado.");
        }

        // 3. Verifica se já resolveu (Evita farmar dinheiro no mesmo enigma)
        if (progressSnap.exists) {
            throw new HttpsError("already-exists", "Você já resolveu este enigma!");
        }

        const enigmaData = enigmaSnap.data();

        // 4. ANTI-CHEAT: Validação do QR Code
        if (enigmaData.tipo_resposta === "QRCODE" && enigmaData.codigo_qr_esperado !== qrCodeScanned) {
            throw new HttpsError("invalid-argument", "QR Code inválido.");
        }

        // 5. ANTI-CHEAT: Validação de GPS (Distância)
        if (!isLocationValid(userLat, userLon, enigmaData.lat, enigmaData.lon)) {
            throw new HttpsError("failed-precondition", "Você está muito longe do local do enigma! Chegue mais perto.");
        }

        // 6. Sucesso! Aplicar as recompensas
        transaction.set(userProgressRef, { solvedAt: FieldValue.serverTimestamp() });

        if (enigmaData.modo === "ACHE_E_GANHE") {
            // Adiciona dinheiro na carteira de forma segura
            transaction.update(userRef, {
                saldo_carteira: FieldValue.increment(enigmaData.premio_dinheiro)
            });
            return { success: true, message: `Você ganhou R$ ${enigmaData.premio_dinheiro}!` };
        }

        if (enigmaData.modo === "SUPER_PREMIO") {
            // Aumenta a pontuação para o Ranking
            transaction.update(userRef, {
                enigmas_resolvidos_total: FieldValue.increment(1)
            });
            return { success: true, message: "Enigma resolvido! Posição no ranking atualizada." };
        }
    });
});