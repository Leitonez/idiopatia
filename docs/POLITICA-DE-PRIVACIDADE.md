# Política de Privacidade do aplicativo Idiopatia

Última atualização: 14 de setembro de 2026.

## Resumo

O Idiopatia **não coleta, não armazena em servidores, não compartilha e não
vende nenhum dado**. Todas as informações que você registra ficam apenas no
seu aparelho.

## Quais dados o app trata

O app permite que você registre, por sua própria iniciativa:

- dados de pacientes: nome, data de nascimento, sexo e a condição idiopática
  acompanhada;
- ocorrências (crises): data e hora de início e término, intensidade, gatilhos
  suspeitos e observações;
- usos de medicamentos: data e hora, medicamento, dose e observações.

Esses são dados de saúde e, por isso, sensíveis. Eles são gravados em um banco
de dados local (SQLite) dentro da área privada do aplicativo no seu aparelho.

## O que o app não faz

- Não exige conta, cadastro ou login.
- Não se conecta à internet. O app não solicita a permissão de acesso à rede.
- Não usa serviços de análise de uso (analytics), publicidade ou relatório de
  falhas de terceiros.
- Não sincroniza dados com nuvem.
- Não envia dados a desenvolvedores, parceiros ou qualquer outra parte.

## Exportação e importação

Você pode gerar arquivos (backup em JSON, relatório em PDF e planilha em CSV)
a partir dos seus dados. Esses arquivos são criados no aparelho e entregues à
folha de compartilhamento do sistema operacional. **A partir daí, o destino é
escolhido por você** (salvar em pasta, enviar por e-mail, mensagem, etc.) e
passa a ser regido pela política do serviço que você escolher. O app não
participa desse envio.

## Proteção de acesso

Opcionalmente, você pode proteger o app com PIN ou biometria. O PIN é guardado
apenas como um resumo criptográfico (hash com sal) no armazenamento seguro do
sistema. A biometria é verificada pelo próprio sistema operacional; o app não
tem acesso aos dados biométricos.

## Permissões

- **Biometria** (Android: `USE_BIOMETRIC`; iOS: Face ID / Touch ID), usada
  apenas se você ativar a proteção por biometria.
- Acesso a arquivos ocorre somente por meio do seletor e da folha de
  compartilhamento do sistema, no momento em que você exporta ou importa.

## Exclusão dos dados

Você pode apagar dados a qualquer momento dentro do app, inclusive todos de uma
vez em Configurações. Desinstalar o app também remove todos os dados. Como não
há cópia em servidor, a exclusão é definitiva.

## Crianças

O app pode ser usado por pais e cuidadores para registrar dados de crianças.
Esses dados permanecem sob controle exclusivo de quem usa o aparelho.

## Alterações

Esta política pode ser atualizada. A versão vigente estará sempre disponível
neste repositório. Mudanças não alterarão o princípio central: nenhum dado sai
do seu aparelho por iniciativa do app.

## Contato

Dúvidas podem ser enviadas pelo repositório do projeto no GitHub.
