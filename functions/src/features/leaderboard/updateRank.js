const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");

// Escuta alterações em qualquer documento dentro da coleção "users"
exports.onUserScoreUpdated = onDocumentUpdated("users/{userId}", async (event) => {
    const newValue = event.data.after.data();
    const previousValue = event.data.before.data();

    // Só roda o código se a pontuação de enigmas realmente mudou
    if (newValue.enigmas_resolvidos_total === previousValue.enigmas_resolvidos_total) {
        return null;
    }

    const db = getFirestore("oenigma");

    // Busca os 50 melhores jogadores
    const topUsersQuery = await db.collection("users")
        .orderBy("enigmas_resolvidos_total", "desc")
        .limit(50)
        .get();

    const top50 = [];
    topUsersQuery.forEach(doc => {
        const data = doc.data();
        top50.push({
            uid: doc.id,
            nome: data.nome,
            pontos: data.enigmas_resolvidos_total
        });
    });

    // Salva num documento único. O Flutter só precisa ler ESTE documento para mostrar o Ranking!
    await db.collection("leaderboard").doc("global_top_50").set({
        ranking: top50,
        atualizadoEm: new Date().toISOString()
    });

    console.log("Ranking Top 50 atualizado com sucesso.");
    return null;
});