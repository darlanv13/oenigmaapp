//const { initializeApp } = require("firebase-admin/app");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require('firebase-admin');
admin.initializeApp({
    // Adicione esta linha para ele saber qual banco usar:
    databaseId: "oenigma"
});

// 1. Configuração Global (Gen 2)
// Garante que todas as funções rodem no servidor de São Paulo, reduzindo o delay.
setGlobalOptions({ region: "southamerica-east1" });

// 2. Inicializa o Admin SDK
// Ele puxa as credenciais e o ID do projeto ("oenigma") automaticamente do ambiente.
//initializeApp();

// Importação dos módulos (Features)
const solveEnigmaFeature = require("./src/features/game/solveEnigma");
const buyHintFeature = require("./src/features/shop/buyHint");
const withdrawFundsFeature = require("./src/features/wallet/withdrawFunds");
const updateRankFeature = require("./src/features/leaderboard/updateRank");

// Exportação das rotas
exports.game = {
    solveEnigma: solveEnigmaFeature.solveEnigma
};

exports.shop = {
    buyHint: buyHintFeature.buyHint
};

exports.wallet = {
    withdraw: withdrawFundsFeature.withdrawFunds
};

exports.leaderboard = {
    triggerUpdate: updateRankFeature.onUserScoreUpdated
};