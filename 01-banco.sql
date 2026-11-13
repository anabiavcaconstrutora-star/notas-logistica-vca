-- ============================================================
-- Notas da Logística VCA · estrutura do banco (Supabase)
-- Cole tudo no SQL Editor do projeto novo e clique em "Run".
-- Pode rodar de novo sem problema: nada é apagado.
-- ============================================================

-- 1) Lançamentos (notas, boletos, comprovantes…)
create table if not exists public.notas (
  id               text primary key,
  valor            numeric(14,2) not null default 0,
  data_emissao     date,
  mes_ref          text not null,                 -- AAAA-MM: mês em que a despesa entra
  fornecedor       text default '',
  empreendimento   text default '',
  categoria        text default '',
  evento           text default '',
  numero           text default '',
  cnpj             text default '',
  descricao        text default '',
  tipo_doc         text default '',               -- Nota fiscal, Boleto, Comprovante…
  vencimento       date,
  status           text not null default 'pago' check (status in ('pago','a_pagar')),
  arquivo          jsonb,                         -- referência do arquivo guardado
  origem           text default 'manual',         -- manual | ia
  criado_em        timestamptz default now(),
  atualizado_em    timestamptz default now(),
  criado_por_email text default ''
);
-- se a tabela já existia sem as colunas novas
alter table public.notas add column if not exists tipo_doc text default '';
alter table public.notas add column if not exists vencimento date;
create index if not exists notas_mes_ref_idx on public.notas (mes_ref);

-- 2) Ajustes da equipe (eventos, empreendimentos, categorias, orçamento)
create table if not exists public.config (
  id            text primary key,
  dados         jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz default now()
);

-- 3) Apresentações montadas na aba "Apresentações"
create table if not exists public.apresentacoes (
  id               text primary key,
  titulo           text,
  dados            jsonb not null default '{}'::jsonb,
  criado_por_email text,
  criado_em        timestamptz default now(),
  atualizado_em    timestamptz default now()
);

-- 4) Segurança: só quem entrou com login (equipe) lê e grava
alter table public.notas          enable row level security;
alter table public.config         enable row level security;
alter table public.apresentacoes  enable row level security;

do $$
declare t text;
begin
  foreach t in array array['notas','config','apresentacoes'] loop
    execute format('drop policy if exists "equipe_ler" on public.%I', t);
    execute format('drop policy if exists "equipe_gravar" on public.%I', t);
    execute format('create policy "equipe_ler" on public.%I for select to authenticated using (true)', t);
    execute format('create policy "equipe_gravar" on public.%I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- 5) Atualização em tempo real (o que um lança aparece na hora para os outros)
do $$
begin
  begin alter publication supabase_realtime add table public.notas;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.config; exception when duplicate_object then null; end;
end $$;

-- 6) Pasta privada para os arquivos (fotos e PDFs), até 20 MB cada
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('notas', 'notas', false, 20971520, array['application/pdf','image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do nothing;

drop policy if exists "equipe_arquivos_ler"     on storage.objects;
drop policy if exists "equipe_arquivos_enviar"  on storage.objects;
drop policy if exists "equipe_arquivos_trocar"  on storage.objects;
drop policy if exists "equipe_arquivos_apagar"  on storage.objects;
create policy "equipe_arquivos_ler"    on storage.objects for select to authenticated using (bucket_id = 'notas');
create policy "equipe_arquivos_enviar" on storage.objects for insert to authenticated with check (bucket_id = 'notas');
create policy "equipe_arquivos_trocar" on storage.objects for update to authenticated using (bucket_id = 'notas');
create policy "equipe_arquivos_apagar" on storage.objects for delete to authenticated using (bucket_id = 'notas');
