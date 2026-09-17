# 🎫 FilaSystem — Guia de Instalação e Uso

> Guia passo a passo para rodar o sistema localmente no seu computador (Windows, Mac ou Linux).  
> Tempo estimado: **15 a 20 minutos** na primeira vez.

---

## 📌 Índice

1. [O que você vai precisar instalar](#1-o-que-você-vai-precisar-instalar)
2. [Instalando o Node.js](#2-instalando-o-nodejs)
3. [Instalando o PostgreSQL](#3-instalando-o-postgresql)
4. [Baixando o projeto](#4-baixando-o-projeto)
5. [Configurando e rodando o Back-end](#5-configurando-e-rodando-o-back-end)
6. [Configurando e rodando o Front-end](#6-configurando-e-rodando-o-front-end)
7. [Acessando o sistema no navegador](#7-acessando-o-sistema-no-navegador)
8. [Usuários e senhas para teste](#8-usuários-e-senhas-para-teste)
9. [Como testar o fluxo completo](#9-como-testar-o-fluxo-completo)
10. [Problemas comuns e soluções](#10-problemas-comuns-e-soluções)

---

## 1. O que você vai precisar instalar

Antes de começar, certifique-se de ter os três programas abaixo instalados.  
Se já tiver algum deles, pode pular direto para o próximo.

| Programa | Para que serve | Versão mínima |
|---|---|---|
| **Node.js** | Roda o back-end e o front-end | 18 ou superior |
| **PostgreSQL** | Banco de dados do sistema | 14 ou superior |
| **Git** *(opcional)* | Baixar o projeto | Qualquer |

---

## 2. Instalando o Node.js

### Windows
1. Acesse **https://nodejs.org**
2. Clique no botão verde **"LTS"** (versão recomendada)
3. Execute o instalador `.msi` baixado e clique em **Next** em todas as telas
4. Ao final, abra o **Prompt de Comando** (`Win + R` → digite `cmd` → Enter) e confirme:
   ```
   node --version
   ```
   Deve aparecer algo como `v20.x.x`. ✅

### Mac
1. Acesse **https://nodejs.org** e baixe o instalador `.pkg` LTS
2. Execute o instalador e siga as instruções
3. Abra o **Terminal** (`Cmd + Espaço` → "Terminal") e confirme:
   ```
   node --version
   ```

### Linux (Ubuntu / Debian)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
```

---

## 3. Instalando o PostgreSQL

### Windows
1. Acesse **https://www.postgresql.org/download/windows/**
2. Clique em **"Download the installer"** → escolha a versão **16** para Windows x86-64
3. Execute o instalador
4. Na tela **"Select Components"**, mantenha tudo marcado
5. Defina uma senha para o usuário `postgres` — **anote essa senha!** (sugestão: `postgres`)
6. Mantenha a porta padrão **5432**
7. Finalize a instalação
8. Após instalar, abra o **pgAdmin 4** (instalado junto) ou o **SQL Shell (psql)**

**Criando o banco de dados (Windows — via SQL Shell):**
- Abra o **SQL Shell (psql)** pelo menu Iniciar
- Pressione **Enter** em todas as perguntas até chegar no campo `Password:`
- Digite a senha que você definiu
- Quando aparecer o prompt `postgres=#`, execute:
  ```sql
  CREATE DATABASE fila_atendimento;
  ```
- Deve aparecer `CREATE DATABASE`. ✅

### Mac
```bash
# Usando Homebrew (recomendado)
brew install postgresql@16
brew services start postgresql@16

# Cria o banco
createdb fila_atendimento
```

Se não tiver o Homebrew: **https://brew.sh**

### Linux (Ubuntu / Debian)
```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres createdb fila_atendimento

# Define senha do usuário postgres
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
```

---

## 4. Baixando o projeto

### Opção A — Com Git
Abra o terminal / prompt de comando na pasta onde quer salvar e execute:
```bash
git clone https://github.com/seu-usuario/fila-atendimento.git
cd fila-atendimento
```

### Opção B — Sem Git (arquivo ZIP)
1. Baixe o arquivo `.zip` do projeto
2. Extraia em uma pasta de sua preferência (ex: `C:\Projetos\fila-atendimento`)
3. Abra o terminal nessa pasta

> **Como abrir o terminal numa pasta específica:**
> - **Windows**: Segure `Shift` e clique com o botão direito dentro da pasta → "Abrir janela do PowerShell aqui"
> - **Mac**: Arraste a pasta para o Terminal, ou clique com o botão direito → "Novo Terminal na Pasta"
> - **Linux**: Clique com o botão direito → "Abrir Terminal"

---

## 5. Configurando e rodando o Back-end

> ⚠️ Você precisará de **dois terminais abertos ao mesmo tempo** — um para o back-end e outro para o front-end.

### Passo 5.1 — Abra o terminal e entre na pasta do back-end

```bash
cd fila-atendimento/backend
```

### Passo 5.2 — Crie o arquivo de configuração

**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env
```

**Mac / Linux:**
```bash
cp .env.example .env
```

Agora abra o arquivo `.env` em qualquer editor de texto (Bloco de Notas, VS Code, etc.) e verifique se está assim:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/fila_atendimento"
JWT_SECRET="fila-secret-key-mude-em-producao"
PORT=3001
```

> ⚠️ Se você definiu uma senha diferente de `postgres` para o PostgreSQL, troque no campo `DATABASE_URL`.  
> Formato: `postgresql://USUARIO:SENHA@localhost:5432/fila_atendimento`

### Passo 5.3 — Instale as dependências

```bash
npm install
```

> Isso pode levar 1 a 3 minutos. Aguarde aparecer algo como `added 487 packages`.

### Passo 5.4 — Crie as tabelas no banco de dados

```bash
npx prisma migrate dev --name init
```

> Aguarde. Deve aparecer: `Your database is now in sync with your schema.` ✅

### Passo 5.5 — Popule o banco com dados de teste

```bash
npx ts-node prisma/seed.ts
```

> Deve aparecer a lista de usuários criados:
> ```
> ✅ Seed concluído!
> 👤 Usuários criados:
>   admin@fila.com        | senha: admin123      | ADMIN
>   gerente.sp@fila.com   | senha: gerente123    | GERENTE
>   ...
> ```

### Passo 5.6 — Inicie o servidor back-end

```bash
npm run start:dev
```

> Aguarde aparecer:
> ```
> 🚀 Backend rodando em http://localhost:3001
> ```
> **Deixe este terminal aberto.** O back-end precisa ficar rodando.

---

## 6. Configurando e rodando o Front-end

> Abra um **novo terminal** (não feche o anterior).

### Passo 6.1 — Entre na pasta do front-end

```bash
cd fila-atendimento/frontend
```

### Passo 6.2 — Instale as dependências

```bash
npm install
```

> Aguarde terminar (1 a 3 minutos).

### Passo 6.3 — Inicie o servidor front-end

```bash
npm run dev
```

> Aguarde aparecer:
> ```
>  ▲ Next.js 14.x.x
>  - Local:  http://localhost:3000
> ```
> **Deixe este terminal aberto também.**

---

## 7. Acessando o sistema no navegador

Com os dois servidores rodando, abra seu navegador (Chrome, Firefox, Edge) e acesse:

| O que acessar | Endereço |
|---|---|
| **Sistema principal** | http://localhost:3000 |
| **Painel Monitor (TV)** | Gerado automaticamente pelo gerencial |

> O navegador vai redirecionar automaticamente para a tela de **login**.

---

## 8. Usuários e senhas para teste

Clique em **"Ver credenciais de teste"** na tela de login — basta clicar em qualquer linha da tabela para preencher automaticamente o e-mail e a senha.

| E-mail | Senha | Perfil | O que pode fazer |
|---|---|---|---|
| `admin@fila.com` | `admin123` | **Admin** | Acesso total ao sistema |
| `gerente.sp@fila.com` | `gerente123` | **Gerente** | Dashboard, métricas, relatórios |
| `triagem1@fila.com` | `triagem123` | **Triagem** | Emitir senhas para os clientes |
| `atendente.caixa1@fila.com` | `atendente123` | **Atendente** | Terminal do Caixa (chamar, atender) |
| `atendente.caixa2@fila.com` | `atendente123` | **Atendente** | Terminal do Caixa (2º atendente) |
| `atendente.adm1@fila.com` | `atendente123` | **Atendente** | Terminal de Admissão |
| `atendente.sac1@fila.com` | `atendente123` | **Atendente** | Terminal do SAC |

> Cada perfil é redirecionado automaticamente para a tela correta após o login.

---

## 9. Como testar o fluxo completo

Para simular o funcionamento real do sistema, o ideal é abrir **3 abas** no navegador:

| Aba | Perfil | URL |
|---|---|---|
| Aba 1 | Triagem | http://localhost:3000/triagem |
| Aba 2 | Atendente | http://localhost:3000/terminal |
| Aba 3 | Monitor / TV | gerado pelo gerencial |

---

### 🔵 Passo 1 — Abra o Painel Monitor (TV)

1. Abra uma aba e faça login como **`gerente.sp@fila.com`** / `gerente123`
2. Você será redirecionado para o **Dashboard Gerencial**
3. Clique no botão **"📺 Abrir Painel Monitor"** no canto superior direito
4. Uma nova aba abrirá com a tela do monitor (fundo escuro) — **deixe ela visível**

---

### 🟢 Passo 2 — Emita senhas pela Triagem

1. Abra outra aba e faça login como **`triagem1@fila.com`** / `triagem123`
2. Selecione o setor **"Caixa e Pagamentos"** no campo "Setor de Destino"
3. Escolha o tipo **Normal** ou **♿ Preferencial**
4. Clique em **"🖨 Emitir Senha"**
5. Aparecerá o ticket com o código (ex: `CAI-019`)
6. Emita mais 2 ou 3 senhas — misture Normal e Preferencial

---

### 🟠 Passo 3 — Atenda no Terminal

1. Abra outra aba e faça login como **`atendente.caixa1@fila.com`** / `atendente123`
2. Você verá a **fila do setor Caixa** com as senhas emitidas
3. Observe que senhas **Preferenciais** aparecem sempre no topo da lista
4. Clique em **"📢 Chamar"** na primeira senha

---

### ✨ Passo 4 — Veja o Painel atualizar em tempo real

1. Olhe para a aba do **Monitor (TV)** aberta no Passo 1
2. A senha chamada aparecerá **instantaneamente**, sem precisar dar F5
3. O banner superior destacará o código chamado e o número da mesa

---

### 🟡 Passo 5 — Conduza o atendimento

De volta à aba do **Atendente**:

| Botão | Quando usar |
|---|---|
| **▶ Iniciar** | Quando o cliente chegar na mesa |
| **✅ Finalizar** | Quando o atendimento terminar |
| **🔁 Rechamar** | Quando o cliente não comparecer (chama novamente no painel) |
| **✕ Cancelar** | Para remover a senha da fila (desistência) |

---

### 📊 Passo 6 — Veja os relatórios

1. Volte para a aba do **Gerente** (ou faça login como `gerente.sp@fila.com`)
2. O **Dashboard** mostra em tempo real: senhas aguardando, em atendimento, finalizadas
3. Clique nas abas:
   - **"🏢 Por Setor"** — TMA e volume por setor
   - **"👥 Por Atendente"** — desempenho individual
   - **"📋 Histórico"** — filtre por período e veja todos os atendimentos

---

## 10. Problemas comuns e soluções

### ❌ `ECONNREFUSED` ou "Não foi possível conectar ao banco"

**Causa:** O PostgreSQL não está rodando ou a senha está errada.

**Solução:**
- Verifique se o serviço PostgreSQL está ativo:
  - **Windows:** `Win + R` → `services.msc` → procure "postgresql" → clique em "Iniciar"
  - **Mac:** `brew services start postgresql@16`
  - **Linux:** `sudo systemctl start postgresql`
- Confirme a senha no arquivo `backend/.env`

---

### ❌ `port 3001 already in use` ou `port 3000 already in use`

**Causa:** Outra aplicação já está usando a porta.

**Solução:**

**Windows:**
```powershell
# Ver qual processo usa a porta 3001
netstat -ano | findstr :3001
# Anote o PID (último número) e encerre:
taskkill /PID <número> /F
```

**Mac / Linux:**
```bash
kill -9 $(lsof -ti:3001)
kill -9 $(lsof -ti:3000)
```

---

### ❌ `prisma: command not found` ou `ts-node: command not found`

**Causa:** As dependências não foram instaladas corretamente.

**Solução:**
```bash
# Certifique-se de estar na pasta backend/
cd fila-atendimento/backend
npm install
```

---

### ❌ O painel TV não atualiza ao chamar uma senha

**Causa:** O WebSocket não conectou (comum quando o back-end reinicia).

**Solução:**
1. Feche a aba do painel
2. Reabra clicando em **"📺 Abrir Painel Monitor"** no gerencial
3. Confirme que o back-end ainda está rodando no terminal

---

### ❌ Tela em branco ou erro 404 ao acessar `localhost:3000`

**Causa:** O front-end ainda está compilando (pode levar até 30 segundos na primeira vez).

**Solução:** Aguarde até aparecer `✓ Ready` no terminal do front-end, depois recarregue a página.

---

### ❌ `Cannot find module '@prisma/client'`

**Causa:** O Prisma Client não foi gerado após o `migrate`.

**Solução:**
```bash
cd fila-atendimento/backend
npx prisma generate
npm run start:dev
```

---

## 🔁 Para parar e reiniciar o sistema

Para **parar**: pressione `Ctrl + C` em cada terminal (back-end e front-end).

Para **reiniciar** (sem precisar refazer tudo):

```bash
# Terminal 1 — Back-end
cd fila-atendimento/backend
npm run start:dev

# Terminal 2 — Front-end
cd fila-atendimento/frontend
npm run dev
```

> Os dados do banco são **persistidos** — você não perde nada ao reiniciar.

---

## 🗑 Para resetar o banco e começar do zero

```bash
cd fila-atendimento/backend

# Apaga tudo e recria
npx prisma migrate reset

# Repopula com dados fake
npx ts-node prisma/seed.ts
```

---

## 📞 Resumo rápido dos endereços

| Serviço | Endereço |
|---|---|
| Sistema (navegador) | http://localhost:3000 |
| API (back-end) | http://localhost:3001/api |
| Banco de dados | localhost:5432 |

---

*Dúvidas ou erros não listados aqui? Abra uma issue no repositório do projeto.*
