<?php
/**
 * Backend API RESTful para o CRM Parceiro Autônomo
 * Conexão direta com MySQL da Hostinger (entendalegal.com)
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurações do Banco de Dados Hostinger
$db_host = 'localhost'; // No servidor Hostinger o host padrão é localhost
$db_name = 'u145350224_crmmei';
$db_user = 'u145350224_crmmei';
$db_pass = '211324@Lu';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    // Cria a tabela de sincronização caso ainda não exista
    $pdo->exec("CREATE TABLE IF NOT EXISTS app_state (
        id VARCHAR(50) PRIMARY KEY,
        dados_json LONGTEXT NOT NULL,
        atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro de conexão com o banco de dados MySQL: ' . $e->getMessage()
    ]);
    exit();
}

$action = $_GET['action'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'obter') {
    $stmt = $pdo->prepare("SELECT dados_json, atualizado_em FROM app_state WHERE id = 'parceiro_autonomo_principal' LIMIT 1");
    $stmt->execute();
    $row = $stmt->fetch();

    if ($row) {
        echo json_encode([
            'status' => 'success',
            'state' => json_decode($row['dados_json'], true),
            'atualizado_em' => $row['atualizado_em']
        ]);
    } else {
        echo json_encode([
            'status' => 'empty',
            'message' => 'Nenhum dado salvo ainda no banco.'
        ]);
    }
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action === 'salvar') {
    $rawInput = file_get_contents('php://input');
    $payload = json_decode($rawInput, true);

    if (!$payload || !isset($payload['state'])) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Payload inválido']);
        exit();
    }

    $jsonStr = json_encode($payload['state'], JSON_UNESCAPED_UNICODE);

    $stmt = $pdo->prepare("INSERT INTO app_state (id, dados_json) 
                           VALUES ('parceiro_autonomo_principal', :json)
                           ON DUPLICATE KEY UPDATE dados_json = :json_update");
    $stmt->execute([
        ':json' => $jsonStr,
        ':json_update' => $jsonStr
    ]);

    echo json_encode([
        'status' => 'success',
        'message' => 'Dados salvos com sucesso no banco MySQL da Hostinger!'
    ]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action === 'novo_pedido_site') {
    $rawInput = file_get_contents('php://input');
    $payload = json_decode($rawInput, true);

    if (!$payload) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Dados inválidos']);
        exit();
    }

    // Carrega o estado atual
    $stmt = $pdo->prepare("SELECT dados_json FROM app_state WHERE id = 'parceiro_autonomo_principal' LIMIT 1");
    $stmt->execute();
    $row = $stmt->fetch();

    $state = $row ? json_decode($row['dados_json'], true) : [];

    if (!isset($state['servicos'])) $state['servicos'] = [];
    if (!isset($state['clientes'])) $state['clientes'] = [];

    // Adiciona o novo cliente e serviço
    if (isset($payload['cliente'])) {
        array_unshift($state['clientes'], $payload['cliente']);
    }
    if (isset($payload['servico'])) {
        array_unshift($state['servicos'], $payload['servico']);
    }

    $jsonStr = json_encode($state, JSON_UNESCAPED_UNICODE);
    $stmtSave = $pdo->prepare("INSERT INTO app_state (id, dados_json) 
                               VALUES ('parceiro_autonomo_principal', :json)
                               ON DUPLICATE KEY UPDATE dados_json = :json_update");
    $stmtSave->execute([
        ':json' => $jsonStr,
        ':json_update' => $jsonStr
    ]);

    echo json_encode([
        'status' => 'success',
        'message' => 'Pedido gravado no banco de dados!'
    ]);
    exit();
}

echo json_encode([
    'status' => 'online',
    'app' => 'CRM Parceiro Autônomo API',
    'banco' => $db_name
]);
