-- Estrutura inicial do banco MySQL na Hostinger
-- Banco: u145350224_crmmei

CREATE TABLE IF NOT EXISTS app_state (
    id VARCHAR(50) PRIMARY KEY,
    dados_json LONGTEXT NOT NULL,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pedidos_recebidos (
    id VARCHAR(50) PRIMARY KEY,
    nome_cliente VARCHAR(255) NOT NULL,
    telefone VARCHAR(50),
    bairro VARCHAR(255),
    servico_solicitado VARCHAR(255),
    observacoes TEXT,
    valor_base DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'combinando',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
