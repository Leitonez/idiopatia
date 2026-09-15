# Idiopatia — Requisitos

Versão 1.0 do documento. Consolidado em 14 de setembro de 2026.

## 1. Visão geral

O Idiopatia é um aplicativo móvel, gratuito e sem anúncios, para o registro pessoal de manifestações
clínicas de patologias idiopáticas, isto é, sem causa médica identificada. Ele permite registrar cada
ocorrência (crise), o uso de medicamentos e, a partir desses registros, visualizar frequência, duração
e possíveis gatilhos, para levar ao médico ou terapeuta.

Foi motivado pelo caso de uma criança com hiperidrose craniofacial idiopática, com crises de cerca de
12 horas separadas por vários dias sem manifestação, mas é genérico: serve para qualquer idiopatia,
periódica ou esporádica.

### 1.1 Princípios

1. **Privacidade absoluta.** Não há conta, login, servidor, sincronização, analytics, relatório de
   falhas ou qualquer envio de dados. Todos os dados ficam no SQLite do aparelho.
2. **Simplicidade.** Deve ser usável por leigos. Registrar uma crise leva poucos toques.
3. **Dados pertencem ao usuário.** Exportação e importação por arquivo, em formato documentado, para
   que o usuário faça o que quiser com seus dados.
4. **Gratuito para sempre.** Distribuído na Apple App Store e na Google Play Store sem custo, sem
   compras internas e sem anúncios.

### 1.2 Público

- Pais e cuidadores de pacientes com idiopatias.
- Pacientes adultos que acompanham a própria condição.
- Terapeutas e profissionais de saúde que acompanham vários pacientes e precisam de um registro fiel.

## 2. Entidades e campos

Todos os registros têm um identificador único (UUID), data de criação e data de última alteração,
para permitir importação e exportação sem conflitos.

### 2.1 Paciente

| Campo | Tipo | Obrigatório | Observações |
|---|---|---|---|
| Nome | texto | sim | |
| Data de nascimento | data | sim | Usada para exibir a idade. |
| Sexo | enumeração | sim | Feminino, Masculino, Outro/Prefiro não informar. |
| Idiopatia | texto | sim | Texto livre com sugestões. Uma idiopatia por perfil. |

Um paciente com mais de uma idiopatia é representado por mais de um perfil.

### 2.2 Gatilho (catálogo por paciente)

| Campo | Tipo | Obrigatório | Observações |
|---|---|---|---|
| Nome | texto | sim | Único por paciente. Ex.: calor, exercício, estresse. |
| Ativo | booleano | sim | Gatilhos desativados não aparecem para seleção, mas seguem no histórico. |

O app oferece uma lista inicial de sugestões, mas o catálogo é do usuário. O valor "Desconhecido" é
sempre disponível e é um dado válido, esperado em idiopatias.

### 2.3 Medicamento (catálogo por paciente)

| Campo | Tipo | Obrigatório | Observações |
|---|---|---|---|
| Nome | texto | sim | Único por paciente. |
| Dose padrão | texto | não | Preenche a dose por padrão ao registrar. Ex.: "10 mg", "5 ml". |
| Ativo | booleano | sim | Mesmo comportamento do gatilho. |

### 2.4 Ocorrência (crise)

| Campo | Tipo | Obrigatório | Observações |
|---|---|---|---|
| Paciente | referência | sim | |
| Início | data e hora | sim | Padrão: agora. |
| Término | data e hora | não | Vazio significa crise em andamento. Deve ser posterior ao início. |
| Duração | derivado | — | Calculada de início e término. Nunca digitada. |
| Intensidade | enumeração | sim | Leve, Moderada, Intensa. |
| Gatilhos | lista de referências | não | Seleção múltipla no catálogo. Vazio equivale a "Desconhecido". |
| Observações | texto | não | |

### 2.5 Uso de medicamento

| Campo | Tipo | Obrigatório | Observações |
|---|---|---|---|
| Paciente | referência | sim | |
| Data e hora | data e hora | sim | Padrão: agora. |
| Medicamento | referência | sim | Do catálogo. |
| Dose | texto | sim | Preenchida com a dose padrão, editável. |
| Ocorrência | referência | não | Vínculo opcional com uma crise. Distingue uso preventivo de uso durante a crise. |
| Observações | texto | não | |

## 3. Requisitos funcionais

### RF01 — Primeiro uso
- Na primeira abertura, o app conduz à criação do primeiro paciente em uma única tela.
- Exibe, de forma breve e clara, a promessa de privacidade: os dados ficam só no aparelho.

### RF02 — Pacientes
- Criar, editar e excluir pacientes. A exclusão pede confirmação e remove todos os registros do paciente.
- Seletor de paciente sempre visível na tela inicial. O último paciente selecionado é lembrado.

### RF03 — Tela inicial
- Dois botões grandes: **Registrar crise** e **Registrar medicamento**.
- Se houver crise em andamento, um destaque com o tempo decorrido e o botão **Encerrar crise**.
- Linha do tempo dos últimos eventos (crises e medicamentos) do paciente selecionado.

### RF04 — Ocorrências
- Registrar crise com início pré-preenchido com o momento atual. Intensidade e gatilhos são
  selecionados por toque, sem digitação.
- Encerrar crise em andamento com um toque, preenchendo o término com o momento atual e permitindo
  ajuste.
- Editar e excluir ocorrências. Exclusão pede confirmação.
- O app permite mais de uma crise em andamento apenas com aviso, pois normalmente é um erro de registro.

### RF05 — Medicamentos
- Registrar uso com data e hora pré-preenchidas, medicamento do catálogo e dose pré-preenchida.
- Se houver crise em andamento, oferecer o vínculo com ela por padrão.
- Editar e excluir usos.

### RF06 — Catálogos
- Gerir gatilhos e medicamentos por paciente: criar, renomear, desativar e reativar.
- Não é possível excluir um item usado em registros; apenas desativar.
- Ao registrar, o usuário pode criar um novo item do catálogo sem sair da tela.

### RF07 — Calendário
- Visão mensal com os dias marcados conforme houve crise, com cor por intensidade.
- Toque no dia lista os eventos daquele dia.

### RF08 — Resumo
- Para um período selecionável (30 dias, 90 dias, 12 meses, tudo):
  - número de crises;
  - duração média e duração máxima;
  - dias desde a última crise e intervalo médio entre crises;
  - distribuição por intensidade;
  - ranking de gatilhos, incluindo "Desconhecido";
  - distribuição das crises por hora de início e por dia da semana;
  - usos de medicamento por medicamento.

### RF09 — Exportação e importação
- **Backup completo** em JSON, com todos os pacientes ou apenas um, para restauração no mesmo ou em
  outro aparelho. A importação detecta registros já existentes pelo UUID e não duplica.
- **Relatório para o médico** em PDF de um paciente e um período, com o resumo e a lista de eventos.
- **Planilha** em CSV dos eventos de um paciente e um período.
- Os arquivos são gerados e compartilhados pelo mecanismo padrão do sistema (salvar, enviar, etc.).
  O app não envia nada por conta própria.
- O formato do JSON será documentado em `docs/FORMATO-EXPORTACAO.md` antes da implementação.

### RF10 — Proteção de acesso
- Opção em Configurações com três estados: **Desligada** (padrão), **PIN de acesso** ou
  **Biometria**. O usuário pode alternar entre eles e desligar a qualquer momento, mediante a
  autenticação vigente.
- PIN de 4 a 6 dígitos, armazenado apenas como hash com sal no armazenamento seguro do sistema.
- Biometria usa a API nativa (Face ID, Touch ID, impressão digital, desbloqueio facial). Só é
  oferecida se o aparelho tiver biometria configurada.
- Ao ativar biometria, o app pede também um PIN de recuperação, usado quando a biometria falha ou é
  removida do aparelho.
- Sem servidor não há recuperação de PIN esquecido. A única saída é apagar todos os dados do app, e
  isso deve estar escrito de forma clara ao ativar a proteção.
- A proteção é exigida ao abrir o app e ao retornar do segundo plano após um tempo configurável
  (imediato, 1 minuto, 5 minutos).

### RF11 — Configurações
- Proteção de acesso (RF10).
- Idioma (segue o sistema por padrão).
- Exportar e importar (RF09).
- Apagar todos os dados, com dupla confirmação.
- Sobre: versão, licença, política de privacidade e lembrete de que os dados existem apenas neste
  aparelho e devem ser exportados antes de trocar de celular.

### RF12 — Lembrete de backup
- Se houver registros e nenhuma exportação nos últimos 30 dias, a tela inicial mostra um aviso
  discreto sugerindo o backup. O aviso pode ser adiado.

## 4. Requisitos não funcionais

- **Plataformas:** iOS e Android, em Flutter, com um único código.
- **Armazenamento:** SQLite local. Nenhum dado sai do aparelho por iniciativa do app.
- **Dependências:** proibidas bibliotecas que enviem dados a terceiros, incluindo analytics e
  relatório de falhas. Toda dependência deve ser revisada quanto a isso.
- **Offline:** o app funciona integralmente sem rede. Não solicita permissão de internet além do
  mínimo exigido pela plataforma.
- **Permissões:** apenas as necessárias para biometria e para salvar ou compartilhar arquivos.
- **Idiomas:** português do Brasil na primeira versão, com a estrutura de internacionalização pronta
  para inglês e espanhol.
- **Acessibilidade:** textos com tamanho responsivo ao sistema, contraste adequado, alvos de toque
  de no mínimo 48 dp, rótulos para leitores de tela.
- **Fusos horários:** datas e horas armazenadas em hora local com o deslocamento UTC, para que
  registros não mudem ao viajar.
- **Desempenho:** telas de resumo devem responder em menos de um segundo com milhares de registros.
- **Política de privacidade:** publicada em URL pública, exigida pelas lojas, afirmando que nenhum
  dado é coletado.
- **Licença:** conforme `LICENSE.md`.

## 5. Fora de escopo da primeira versão

- Sincronização em nuvem ou entre aparelhos.
- Fotos e anexos nas ocorrências.
- Notificações e lembretes de medicamento.
- Compartilhamento direto com profissionais dentro do app.
- Gráficos avançados além dos previstos em RF08.
- Versão web ou desktop.

## 6. Decisões pendentes

- Formato detalhado do JSON de exportação (RF09).
- Lista inicial de sugestões de gatilhos e de idiopatias.
- Identidade visual além do ícone: paleta e tipografia. O ícone aprovado está em `design/icon/`.

## 7. Glossário

- **Idiopatia:** condição clínica cuja causa é desconhecida.
- **Ocorrência ou crise:** um episódio de manifestação da idiopatia, com início e término.
- **Gatilho:** fator que o usuário suspeita ter desencadeado a crise.
- **Catálogo:** lista de gatilhos ou medicamentos mantida pelo usuário para cada paciente.
