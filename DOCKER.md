# NOIR Fashion Template - Docker Deployment Guide

## Quick Start

### Build and Run with Docker Compose (Recomendado)

```bash
# Build the image
docker-compose build

# Run the container
docker-compose up -d

# View logs
docker-compose logs -f noir-fashion

# Stop the container
docker-compose down
```

Acesse a aplicação em: `http://localhost`

---

## Manual Docker Commands

### Build the Image

```bash
docker build -t noir-fashion:latest .
```

### Run the Container

```bash
docker run -d \
  --name noir-fashion \
  -p 80:80 \
  --restart unless-stopped \
  noir-fashion:latest
```

### Stop and Remove

```bash
docker stop noir-fashion
docker rm noir-fashion
```

---

## Docker Architecture

### Multi-Stage Build
- **Stage 1 (Builder):** Node 20 Alpine - prepara assets (extensível para build futuro)
- **Stage 2 (Production):** Nginx Alpine - serve arquivos estáticos

### Security Features
- ✅ Executa como usuário non-root (`nginx-user`)
- ✅ Security headers habilitados (X-Frame-Options, X-Content-Type-Options, etc)
- ✅ Gzip compression ativado
- ✅ Negação de acesso a arquivos sensíveis (`.git`, `.env`, etc)

### Performance Optimization
- ✅ HTTP/2 push preload
- ✅ Cache agressivo para assets (31536000s = 1 ano)
- ✅ Cache mínimo para HTML (sempre atualizado)
- ✅ Compressão gzip para CSS, JS, SVG, JSON
- ✅ Image AVIF otimizado

### Health Check
```bash
# Verifica se o container está saudável
wget --no-verbose --tries=1 --spider http://localhost/index.html
```
- Intervalo: 30 segundos
- Timeout: 3 segundos
- Tentativas: 3

---

## Configuração do Nginx

### Localização
```
nginx.conf - Configuração principal
```

### Recursos Implementados
1. **Gzip Compression** - Reduz tamanho de CSS, JS, SVG
2. **Cache Strategy** 
   - HTML: `max-age=0` (sempre revalidar)
   - Assets: `max-age=31536000` (cache permanente)
3. **Security Headers**
   - X-Frame-Options: SAMEORIGIN
   - X-Content-Type-Options: nosniff
   - X-XSS-Protection: 1; mode=block
4. **SPA Routing** - Fallback para index.html
5. **Error Handling** - 404 redireciona para index.html

---

## Troubleshooting

### Container não inicia
```bash
docker logs noir-fashion
```

### Verificar se porta 80 está em uso
```bash
# Windows
netstat -ano | findstr :80

# Linux/Mac
lsof -i :80
```

### Rebuildar após mudanças
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Environment Variables

Configurado em `docker-compose.yml`:
- `NODE_ENV=production`

Para adicionar mais variáveis:
```yaml
environment:
  - NODE_ENV=production
  - YOUR_VAR=value
```

---

## Monitoramento

### Ver status dos containers
```bash
docker ps
docker-compose ps
```

### Ver logs em tempo real
```bash
docker logs -f noir-fashion
docker-compose logs -f
```

### Inspecionar container
```bash
docker inspect noir-fashion
```

---

## Deployment em Production

### Com Docker Hub
```bash
# Tag da imagem
docker tag noir-fashion:latest username/noir-fashion:latest

# Push
docker push username/noir-fashion:latest

# Pull em outro servidor
docker pull username/noir-fashion:latest
```

### Com registros privados (AWS ECR, Azure ACR, etc)
Adapt the `docker-compose.yml` com a URL do seu registro.

---

## Size Optimization

### Verificar tamanho da imagem
```bash
docker images noir-fashion
```

### Usar Alpine para reduzir size
Já implementado:
- Base: `nginx:alpine` (~150MB)
- Builder: `node:20-alpine` (~200MB)

---

Última atualização: Novembro 18, 2025
