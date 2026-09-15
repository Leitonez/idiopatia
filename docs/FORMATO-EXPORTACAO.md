# Formato de exportação e importação

## Backup completo (JSON)

Arquivo `idiopatia-backup-AAAA-MM-DD.json`, UTF-8. Serve para restauração
completa no mesmo aparelho ou em outro. Todos os identificadores são UUID v4.

```json
{
  "format": "idiopatia-backup",
  "version": 1,
  "exportedAt": "2026-09-14T21:05:00",
  "exportedAtOffsetMinutes": -180,
  "app": { "name": "Idiopatia", "version": "1.0.0" },
  "patients": [
    {
      "id": "6d1f...",
      "name": "Nome do paciente",
      "birthDate": "2018-05-01",
      "sex": "male",
      "condition": "Hiperidrose craniofacial",
      "createdAt": "2026-09-01T10:00:00",
      "updatedAt": "2026-09-01T10:00:00",
      "triggers": [
        { "id": "...", "name": "Calor", "active": true,
          "createdAt": "...", "updatedAt": "..." }
      ],
      "medications": [
        { "id": "...", "name": "Nome", "defaultDose": "10 mg", "active": true,
          "createdAt": "...", "updatedAt": "..." }
      ],
      "occurrences": [
        { "id": "...",
          "startedAt": "2026-09-10T22:30:00", "startedAtOffsetMinutes": -180,
          "endedAt": "2026-09-11T10:15:00", "endedAtOffsetMinutes": -180,
          "intensity": "moderate",
          "triggerIds": ["..."],
          "notes": "",
          "createdAt": "...", "updatedAt": "..." }
      ],
      "medicationUses": [
        { "id": "...",
          "takenAt": "2026-09-10T23:00:00", "takenAtOffsetMinutes": -180,
          "medicationId": "...", "dose": "10 mg",
          "occurrenceId": "...",
          "notes": "",
          "createdAt": "...", "updatedAt": "..." }
      ]
    }
  ]
}
```

### Regras

- **Datas e horas** são gravadas como hora local do aparelho no momento do
  registro, no formato `AAAA-MM-DDTHH:MM:SS`, sem fuso. O campo
  `...OffsetMinutes` guarda o deslocamento UTC em minutos apenas como
  informação. Ao importar, a hora local é preservada tal como foi digitada.
- **Enumerações:** `sex` aceita `female`, `male`, `other`; `intensity` aceita
  `mild`, `moderate`, `intense`.
- **Gatilhos:** `triggerIds` vazio significa gatilho desconhecido.
- **Importação:** registros são identificados pelo `id`. Um registro já
  existente só é substituído se o `updatedAt` importado for posterior ao
  existente. Caso contrário, é ignorado e contado como "ignorado". Nada é
  duplicado.
- **Versão:** o app importa qualquer `version` menor ou igual à que ele
  próprio gera. Versões futuras são recusadas com mensagem clara.

## Planilha (CSV)

Arquivo `idiopatia-<paciente>-<periodo>.csv`, UTF-8 com BOM, separador `;`,
para abrir diretamente no Excel em português. Uma linha por evento, em ordem
cronológica. Colunas:

| Coluna | Crise | Medicamento |
|---|---|---|
| Tipo | "Crise" | "Medicamento" |
| Início | data e hora | data e hora do uso |
| Término | data e hora ou "Em andamento" | vazio |
| Duração | `HHh MMmin` | vazio |
| Intensidade | Leve, Moderada, Intensa | vazio |
| Gatilhos | nomes separados por vírgula ou "Desconhecido" | vazio |
| Medicamento | vazio | nome |
| Dose | vazio | dose |
| Crise relacionada | vazio | início da crise vinculada ou vazio |
| Observações | texto | texto |

Os cabeçalhos seguem o idioma do app no momento da exportação.

## Relatório para o médico (PDF)

Arquivo `idiopatia-<paciente>-<periodo>.pdf`, formato A4. Contém:

1. Dados do paciente: nome, idade, sexo e idiopatia.
2. Resumo do período: número de crises, duração média e máxima, dias desde a
   última crise, intervalo médio, distribuição por intensidade e ranking de
   gatilhos.
3. Tabela de crises e tabela de usos de medicamento.
4. Rodapé com a observação de que os dados foram registrados pelo próprio
   usuário e existem apenas no aparelho dele.
