const admin = require('firebase-admin');

// 1. Importa o ficheiro JSON que acabou de baixar
const serviceAccount = require('./serviceAccountKey.json');

// 2. Inicializa o Admin usando a sua chave de segurança
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseId: "oenigma"
});

const db = admin.firestore();

async function seedDatabase() {
    console.log("⏳ Iniciando o povoamento do banco de dados do O Enigma...");

    try {
        // ==========================================
        // 1. POVOAR UTILIZADORES (Mock)
        // ==========================================
        const userRef = db.collection('users').doc('mock_admin_uid_123');
        await userRef.set({
            nome: "Darlan",
            email: "admin@oenigma.com",
            telefone: "+5511999999999",
            saldo_carteira: 150.00,
            saldo_moedas: 50,
            enigmas_resolvidos_total: 12,
            posicao_ranking: 1,
            role: "admin",
            criadoEm: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log("✅ Utilizador 'Darlan' criado com sucesso.");

        // ==========================================
        // 2. POVOAR EVENTOS
        // ==========================================
        const eventsRef = db.collection('events');

        // Evento 1: Super Prêmio (Baseado na sua imagem de referência)
        await eventsRef.doc('evento_lula_viado_001').set({
            nome: "Lula Viado",
            descricao: "TESTE",
            local: "Marabá",
            data_evento: "18/03/2026",
            fases: 0,
            premio_total: 1000.00,
            valor_inscricao: 10.00,
            ativo: true,
            tipo_evento: "SUPER_PREMIO",
            imagem_url: "", // Para futura implementação
            criadoEm: admin.firestore.FieldValue.serverTimestamp()
        });

        // Evento 2: Super Prêmio (Baseado na sua imagem de referência)
        await eventsRef.doc('evento_pioca_doce_002').set({
            nome: "Pioca Doce",
            descricao: "Evento especial na praça principal.",
            local: "Marabá",
            data_evento: "19/03/2026",
            fases: 3,
            premio_total: 1000.00,
            valor_inscricao: 10.00,
            ativo: true,
            tipo_evento: "SUPER_PREMIO",
            imagem_url: "",
            criadoEm: admin.firestore.FieldValue.serverTimestamp()
        });

        // Evento 3: Ache e Ganhe (Grátis)
        await eventsRef.doc('evento_ache_ganhe_003').set({
            nome: "Enigma do Cofre",
            descricao: "Encontre o QR Code escondido e ganhe dinheiro na hora.",
            local: "Centro Histórico",
            data_evento: "Disponível Agora",
            fases: 1,
            premio_total: 50.00,
            valor_inscricao: 0.00, // Grátis
            ativo: true,
            tipo_evento: "ACHE_E_GANHE",
            imagem_url: "",
            criadoEm: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log("✅ Eventos criados com sucesso.");

        // ==========================================
        // 3. POVOAR ENIGMAS DENTRO DOS EVENTOS
        // ==========================================
        const enigmasRef = db.collection('enigmas');

        await enigmasRef.doc('enigma_teste_001').set({
            eventoId: "evento_lula_viado_001",
            titulo: "A Árvore Centenária",
            pergunta: "Estou onde a água encontra a pedra, mas não sou rio. Escaneie meu código.",
            dica_gratis: "Procure perto da estátua principal.",
            lat: -5.3678, // Coordenadas fictícias
            lon: -49.1234,
            tipo_resposta: "QRCODE",
            codigo_qr_esperado: "oenigma_secreto_001",
            premio_dinheiro: 0.00, // Porque o prêmio é no evento final
            modo: "SUPER_PREMIO"
        });
        console.log("✅ Enigmas criados com sucesso.");

        console.log("🎉 Povoamento concluído! O seu banco está pronto para testes.");
        process.exit(0);

    } catch (error) {
        console.error("❌ Erro ao povoar o banco:", error);
        process.exit(1);
    }
}

seedDatabase();