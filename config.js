// ============================================================
// Configuração do sistema · Notas da Logística VCA
// Projeto Supabase: notas-logistica-vca (separado do marketing)
// Estes dois dados são públicos por natureza (ficam no site).
// A segurança vem do login e das regras do banco de dados.
// Enquanto não forem preenchidos, o site abre a tela de configuração
// (com a opção de ver uma demonstração com dados de exemplo).
// ============================================================
window.VCA_CONFIG = {
  supabaseUrl: 'COLE_AQUI_A_PROJECT_URL',
  supabaseAnonKey: 'COLE_AQUI_A_CHAVE_PUBLICA',
  leituraAutomatica: true   // false = desliga a leitura dos documentos pela IA
};
