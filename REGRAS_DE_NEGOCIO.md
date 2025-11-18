# REGRAS DE NEGÓCIO - NOIR FASHION E-COMMERCE

## 1. VISÃO GERAL DO NEGÓCIO

O NOIR Fashion é uma loja de e-commerce especializada em moda premium que oferece:
- Coleções de roupas para mulheres, homens e acessórios
- Produtos de edição limitada e exclusivos
- Sustentabilidade e qualidade artesanal como diferenciais
- Experiência de compra online com atendimento personalizado

## 2. REGRAS DE NEGÓCIO PRINCIPAIS

### 2.1 Gestão de Produtos
- **RN01**: Todos os produtos devem pertencer a uma categoria principal (women, men, accessories, limited)
- **RN02**: Produtos de edição limitada devem ter quantidade máxima definida e não podem ser reestocados
- **RN03**: Cada produto deve ter no mínimo 3 imagens em alta resolução
- **RN04**: Preços devem ser definidos com base na categoria e custo de produção
- **RN05**: Produtos sustentáveis devem ser claramente identificados com certificação

### 2.2 Gestão de Clientes
- **RN06**: Cadastro obrigatório com email válido para compras
- **RN07**: Clientes podem ter múltiplos endereços de entrega
- **RN08**: Histórico de compras deve ser mantido por 5 anos
- **RN09**: Clientes VIP têm acesso antecipado a lançamentos
- **RN10**: Preferências de estilo devem ser registradas para personalização

### 2.3 Gestão de Pedidos
- **RN11**: Pedido mínimo de $100 para frete grátis
- **RN12**: Prazo de entrega máximo de 48h para capital
- **RN13**: Devolução permitida em até 30 dias
- **RN14**: Produtos de edição limitada não trocáveis
- **RN15**: Cancelamento permitido até 2h após confirmação

### 2.4 Gestão de Estoque
- **RN16**: Estoque mínimo de 5 unidades por tamanho/cor
- **RN17**: Alerta automático quando estoque < 10 unidades
- **RN18**: Reserva de estoque por 15 minutos no carrinho
- **RN19**: Bloqueio de venda sem estoque
- **RN20**: Reabastecimento automático para produtos regulares

### 2.5 Gestão de Pagamentos
- **RN21**: Aceitar Visa, Mastercard, Amex e PayPal
- **RN22**: Parcelamento em até 12x sem juros acima de $500
- **RN23**: Antifraude obrigatório para pedidos > $1000
- **RN24**: Confirmação de pagamento em até 24h
- **RN25**: Reembolso em até 10 dias úteis

### 2.6 Sustentabilidade
- **RN26**: 30% dos produtos devem ser sustentáveis
- **RN27**: Embalagem reciclável obrigatória
- **RN28**: Compensação de carbono para entregas
- **RN29**: Fornecedores devem ter certificação ética
- **RN30**: Relatório anual de sustentabilidade

## 3. ESTRUTURA DE DADOS

### 3.1 TABELAS PRINCIPAIS

#### 3.1.1 PRODUTOS
```sql
produtos {
  id_produto: UUID PRIMARY KEY,
  nome: VARCHAR(255) NOT NULL,
  descricao: TEXT,
  categoria: ENUM('women', 'men', 'accessories', 'limited') NOT NULL,
  preco: DECIMAL(10,2) NOT NULL,
  preco_promocional: DECIMAL(10,2),
  sku: VARCHAR(100) UNIQUE NOT NULL,
  codigo_barras: VARCHAR(100),
  material: VARCHAR(255),
  pais_origem: VARCHAR(100),
  sustentavel: BOOLEAN DEFAULT FALSE,
  edicao_limitada: BOOLEAN DEFAULT FALSE,
  quantidade_limitada: INTEGER,
  data_lancamento: TIMESTAMP,
  status: ENUM('ativo', 'inativo', 'esgotado') DEFAULT 'ativo',
  peso: DECIMAL(8,2),
  dimensoes: JSON,
  created_at: TIMESTAMP DEFAULT NOW(),
  updated_at: TIMESTAMP DEFAULT NOW()
}
```

#### 3.1.2 VARIAÇÕES DE PRODUTO
```sql
produto_variacoes {
  id_variacao: UUID PRIMARY KEY,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  tamanho: VARCHAR(10),
  cor: VARCHAR(50),
  cor_hex: VARCHAR(7),
  estoque: INTEGER DEFAULT 0,
  estoque_minimo: INTEGER DEFAULT 5,
  sku_variacao: VARCHAR(100) UNIQUE,
  preco_adicional: DECIMAL(8,2) DEFAULT 0,
  imagem_destaque: VARCHAR(500),
  status: ENUM('disponivel', 'esgotado', 'em_producao') DEFAULT 'disponivel'
}
```

#### 3.1.3 IMAGENS DE PRODUTOS
```sql
produto_imagens {
  id_imagem: UUID PRIMARY KEY,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  url_imagem: VARCHAR(500) NOT NULL,
  alt_text: VARCHAR(255),
  ordem: INTEGER DEFAULT 0,
  principal: BOOLEAN DEFAULT FALSE,
  tipo: ENUM('principal', 'detalhe', 'lifestyle', '360') DEFAULT 'principal'
}
```

#### 3.1.4 CLIENTES
```sql
clientes {
  id_cliente: UUID PRIMARY KEY,
  email: VARCHAR(255) UNIQUE NOT NULL,
  senha_hash: VARCHAR(255) NOT NULL,
  nome: VARCHAR(255) NOT NULL,
  sobrenome: VARCHAR(255) NOT NULL,
  cpf: VARCHAR(14) UNIQUE,
  telefone: VARCHAR(20),
  data_nascimento: DATE,
  genero: ENUM('M', 'F', 'O', 'N'),
  tipo_cliente: ENUM('regular', 'vip', 'premium') DEFAULT 'regular',
  status: ENUM('ativo', 'inativo', 'suspenso') DEFAULT 'ativo',
  email_verificado: BOOLEAN DEFAULT FALSE,
  data_cadastro: TIMESTAMP DEFAULT NOW(),
  ultima_compra: TIMESTAMP,
  total_compras: DECIMAL(12,2) DEFAULT 0,
  preferencias: JSON,
  observacoes: TEXT
}
```

#### 3.1.5 ENDEREÇOS
```sql
enderecos {
  id_endereco: UUID PRIMARY KEY,
  id_cliente: UUID FOREIGN KEY REFERENCES clientes,
  apelido: VARCHAR(100),
  tipo: ENUM('residencial', 'comercial', 'cobranca', 'entrega') DEFAULT 'residencial',
  logradouro: VARCHAR(255) NOT NULL,
  numero: VARCHAR(20) NOT NULL,
  complemento: VARCHAR(100),
  bairro: VARCHAR(100) NOT NULL,
  cidade: VARCHAR(100) NOT NULL,
  estado: VARCHAR(50) NOT NULL,
  cep: VARCHAR(10) NOT NULL,
  pais: VARCHAR(50) DEFAULT 'Brasil',
  principal: BOOLEAN DEFAULT FALSE,
  created_at: TIMESTAMP DEFAULT NOW()
}
```

#### 3.1.6 PEDIDOS
```sql
pedidos {
  id_pedido: UUID PRIMARY KEY,
  id_cliente: UUID FOREIGN KEY REFERENCES clientes,
  id_endereco: UUID FOREIGN KEY REFERENCES enderecos,
  numero_pedido: VARCHAR(20) UNIQUE NOT NULL,
  status: ENUM('pendente', 'confirmado', 'processando', 'enviado', 'entregue', 'cancelado', 'devolvido') DEFAULT 'pendente',
  subtotal: DECIMAL(10,2) NOT NULL,
  frete: DECIMAL(8,2) NOT NULL,
  desconto: DECIMAL(8,2) DEFAULT 0,
  total: DECIMAL(10,2) NOT NULL,
  forma_pagamento: ENUM('cartao_credito', 'cartao_debito', 'paypal', 'boleto', 'pix'),
  parcelas: INTEGER DEFAULT 1,
  valor_parcela: DECIMAL(8,2),
  data_pedido: TIMESTAMP DEFAULT NOW(),
  data_confirmacao: TIMESTAMP,
  data_envio: TIMESTAMP,
  data_entrega: TIMESTAMP,
  codigo_rastreamento: VARCHAR(100),
  transportadora: VARCHAR(100),
  prazo_entrega_dias: INTEGER,
  observacoes: TEXT,
  motivo_cancelamento: TEXT,
  cupom_desconto: VARCHAR(50),
  ip_compra: VARCHAR(45),
  user_agent: VARCHAR(500)
}
```

#### 3.1.7 ITENS DO PEDIDO
```sql
pedido_itens {
  id_item: UUID PRIMARY KEY,
  id_pedido: UUID FOREIGN KEY REFERENCES pedidos,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  quantidade: INTEGER NOT NULL,
  preco_unitario: DECIMAL(10,2) NOT NULL,
  preco_total: DECIMAL(10,2) NOT NULL,
  desconto_item: DECIMAL(8,2) DEFAULT 0,
  nome_produto: VARCHAR(255) NOT NULL,
  sku: VARCHAR(100) NOT NULL,
  tamanho: VARCHAR(10),
  cor: VARCHAR(50),
  imagem_url: VARCHAR(500)
}
```

#### 3.1.8 CESTA DE COMPRAS
```sql
carrinho {
  id_carrinho: UUID PRIMARY KEY,
  id_cliente: UUID FOREIGN KEY REFERENCES clientes,
  id_sessao: VARCHAR(255),
  criado_em: TIMESTAMP DEFAULT NOW(),
  atualizado_em: TIMESTAMP DEFAULT NOW(),
  expira_em: TIMESTAMP,
  status: ENUM('ativo', 'abandonado', 'convertido') DEFAULT 'ativo'
}
```

carrinho_itens {
  id_item: UUID PRIMARY KEY,
  id_carrinho: UUID FOREIGN KEY REFERENCES carrinho,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  quantidade: INTEGER NOT NULL,
  preco_unitario: DECIMAL(10,2) NOT NULL,
  preco_total: DECIMAL(10,2) NOT NULL,
  adicionado_em: TIMESTAMP DEFAULT NOW()
}
```

#### 3.1.9 PAGAMENTOS
```sql
pagamentos {
  id_pagamento: UUID PRIMARY KEY,
  id_pedido: UUID FOREIGN KEY REFERENCES pedidos,
  tipo_pagamento: ENUM('cartao_credito', 'cartao_debito', 'paypal', 'boleto', 'pix') NOT NULL,
  status: ENUM('pendente', 'processando', 'aprovado', 'negado', 'estornado', 'cancelado') DEFAULT 'pendente',
  valor: DECIMAL(10,2) NOT NULL,
  parcelas: INTEGER DEFAULT 1,
  gateway_pagamento: VARCHAR(50),
  transaction_id: VARCHAR(255),
  nsu: VARCHAR(100),
  autorizacao: VARCHAR(100),
  codigo_antifraude: VARCHAR(100),
  score_antifraude: DECIMAL(3,2),
  motivo_negativa: TEXT,
  data_pagamento: TIMESTAMP,
  data_confirmacao: TIMESTAMP,
  data_estorno: TIMESTAMP,
  dados_cartao: JSON,
  dados_paypal: JSON,
  dados_pix: JSON
}
```

#### 3.1.10 AVALIAÇÕES DE PRODUTOS
```sql
avaliacoes {
  id_avaliacao: UUID PRIMARY KEY,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_cliente: UUID FOREIGN KEY REFERENCES clientes,
  id_pedido: UUID FOREIGN KEY REFERENCES pedidos,
  nota: INTEGER CHECK (nota >= 1 AND nota <= 5),
  titulo: VARCHAR(255),
  comentario: TEXT,
  recomenda: BOOLEAN,
  aprovado: BOOLEAN DEFAULT FALSE,
  data_avaliacao: TIMESTAMP DEFAULT NOW(),
  util_para: INTEGER DEFAULT 0,
  nao_util_para: INTEGER DEFAULT 0,
  resposta_loja: TEXT,
  data_resposta: TIMESTAMP
}
```

#### 3.1.11 CUPONS DE DESCONTO
```sql
cupons {
  id_cupom: UUID PRIMARY KEY,
  codigo: VARCHAR(50) UNIQUE NOT NULL,
  tipo_desconto: ENUM('percentual', 'fixo', 'frete_gratis') NOT NULL,
  valor_desconto: DECIMAL(8,2) NOT NULL,
  valor_minimo: DECIMAL(10,2) DEFAULT 0,
  valor_maximo_desconto: DECIMAL(10,2),
  quantidade_total: INTEGER,
  quantidade_usada: INTEGER DEFAULT 0,
  validade_inicio: TIMESTAMP,
  validade_fim: TIMESTAMP,
  ativo: BOOLEAN DEFAULT TRUE,
  unico_por_cliente: BOOLEAN DEFAULT FALSE,
  novo_cliente: BOOLEAN DEFAULT FALSE,
  categoria_aplicavel: ENUM('all', 'women', 'men', 'accessories', 'limited'),
  produtos_aplicaveis: JSON,
  created_at: TIMESTAMP DEFAULT NOW()
}
```

#### 3.1.12 LISTA DE DESEJOS
```sql
lista_desejos {
  id_item: UUID PRIMARY KEY,
  id_cliente: UUID FOREIGN KEY REFERENCES clientes,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  adicionado_em: TIMESTAMP DEFAULT NOW(),
  notificacao_disponivel: BOOLEAN DEFAULT TRUE
}
```

#### 3.1.13 HISTÓRICO DE PREÇOS
```sql
historico_precos {
  id_historico: UUID PRIMARY KEY,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  preco_anterior: DECIMAL(10,2) NOT NULL,
  preco_novo: DECIMAL(10,2) NOT NULL,
  motivo_alteracao: ENUM('promocao', 'ajuste_custo', 'campanha', 'reajuste') NOT NULL,
  data_alteracao: TIMESTAMP DEFAULT NOW(),
  id_admin: UUID,
  cupom_aplicavel: VARCHAR(50)
}
```

#### 3.1.14 FORNECEDORES
```sql
fornecedores {
  id_fornecedor: UUID PRIMARY KEY,
  nome: VARCHAR(255) NOT NULL,
  cnpj: VARCHAR(18) UNIQUE,
  email: VARCHAR(255),
  telefone: VARCHAR(20),
  endereco: TEXT,
  pais: VARCHAR(50),
  certificacao_etica: BOOLEAN DEFAULT FALSE,
  certificacoes: JSON,
  prazo_entrega: INTEGER,
  moeda: VARCHAR(3) DEFAULT 'BRL',
  status: ENUM('ativo', 'inativo') DEFAULT 'ativo',
  observacoes: TEXT,
  created_at: TIMESTAMP DEFAULT NOW()
}
```

#### 3.1.15 ESTOQUE MOVIMENTAÇÃO
```sql
estoque_movimento {
  id_movimento: UUID PRIMARY KEY,
  id_produto: UUID FOREIGN KEY REFERENCES produtos,
  id_variacao: UUID FOREIGN KEY REFERENCES produto_variacoes,
  tipo_movimento: ENUM('entrada', 'saida', 'ajuste', 'devolucao', 'perda') NOT NULL,
  quantidade: INTEGER NOT NULL,
  quantidade_anterior: INTEGER NOT NULL,
  quantidade_nova: INTEGER NOT NULL,
  motivo: VARCHAR(255),
  id_pedido: UUID FOREIGN KEY REFERENCES pedidos,
  id_fornecedor: UUID FOREIGN KEY REFERENCES fornecedores,
  custo_unitario: DECIMAL(10,2),
  custo_total: DECIMAL(12,2),
  data_movimento: TIMESTAMP DEFAULT NOW(),
  id_admin: UUID
}
```

## 4. RELACIONAMENTOS ENTRE TABELAS

### 4.1 Relacionamentos Principais

1. **clientes → enderecos** (1:N)
   - Um cliente pode ter múltiplos endereços
   - Cada endereço pertence a um único cliente

2. **clientes → pedidos** (1:N)
   - Um cliente pode fazer múltiplos pedidos
   - Cada pedido pertence a um único cliente

3. **pedidos → pedido_itens** (1:N)
   - Um pedido pode conter múltiplos itens
   - Cada item pertence a um único pedido

4. **produtos → produto_variacoes** (1:N)
   - Um produto pode ter múltiplas variações (tamanho, cor)
   - Cada variação pertence a um único produto

5. **produto_variacoes → estoque_movimento** (1:N)
   - Uma variação pode ter múltiplos movimentos de estoque
   - Cada movimento está relacionado a uma variação

6. **produtos → produto_imagens** (1:N)
   - Um produto pode ter múltiplas imagens
   - Cada imagem pertence a um único produto

7. **clientes → avaliacoes** (1:N)
   - Um cliente pode fazer múltiplas avaliações
   - Cada avaliação é feita por um único cliente

8. **produtos → avaliacoes** (1:N)
   - Um produto pode receber múltiplas avaliações
   - Cada avaliação é para um único produto

9. **clientes → lista_desejos** (1:N)
   - Um cliente pode ter múltiplos itens na lista de desejos
   - Cada item na lista pertence a um único cliente

10. **fornecedores → estoque_movimento** (1:N)
    - Um fornecedor pode ter múltiplos movimentos de estoque
    - Cada movimento de entrada pode estar relacionado a um fornecedor

## 5. ÍNDICES RECOMENDADOS

```sql
-- Performance indexes
CREATE INDEX idx_produtos_categoria ON produtos(categoria);
CREATE INDEX idx_produtos_status ON produtos(status);
CREATE INDEX idx_produtos_preco ON produtos(preco);
CREATE INDEX idx_produtos_sku ON produtos(sku);

CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_status ON clientes(status);
CREATE INDEX idx_clientes_tipo ON clientes(tipo_cliente);

CREATE INDEX idx_pedidos_cliente ON pedidos(id_cliente);
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_pedidos_numero ON pedidos(numero_pedido);

CREATE INDEX idx_pedido_itens_pedido ON pedido_itens(id_pedido);
CREATE INDEX idx_pedido_itens_produto ON pedido_itens(id_produto);

CREATE INDEX idx_produto_variacoes_produto ON produto_variacoes(id_produto);
CREATE INDEX idx_produto_variacoes_sku ON produto_variacoes(sku_variacao);

CREATE INDEX idx_estoque_movimento_produto ON estoque_movimento(id_produto);
CREATE INDEX idx_estoque_movimento_data ON estoque_movimento(data_movimento);

CREATE INDEX idx_avaliacoes_produto ON avaliacoes(id_produto);
CREATE INDEX idx_avaliacoes_cliente ON avaliacoes(id_cliente);
CREATE INDEX idx_avaliacoes_nota ON avaliacoes(nota);
```

## 6. TRIGGERS E VALIDAÇÕES

### 6.1 Triggers de Auditoria
- Atualização automática de `updated_at`
- Registro de movimentação de estoque
- Cálculo automático de totais em pedidos
- Atualização de estoque ao confirmar pedido

### 6.2 Validações de Integridade
- Estoque não pode ser negativo
- Preços devem ser positivos
- CPF e CNPJ devem ser válidos
- Emails devem ter formato válido
- Quantidades devem ser positivas

## 7. CONSIDERAÇÕES DE SEGURANÇA

- Dados de cartão de crédito não devem ser armazenados
- Senhas devem ser hasheadas com bcrypt
- Acesso restrito a dados sensíveis de clientes
- Logs de auditoria para ações críticas
- Cópias de segurança regulares dos dados

## 8. ESCALABILIDADE

- Particionamento de tabelas grandes (pedidos, estoque_movimento)
- Arquivamento de dados antigos
- Índices para consultas frequentes
- Cache para produtos e categorias populares