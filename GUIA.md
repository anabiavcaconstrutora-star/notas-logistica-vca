# Notas da Logística VCA · guia de instalação

Sistema da logística para lançar notas fiscais, boletos, comprovantes, recibos, passagens e cupons, com leitura automática, dashboard, relatórios em PDF/Excel, apresentações e a **LOG** (IA que responde perguntas sobre os gastos). É separado do sistema do marketing: tem banco, logins e arquivos próprios.

**Como fica no ar:**
- **GitHub** guarda o código do site.
- **Vercel** (ou GitHub Pages) deixa o site no ar. A Vercel hospeda o site, mas não guarda dados.
- **Supabase** guarda o banco, os logins e os arquivos, e roda a função de IA.
- **Claude Platform (Anthropic)** fornece a IA usada na leitura de documentos e na LOG. O modelo padrão é o **Claude Haiku 5.5** (`claude-haiku-5-5`), o mais barato: US$ 0,10 por milhão de tokens de entrada e US$ 0,50 por milhão de saída. Uma leitura de documento sai por cerca de US$ 0,0005 e uma pergunta à LOG por cerca de US$ 0,003.

**Quer só ver antes de configurar?** Abra o site com `?demo=1` no final do endereço (ex.: `https://SEU-USUARIO.github.io/notas-logistica-vca/?demo=1`). Ele carrega dados de exemplo e nada é salvo.

---

## 0. Chave da IA na Claude Platform

1. Entre em **platform.claude.com** e crie a conta ou faça login.
2. **Settings → Billing**: adicione créditos (US$ 5 rendem muito com o Haiku 5.5).
3. **Settings → Workspaces → Create workspace**, com o nome `Logistica VCA`. Assim os gastos ficam separados do marketing.
4. Clique no workspace → **Spend limits** → defina um limite mensal (ex.: US$ 10) e um aviso por e-mail.
5. **Settings → API keys → Create key**, escolhendo o workspace `Logistica VCA`. Copie a chave `sk-ant-...` na hora, porque ela só aparece uma vez. Ela vai no passo 4.

## 1. Criar o projeto no Supabase

1. Entre em https://supabase.com e clique em **New project**.
2. Nome: `notas-logistica-vca`. Crie uma senha de banco (guarde) e escolha a região **South America (São Paulo)**.
3. Espere o projeto terminar de criar (1 a 2 minutos).

## 2. Criar as tabelas

1. No menu do projeto, abra **SQL Editor** → **New query**.
2. Abra o arquivo `supabase/01-banco.sql` desta pasta, copie tudo, cole e clique em **Run**.
3. Deve aparecer "Success. No rows returned".

Isso cria as tabelas de lançamentos, ajustes e apresentações, as regras de segurança (só quem tem login acessa), o tempo real e a pasta privada dos arquivos.

## 3. Logins da equipe

1. **Authentication → Sign In / Providers**: desligue **Allow new users to sign up** (ninguém se cadastra sozinho).
2. **Authentication → Users → Add user → Create new user**: e-mail e senha de cada pessoa, marcando **Auto Confirm User**.
3. **Authentication → URL Configuration**: em **Site URL**, coloque o endereço do site (passo 6). É para o link de "Esqueci minha senha" voltar para o lugar certo.

## 4. Leitura automática e LOG (IA)

1. **Edge Functions → Deploy a new function → Via Editor**.
2. Nome: `ler-nota` (exatamente assim).
3. Apague o exemplo, cole o conteúdo de `supabase/ler-nota.ts` e clique em **Deploy**.
   Use **este** arquivo, e não o código da função do marketing: ele também atende a LOG (modo de conversa).
4. Na função, abra **Settings** e **desligue "Verify JWT"** (o login já é conferido dentro dela).
5. **Edge Functions → Secrets → Add new secret**:
   - `ANTHROPIC_API_KEY` = a chave da Anthropic (pode ser a mesma do marketing ou uma nova, para separar os custos).
   - Opcional: `ANTHROPIC_MODEL`, para trocar o modelo. O padrão é `claude-haiku-5-5`.

A leitura aceita nota fiscal (NF-e/DANFE), nota de serviço (NFS-e), cupom fiscal, boleto, comprovante de PIX/TED/cartão, recibo, fatura, passagem aérea ou rodoviária e reserva de hotel. Ela preenche valor, fornecedor (quem recebeu), data, nº, vencimento, tipo, e já sugere a situação: boleto entra como **A pagar** e comprovante como **Pago**.

Para desligar a leitura, troque `leituraAutomatica: true` para `false` no `config.js`.

## 5. Ligar o site ao banco

1. **Project Settings → API Keys** (ou **Data API**): copie a **Project URL** e a **chave pública** (publishable / anon).
2. Abra `config.js` desta pasta e cole as duas no lugar de `COLE_AQUI_...`.

## 6. Publicar (GitHub + Vercel)

1. No GitHub, crie um repositório novo, por exemplo `notas-logistica-vca`, e envie **todos os arquivos desta pasta** (**Add file → Upload files**). A pasta `supabase` é só para consulta; se enviar, não tem problema.
2. Em **vercel.com**, entre com a conta do GitHub → **Add New → Project** → escolha o repositório → **Deploy**. Não precisa configurar nada (é um site estático). Toda vez que o GitHub for atualizado, a Vercel publica sozinha.
3. Copie o endereço gerado (ex.: `notas-logistica-vca.vercel.app`) e coloque no Supabase em **Authentication → URL Configuration → Site URL**.

*Alternativa sem Vercel:* no GitHub, **Settings → Pages → Deploy from a branch → main → /(root)**. O site fica em `https://SEU-USUARIO.github.io/notas-logistica-vca/`.

No celular, dá para "Adicionar à tela de início" que ele abre como aplicativo.

---

## Como usar

- **Notas**: arraste o documento na faixa do topo ou toque em **Lançar**. Confira os campos marcados como "lido pela IA" e salve. O número laranja no ícone de Notas mostra quantos documentos estão a pagar.
- **Eventos**: quanto cada evento custou (Feirão Caixa, Viagem Diretoria, Aeronave VCA…).
- **Dashboard**: filtros por ano, mês, evento, empreendimento e categoria.
- **Relatórios**: PDF e Excel por mês, ano, evento, empreendimento ou categoria.
- **LOG**: o botão "LOG" na barra lateral (no celular, fica no topo). Pergunte em português: "quanto gastamos com combustível em outubro?", "quais boletos vencem esta semana?", "compare este mês com o anterior". Ela consulta os lançamentos antes de responder e não inventa números.
- **Apresentações**: escolha quantas páginas (5, 10 ou 15) e um modelo (Fechamento do mês, Balanço do ano, Prestação de contas de um evento, Custos de um empreendimento ou Em branco), ajuste o período e os filtros, ligue/desligue e reordene slides, escreva comentários e clique em **▶ Apresentar** (setas do teclado para passar, Esc para sair). Também baixa em **PDF** ou **PowerPoint** (com gráficos editáveis). Os números se atualizam sozinhos conforme novos lançamentos entram.
- **Modo claro/escuro**: botão de sol/lua no topo. Fica salvo em cada aparelho.
- **Ajustes** (engrenagem): eventos, empreendimentos, categorias e orçamento mensal.

## Trocar o logo

O logo fica embutido no `index.html` (imagem em base64) e nos ícones `icon-192.png` e `icon-512.png`. Para usar um logo oficial da logística, troque os dois PNG e me peça para atualizar o embutido.
