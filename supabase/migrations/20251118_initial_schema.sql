-- MIGRATION: Estrutura inicial do banco de dados NOIR Fashion
-- Data: 2025-11-18
-- Descrição: Criação das tabelas principais do sistema de e-commerce

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER TABLE IF EXISTS produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS pedidos ENABLE ROW LEVEL SECURITY;

-- TABELA: produtos
CREATE TABLE IF NOT EXISTS produtos (
    id_produto UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('women', 'men', 'accessories', 'limited')),
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    preco_promocional DECIMAL(10,2) CHECK (preco_promocional >= 0),
    sku VARCHAR(100) UNIQUE NOT NULL,
    codigo_barras VARCHAR(100),
    material VARCHAR(255),
    pais_origem VARCHAR(100),
    sustentavel BOOLEAN DEFAULT FALSE,
    edicao_limitada BOOLEAN DEFAULT FALSE,
    quantidade_limitada INTEGER CHECK (quantidade_limitada > 0),
    data_lancamento TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'esgotado')),
    peso DECIMAL(8,2) CHECK (peso > 0),
    dimensoes JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para produtos
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON produtos(categoria);
CREATE INDEX IF NOT EXISTS idx_produtos_status ON produtos(status);
CREATE INDEX IF NOT EXISTS idx_produtos_preco ON produtos(preco);
CREATE INDEX IF NOT EXISTS idx_produtos_sku ON produtos(sku);
CREATE INDEX IF NOT EXISTS idx_produtos_data_lancamento ON produtos(data_lancamento);

-- TABELA: produto_variacoes
CREATE TABLE IF NOT EXISTS produto_variacoes (
    id_variacao UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    tamanho VARCHAR(10),
    cor VARCHAR(50),
    cor_hex VARCHAR(7) CHECK (cor_hex ~ '^#[A-Fa-f0-9]{6}$'),
    estoque INTEGER DEFAULT 0 CHECK (estoque >= 0),
    estoque_minimo INTEGER DEFAULT 5 CHECK (estoque_minimo >= 0),
    sku_variacao VARCHAR(100) UNIQUE,
    preco_adicional DECIMAL(8,2) DEFAULT 0,
    imagem_destaque VARCHAR(500),
    status VARCHAR(20) DEFAULT 'disponivel' CHECK (status IN ('disponivel', 'esgotado', 'em_producao')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para produto_variacoes
CREATE INDEX IF NOT EXISTS idx_produto_variacoes_produto ON produto_variacoes(id_produto);
CREATE INDEX IF NOT EXISTS idx_produto_variacoes_sku ON produto_variacoes(sku_variacao);
CREATE INDEX IF NOT EXISTS idx_produto_variacoes_status ON produto_variacoes(status);

-- TABELA: produto_imagens
CREATE TABLE IF NOT EXISTS produto_imagens (
    id_imagem UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    id_variacao UUID REFERENCES produto_variacoes(id_variacao) ON DELETE CASCADE,
    url_imagem VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    ordem INTEGER DEFAULT 0,
    principal BOOLEAN DEFAULT FALSE,
    tipo VARCHAR(20) DEFAULT 'principal' CHECK (tipo IN ('principal', 'detalhe', 'lifestyle', '360')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para produto_imagens
CREATE INDEX IF NOT EXISTS idx_produto_imagens_produto ON produto_imagens(id_produto);
CREATE INDEX IF NOT EXISTS idx_produto_imagens_variacao ON produto_imagens(id_variacao);
CREATE INDEX IF NOT EXISTS idx_produto_imagens_principal ON produto_imagens(principal);

-- TABELA: clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    sobrenome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20),
    data_nascimento DATE,
    genero VARCHAR(1) CHECK (genero IN ('M', 'F', 'O', 'N')),
    tipo_cliente VARCHAR(20) DEFAULT 'regular' CHECK (tipo_cliente IN ('regular', 'vip', 'premium')),
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'suspenso')),
    email_verificado BOOLEAN DEFAULT FALSE,
    data_cadastro TIMESTAMP DEFAULT NOW(),
    ultima_compra TIMESTAMP,
    total_compras DECIMAL(12,2) DEFAULT 0 CHECK (total_compras >= 0),
    preferencias JSONB,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para clientes
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_status ON clientes(status);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON clientes(tipo_cliente);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf ON clientes(cpf);

-- TABELA: enderecos
CREATE TABLE IF NOT EXISTS enderecos (
    id_endereco UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_cliente UUID NOT NULL REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    apelido VARCHAR(100),
    tipo VARCHAR(20) DEFAULT 'residencial' CHECK (tipo IN ('residencial', 'comercial', 'cobranca', 'entrega')),
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    pais VARCHAR(50) DEFAULT 'Brasil',
    principal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para enderecos
CREATE INDEX IF NOT EXISTS idx_enderecos_cliente ON enderecos(id_cliente);
CREATE INDEX IF NOT EXISTS idx_enderecos_principal ON enderecos(principal);

-- TABELA: pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_cliente UUID NOT NULL REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    id_endereco UUID NOT NULL REFERENCES enderecos(id_endereco),
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'confirmado', 'processando', 'enviado', 'entregue', 'cancelado', 'devolvido')),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    frete DECIMAL(8,2) NOT NULL CHECK (frete >= 0),
    desconto DECIMAL(8,2) DEFAULT 0 CHECK (desconto >= 0),
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    forma_pagamento VARCHAR(20) CHECK (forma_pagamento IN ('cartao_credito', 'cartao_debito', 'paypal', 'boleto', 'pix')),
    parcelas INTEGER DEFAULT 1 CHECK (parcelas > 0),
    valor_parcela DECIMAL(8,2) CHECK (valor_parcela >= 0),
    data_pedido TIMESTAMP DEFAULT NOW(),
    data_confirmacao TIMESTAMP,
    data_envio TIMESTAMP,
    data_entrega TIMESTAMP,
    codigo_rastreamento VARCHAR(100),
    transportadora VARCHAR(100),
    prazo_entrega_dias INTEGER CHECK (prazo_entrega_dias > 0),
    observacoes TEXT,
    motivo_cancelamento TEXT,
    cupom_desconto VARCHAR(50),
    ip_compra VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para pedidos
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(id_cliente);
CREATE INDEX IF NOT EXISTS idx_pedidos_status ON pedidos(status);
CREATE INDEX IF NOT EXISTS idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX IF NOT EXISTS idx_pedidos_numero ON pedidos(numero_pedido);

-- TABELA: pedido_itens
CREATE TABLE IF NOT EXISTS pedido_itens (
    id_item UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_pedido UUID NOT NULL REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    id_produto UUID NOT NULL REFERENCES produtos(id_produto),
    id_variacao UUID REFERENCES produto_variacoes(id_variacao),
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    preco_total DECIMAL(10,2) NOT NULL CHECK (preco_total >= 0),
    desconto_item DECIMAL(8,2) DEFAULT 0 CHECK (desconto_item >= 0),
    nome_produto VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    tamanho VARCHAR(10),
    cor VARCHAR(50),
    imagem_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para pedido_itens
CREATE INDEX IF NOT EXISTS idx_pedido_itens_pedido ON pedido_itens(id_pedido);
CREATE INDEX IF NOT EXISTS idx_pedido_itens_produto ON pedido_itens(id_produto);
CREATE INDEX IF NOT EXISTS idx_pedido_itens_variacao ON pedido_itens(id_variacao);

-- TABELA: carrinho
CREATE TABLE IF NOT EXISTS carrinho (
    id_carrinho UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_cliente UUID REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    id_sessao VARCHAR(255),
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW(),
    expira_em TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'abandonado', 'convertido'))
);

-- Índices para carrinho
CREATE INDEX IF NOT EXISTS idx_carrinho_cliente ON carrinho(id_cliente);
CREATE INDEX IF NOT EXISTS idx_carrinho_sessao ON carrinho(id_sessao);
CREATE INDEX IF NOT EXISTS idx_carrinho_status ON carrinho(status);
CREATE INDEX IF NOT EXISTS idx_carrinho_expira ON carrinho(expira_em);

-- TABELA: carrinho_itens
CREATE TABLE IF NOT EXISTS carrinho_itens (
    id_item UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_carrinho UUID NOT NULL REFERENCES carrinho(id_carrinho) ON DELETE CASCADE,
    id_produto UUID NOT NULL REFERENCES produtos(id_produto),
    id_variacao UUID REFERENCES produto_variacoes(id_variacao),
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    preco_total DECIMAL(10,2) NOT NULL CHECK (preco_total >= 0),
    adicionado_em TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para carrinho_itens
CREATE INDEX IF NOT EXISTS idx_carrinho_itens_carrinho ON carrinho_itens(id_carrinho);
CREATE INDEX IF NOT EXISTS idx_carrinho_itens_produto ON carrinho_itens(id_produto);
CREATE INDEX IF NOT EXISTS idx_carrinho_itens_variacao ON carrinho_itens(id_variacao);

-- TABELA: pagamentos
CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_pedido UUID NOT NULL REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    tipo_pagamento VARCHAR(20) NOT NULL CHECK (tipo_pagamento IN ('cartao_credito', 'cartao_debito', 'paypal', 'boleto', 'pix')),
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processando', 'aprovado', 'negado', 'estornado', 'cancelado')),
    valor DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    parcelas INTEGER DEFAULT 1 CHECK (parcelas > 0),
    gateway_pagamento VARCHAR(50),
    transaction_id VARCHAR(255),
    nsu VARCHAR(100),
    autorizacao VARCHAR(100),
    codigo_antifraude VARCHAR(100),
    score_antifraude DECIMAL(3,2) CHECK (score_antifraude >= 0 AND score_antifraude <= 100),
    motivo_negativa TEXT,
    data_pagamento TIMESTAMP,
    data_confirmacao TIMESTAMP,
    data_estorno TIMESTAMP,
    dados_cartao JSONB,
    dados_paypal JSONB,
    dados_pix JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para pagamentos
CREATE INDEX IF NOT EXISTS idx_pagamentos_pedido ON pagamentos(id_pedido);
CREATE INDEX IF NOT EXISTS idx_pagamentos_status ON pagamentos(status);
CREATE INDEX IF NOT EXISTS idx_pagamentos_tipo ON pagamentos(tipo_pagamento);
CREATE INDEX IF NOT EXISTS idx_pagamentos_transaction ON pagamentos(transaction_id);

-- TABELA: avaliacoes
CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    id_cliente UUID NOT NULL REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    id_pedido UUID NOT NULL REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    nota INTEGER CHECK (nota >= 1 AND nota <= 5),
    titulo VARCHAR(255),
    comentario TEXT,
    recomenda BOOLEAN,
    aprovado BOOLEAN DEFAULT FALSE,
    data_avaliacao TIMESTAMP DEFAULT NOW(),
    util_para INTEGER DEFAULT 0 CHECK (util_para >= 0),
    nao_util_para INTEGER DEFAULT 0 CHECK (nao_util_para >= 0),
    resposta_loja TEXT,
    data_resposta TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para avaliacoes
CREATE INDEX IF NOT EXISTS idx_avaliacoes_produto ON avaliacoes(id_produto);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_cliente ON avaliacoes(id_cliente);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_pedido ON avaliacoes(id_pedido);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_nota ON avaliacoes(nota);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_aprovado ON avaliacoes(aprovado);

-- TABELA: cupons
CREATE TABLE IF NOT EXISTS cupons (
    id_cupom UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    tipo_desconto VARCHAR(20) NOT NULL CHECK (tipo_desconto IN ('percentual', 'fixo', 'frete_gratis')),
    valor_desconto DECIMAL(8,2) NOT NULL CHECK (valor_desconto >= 0),
    valor_minimo DECIMAL(10,2) DEFAULT 0 CHECK (valor_minimo >= 0),
    valor_maximo_desconto DECIMAL(10,2) CHECK (valor_maximo_desconto >= 0),
    quantidade_total INTEGER CHECK (quantidade_total > 0),
    quantidade_usada INTEGER DEFAULT 0 CHECK (quantidade_usada >= 0),
    validade_inicio TIMESTAMP,
    validade_fim TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    unico_por_cliente BOOLEAN DEFAULT FALSE,
    novo_cliente BOOLEAN DEFAULT FALSE,
    categoria_aplicavel VARCHAR(20) DEFAULT 'all' CHECK (categoria_aplicavel IN ('all', 'women', 'men', 'accessories', 'limited')),
    produtos_aplicaveis JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para cupons
CREATE INDEX IF NOT EXISTS idx_cupons_codigo ON cupons(codigo);
CREATE INDEX IF NOT EXISTS idx_cupons_ativo ON cupons(ativo);
CREATE INDEX IF NOT EXISTS idx_cupons_validade ON cupons(validade_inicio, validade_fim);

-- TABELA: lista_desejos
CREATE TABLE IF NOT EXISTS lista_desejos (
    id_item UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_cliente UUID NOT NULL REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    id_variacao UUID REFERENCES produto_variacoes(id_variacao) ON DELETE CASCADE,
    adicionado_em TIMESTAMP DEFAULT NOW(),
    notificacao_disponivel BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(id_cliente, id_produto, id_variacao)
);

-- Índices para lista_desejos
CREATE INDEX IF NOT EXISTS idx_lista_desejos_cliente ON lista_desejos(id_cliente);
CREATE INDEX IF NOT EXISTS idx_lista_desejos_produto ON lista_desejos(id_produto);
CREATE INDEX IF NOT EXISTS idx_lista_desejos_notificacao ON lista_desejos(notificacao_disponivel);

-- TABELA: fornecedores
CREATE TABLE IF NOT EXISTS fornecedores (
    id_fornecedor UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    email VARCHAR(255),
    telefone VARCHAR(20),
    endereco TEXT,
    pais VARCHAR(50),
    certificacao_etica BOOLEAN DEFAULT FALSE,
    certificacoes JSONB,
    prazo_entrega INTEGER CHECK (prazo_entrega > 0),
    moeda VARCHAR(3) DEFAULT 'BRL',
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para fornecedores
CREATE INDEX IF NOT EXISTS idx_fornecedores_cnpj ON fornecedores(cnpj);
CREATE INDEX IF NOT EXISTS idx_fornecedores_status ON fornecedores(status);
CREATE INDEX IF NOT EXISTS idx_fornecedores_certificacao ON fornecedores(certificacao_etica);

-- TABELA: estoque_movimento
CREATE TABLE IF NOT EXISTS estoque_movimento (
    id_movimento UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    id_variacao UUID NOT NULL REFERENCES produto_variacoes(id_variacao) ON DELETE CASCADE,
    tipo_movimento VARCHAR(20) NOT NULL CHECK (tipo_movimento IN ('entrada', 'saida', 'ajuste', 'devolucao', 'perda')),
    quantidade INTEGER NOT NULL,
    quantidade_anterior INTEGER NOT NULL,
    quantidade_nova INTEGER NOT NULL,
    motivo VARCHAR(255),
    id_pedido UUID REFERENCES pedidos(id_pedido) ON DELETE SET NULL,
    id_fornecedor UUID REFERENCES fornecedores(id_fornecedor) ON DELETE SET NULL,
    custo_unitario DECIMAL(10,2) CHECK (custo_unitario >= 0),
    custo_total DECIMAL(12,2) CHECK (custo_total >= 0),
    data_movimento TIMESTAMP DEFAULT NOW(),
    id_admin UUID,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para estoque_movimento
CREATE INDEX IF NOT EXISTS idx_estoque_movimento_produto ON estoque_movimento(id_produto);
CREATE INDEX IF NOT EXISTS idx_estoque_movimento_variacao ON estoque_movimento(id_variacao);
CREATE INDEX IF NOT EXISTS idx_estoque_movimento_tipo ON estoque_movimento(tipo_movimento);
CREATE INDEX IF NOT EXISTS idx_estoque_movimento_data ON estoque_movimento(data_movimento);
CREATE INDEX IF NOT EXISTS idx_estoque_movimento_pedido ON estoque_movimento(id_pedido);

-- TABELA: historico_precos
CREATE TABLE IF NOT EXISTS historico_precos (
    id_historico UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_produto UUID NOT NULL REFERENCES produtos(id_produto) ON DELETE CASCADE,
    id_variacao UUID REFERENCES produto_variacoes(id_variacao) ON DELETE CASCADE,
    preco_anterior DECIMAL(10,2) NOT NULL CHECK (preco_anterior >= 0),
    preco_novo DECIMAL(10,2) NOT NULL CHECK (preco_novo >= 0),
    motivo_alteracao VARCHAR(20) NOT NULL CHECK (motivo_alteracao IN ('promocao', 'ajuste_custo', 'campanha', 'reajuste')),
    data_alteracao TIMESTAMP DEFAULT NOW(),
    id_admin UUID,
    cupom_aplicavel VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para historico_precos
CREATE INDEX IF NOT EXISTS idx_historico_precos_produto ON historico_precos(id_produto);
CREATE INDEX IF NOT EXISTS idx_historico_precos_variacao ON historico_precos(id_variacao);
CREATE INDEX IF NOT EXISTS idx_historico_precos_data ON historico_precos(data_alteracao);

-- Function para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON produtos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_enderecos_updated_at BEFORE UPDATE ON enderecos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pedidos_updated_at BEFORE UPDATE ON pedidos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pagamentos_updated_at BEFORE UPDATE ON pagamentos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_avaliacoes_updated_at BEFORE UPDATE ON avaliacoes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cupons_updated_at BEFORE UPDATE ON cupons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fornecedores_updated_at BEFORE UPDATE ON fornecedores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function para calcular total do pedido
CREATE OR REPLACE FUNCTION calcular_total_pedido(pedido_id UUID)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(preco_total), 0) + frete - desconto
    INTO total
    FROM pedidos
    WHERE id_pedido = pedido_id;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Function para atualizar estoque
CREATE OR REPLACE FUNCTION atualizar_estoque_variacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza estoque na tabela de variações
    UPDATE produto_variacoes 
    SET estoque = NEW.quantidade_nova 
    WHERE id_variacao = NEW.id_variacao;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar estoque automaticamente
CREATE TRIGGER trigger_atualizar_estoque
    AFTER INSERT ON estoque_movimento
    FOR EACH ROW EXECUTE FUNCTION atualizar_estoque_variacao();

-- Function para validar estoque antes de confirmar pedido
CREATE OR REPLACE FUNCTION validar_estoque_pedido()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
    estoque_disponivel INTEGER;
BEGIN
    -- Verifica estoque para cada item do pedido
    FOR item IN SELECT * FROM pedido_itens WHERE id_pedido = NEW.id_pedido
    LOOP
        SELECT estoque INTO estoque_disponivel 
        FROM produto_variacoes 
        WHERE id_variacao = item.id_variacao;
        
        IF estoque_disponivel < item.quantidade THEN
            RAISE EXCEPTION 'Estoque insuficiente para variação %', item.id_variacao;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function para registrar movimento de estoque ao confirmar pedido
CREATE OR REPLACE FUNCTION registrar_movimento_pedido()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
BEGIN
    -- Registrar saída de estoque para cada item
    FOR item IN SELECT * FROM pedido_itens WHERE id_pedido = NEW.id_pedido
    LOOP
        INSERT INTO estoque_movimento (
            id_produto, id_variacao, tipo_movimento, quantidade,
            quantidade_anterior, quantidade_nova, motivo, id_pedido
        ) VALUES (
            item.id_produto, item.id_variacao, 'saida', item.quantidade,
            (SELECT estoque FROM produto_variacoes WHERE id_variacao = item.id_variacao),
            (SELECT estoque - item.quantidade FROM produto_variacoes WHERE id_variacao = item.id_variacao),
            'Pedido confirmado', NEW.id_pedido
        );
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security Policies
-- Permitir leitura pública de produtos ativos
CREATE POLICY "Produtos ativos são visíveis publicamente" ON produtos
    FOR SELECT USING (status = 'ativo');

-- Permitir leitura pública de imagens de produtos
CREATE POLICY "Imagens de produtos são visíveis publicamente" ON produto_imagens
    FOR SELECT USING (true);

-- Permitir leitura pública de variações de produtos ativos
CREATE POLICY "Variações de produtos ativos são visíveis" ON produto_variacoes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM produtos 
            WHERE produtos.id_produto = produto_variacoes.id_produto 
            AND produtos.status = 'ativo'
        )
    );

-- Inserir dados iniciais de exemplo
INSERT INTO produtos (nome, descricao, categoria, preco, sku, material, pais_origem, sustentavel, edicao_limitada, status) VALUES
    ('Urban Edge Jacket', 'Jaqueta urbana com design moderno e cortes assimétricos', 'women', 299.00, 'URB-EDGE-001', 'Algodão Premium', 'Brasil', true, false, 'ativo'),
    ('Midnight Luxe Dress', 'Vestido de luxo em edição limitada com detalhes em renda', 'women', 899.00, 'MID-LUXE-001', 'Seda Italiana', 'Itália', false, true, 'ativo'),
    ('Neo Classic Blazer', 'Blazer clássico com toque moderno para o homem contemporâneo', 'men', 399.00, 'NEO-CLASS-001', 'Lã Virgem', 'Portugal', true, false, 'ativo'),
    ('Accent Pieces Bag', 'Bolsa de mão artesanal com detalhes metálicos', 'accessories', 149.00, 'ACC-BAG-001', 'Couro Legítimo', 'Brasil', true, false, 'ativo'),
    ('Spring Bloom Blouse', 'Blusa leve com estampa floral para a primavera', 'women', 249.00, 'SPR-BLOOM-001', 'Viscose', 'Brasil', true, false, 'ativo'),
    ('Street Rebel Hoodie', 'Moletom urbano com estampa rebelde', 'men', 199.00, 'STR-REBEL-001', 'Algodão Fleece', 'Brasil', false, false, 'ativo'),
    ('Avant Garde Coat', 'Casaco de alta costura em edição ultra limitada', 'limited', 1299.00, 'AVANT-GARDE-001', 'Cashmere Premium', 'França', true, true, 'ativo'),
    ('Minimal Chic Watch', 'Relógio minimalista com design atemporal', 'accessories', 89.00, 'MIN-WATCH-001', 'Aço Inoxidável', 'Suíça', true, false, 'ativo');

-- Inserir variações de exemplo
INSERT INTO produto_variacoes (id_produto, tamanho, cor, cor_hex, estoque, estoque_minimo, sku_variacao, preco_adicional, status) VALUES
    -- Urban Edge Jacket
    ((SELECT id_produto FROM produtos WHERE sku = 'URB-EDGE-001'), 'P', 'Preto', '#000000', 15, 5, 'URB-EDGE-001-P-PRETO', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'URB-EDGE-001'), 'M', 'Preto', '#000000', 12, 5, 'URB-EDGE-001-M-PRETO', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'URB-EDGE-001'), 'G', 'Preto', '#000000', 8, 5, 'URB-EDGE-001-G-PRETO', 0, 'disponivel'),
    
    -- Midnight Luxe Dress (edição limitada)
    ((SELECT id_produto FROM produtos WHERE sku = 'MID-LUXE-001'), 'P', 'Azul Meia Noite', '#191970', 5, 2, 'MID-LUXE-001-P-AZUL', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'MID-LUXE-001'), 'M', 'Azul Meia Noite', '#191970', 3, 2, 'MID-LUXE-001-M-AZUL', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'MID-LUXE-001'), 'G', 'Azul Meia Noite', '#191970', 2, 2, 'MID-LUXE-001-G-AZUL', 0, 'disponivel'),
    
    -- Neo Classic Blazer
    ((SELECT id_produto FROM produtos WHERE sku = 'NEO-CLASS-001'), 'M', 'Cinza', '#808080', 10, 5, 'NEO-CLASS-001-M-CINZA', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'NEO-CLASS-001'), 'G', 'Cinza', '#808080', 8, 5, 'NEO-CLASS-001-G-CINZA', 0, 'disponivel'),
    ((SELECT id_produto FROM produtos WHERE sku = 'NEO-CLASS-001'), 'GG', 'Cinza', '#808080', 6, 5, 'NEO-CLASS-001-GG-CINZA', 0, 'disponivel');

-- Inserir cupons de desconto iniciais
INSERT INTO cupons (codigo, tipo_desconto, valor_desconto, valor_minimo, quantidade_total, validade_inicio, validade_fim, ativo, categoria_aplicavel) VALUES
    ('NOIR10', 'percentual', 10.00, 200.00, 100, NOW(), NOW() + INTERVAL '30 days', true, 'all'),
    ('FRETEGRATIS', 'frete_gratis', 0, 300.00, 50, NOW(), NOW() + INTERVAL '15 days', true, 'all'),
    ('VIP20', 'percentual', 20.00, 500.00, 25, NOW(), NOW() + INTERVAL '60 days', true, 'all'),
    ('SUSTENTAVEL15', 'percentual', 15.00, 150.00, 75, NOW(), NOW() + INTERVAL '45 days', true, 'all');

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant specific permissions for RLS
GRANT SELECT ON produtos TO anon;
GRANT SELECT ON produtos TO authenticated;
GRANT SELECT ON produto_variacoes TO anon;
GRANT SELECT ON produto_variacoes TO authenticated;
GRANT SELECT ON produto_imagens TO anon;
GRANT SELECT ON produto_imagens TO authenticated;
GRANT SELECT ON avaliacoes TO anon;
GRANT SELECT ON avaliacoes TO authenticated;