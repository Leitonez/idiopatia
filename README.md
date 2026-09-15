# Idiopatia

Aplicativo móvel, gratuito e sem anúncios, para o registro pessoal de
manifestações clínicas, periódicas ou esporádicas, em pacientes com patologias
idiopáticas. Permite registrar crises, gatilhos e medicamentos, e visualizar
frequência e padrões para levar ao médico.

**Privacidade:** não há conta, servidor, sincronização ou coleta de dados. Tudo
fica no SQLite do aparelho. Os dados podem ser exportados e importados por
arquivo, sob controle do usuário.

## Documentação

- [Requisitos](docs/REQUISITOS.md)
- [Formato de exportação e importação](docs/FORMATO-EXPORTACAO.md)
- [Política de privacidade](docs/POLITICA-DE-PRIVACIDADE.md)
- Ícone do app: [design/icon](design/icon)

## Desenvolvimento

Flutter 3.32 ou superior, com Android SDK 36 e NDK 27 (ver
`android/app/build.gradle.kts`).

```bash
flutter pub get
flutter gen-l10n
flutter test
flutter run
```

Textos da interface ficam em `lib/l10n/app_pt.arb` (modelo) e `app_en.arb`.
Após alterar, rode `flutter gen-l10n`.

Para gerar capturas de tela em `design/screenshots` (sem emulador):

```bash
flutter test --tags screenshots --run-skipped --update-goldens
```

Para regenerar os ícones de launcher a partir de `design/icon/icon.png`:

```bash
dart run flutter_launcher_icons
```

### Estrutura

| Pasta | Conteúdo |
|---|---|
| `lib/data` | modelos, esquema SQLite e repositório |
| `lib/services` | estatísticas, backup JSON, CSV, PDF, preferências e segurança |
| `lib/state` | provedores Riverpod |
| `lib/features` | telas por funcionalidade |
| `lib/widgets` | widgets e formatação compartilhados |
| `test` | testes unitários e de fluxo |

### Dependências e privacidade

Nenhuma dependência envia dados a terceiros. Não há analytics nem relatório de
falhas. O app não solicita permissão de internet. Toda dependência nova deve
ser revisada quanto a isso.

## Licença

Este projeto está protegido por direitos de autor. Consulte o ficheiro
[LICENSE.md](LICENSE.md) para conhecer os termos de utilização, que proíbem a
modificação e a venda do código.
