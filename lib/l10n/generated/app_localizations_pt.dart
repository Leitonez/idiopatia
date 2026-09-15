// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Idiopatia';

  @override
  String get privacyPromise =>
      'Seus dados ficam apenas neste aparelho. Nada é enviado a servidores ou a terceiros.';

  @override
  String get onboardingTitle => 'Bem-vindo';

  @override
  String get onboardingSubtitle =>
      'Vamos começar cadastrando o primeiro paciente. Pode ser você ou alguém de quem você cuida.';

  @override
  String get patient => 'Paciente';

  @override
  String get patients => 'Pacientes';

  @override
  String get newPatient => 'Novo paciente';

  @override
  String get editPatient => 'Editar paciente';

  @override
  String get managePatients => 'Gerenciar pacientes';

  @override
  String get selectPatient => 'Selecionar paciente';

  @override
  String get name => 'Nome';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get sex => 'Sexo';

  @override
  String get sexFemale => 'Feminino';

  @override
  String get sexMale => 'Masculino';

  @override
  String get sexOther => 'Outro / prefiro não informar';

  @override
  String get condition => 'Idiopatia';

  @override
  String get conditionHint => 'Ex.: hiperidrose craniofacial';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
      zero: 'menos de 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Fechar';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmar';

  @override
  String get add => 'Adicionar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get later => 'Depois';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get deletePatientTitle => 'Excluir paciente?';

  @override
  String deletePatientMessage(String name) {
    return 'Todos os registros de $name serão apagados. Esta ação não pode ser desfeita.';
  }

  @override
  String get home => 'Início';

  @override
  String get calendar => 'Calendário';

  @override
  String get summary => 'Resumo';

  @override
  String get settings => 'Configurações';

  @override
  String get registerCrisis => 'Registrar crise';

  @override
  String get registerMedication => 'Registrar medicamento';

  @override
  String get ongoingCrisis => 'Crise em andamento';

  @override
  String startedAgo(String duration) {
    return 'Início há $duration';
  }

  @override
  String get endCrisis => 'Encerrar crise';

  @override
  String get recentEvents => 'Últimos eventos';

  @override
  String get noEvents =>
      'Nenhum registro ainda. Toque em \"Registrar crise\" quando houver uma manifestação.';

  @override
  String get crisis => 'Crise';

  @override
  String get crises => 'Crises';

  @override
  String get medicationUse => 'Medicamento';

  @override
  String get start => 'Início';

  @override
  String get end => 'Término';

  @override
  String get ongoing => 'Em andamento';

  @override
  String get duration => 'Duração';

  @override
  String get intensity => 'Intensidade';

  @override
  String get intensityMild => 'Leve';

  @override
  String get intensityModerate => 'Moderada';

  @override
  String get intensityIntense => 'Intensa';

  @override
  String get triggers => 'Gatilhos';

  @override
  String get unknownTrigger => 'Desconhecido';

  @override
  String get newTrigger => 'Novo gatilho';

  @override
  String get notes => 'Observações';

  @override
  String get setEnd => 'Informar término';

  @override
  String get endMustBeAfterStart => 'O término deve ser posterior ao início.';

  @override
  String get anotherOngoingTitle => 'Já existe uma crise em andamento';

  @override
  String get anotherOngoingMessage =>
      'Normalmente isso indica que a crise anterior não foi encerrada. Deseja registrar outra mesmo assim?';

  @override
  String get registerAnyway => 'Registrar mesmo assim';

  @override
  String get newCrisis => 'Nova crise';

  @override
  String get editCrisis => 'Editar crise';

  @override
  String get deleteCrisisTitle => 'Excluir crise?';

  @override
  String get deleteConfirmGeneric => 'Esta ação não pode ser desfeita.';

  @override
  String get medication => 'Medicamento';

  @override
  String get medications => 'Medicamentos';

  @override
  String get newMedication => 'Novo medicamento';

  @override
  String get dose => 'Dose';

  @override
  String get defaultDose => 'Dose padrão';

  @override
  String get doseHint => 'Ex.: 10 mg, 5 ml, 1 comprimido';

  @override
  String get linkedCrisis => 'Crise relacionada';

  @override
  String get noLinkedCrisis => 'Nenhuma (uso preventivo)';

  @override
  String crisisStartedAt(String dateTime) {
    return 'Crise de $dateTime';
  }

  @override
  String get dateTime => 'Data e hora';

  @override
  String get date => 'Data';

  @override
  String get time => 'Hora';

  @override
  String get editMedicationUse => 'Editar medicamento';

  @override
  String get deleteMedicationUseTitle => 'Excluir registro?';

  @override
  String get selectMedication => 'Selecione o medicamento';

  @override
  String get catalogs => 'Listas';

  @override
  String get catalogsSubtitle => 'Gatilhos e medicamentos do paciente';

  @override
  String get manageTriggers => 'Gatilhos';

  @override
  String get manageMedications => 'Medicamentos';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get rename => 'Renomear';

  @override
  String get deactivate => 'Desativar';

  @override
  String get reactivate => 'Reativar';

  @override
  String get nameAlreadyExists => 'Já existe um item com esse nome.';

  @override
  String get noCatalogItems => 'Nenhum item. Toque em + para adicionar.';

  @override
  String get cannotDeleteUsedItem =>
      'Este item já foi usado em registros e não pode ser excluído. Você pode desativá-lo.';

  @override
  String get inactiveItemsHint =>
      'Itens desativados não aparecem ao registrar, mas continuam no histórico.';

  @override
  String get today => 'Hoje';

  @override
  String get noEventsOnDay => 'Nenhum evento neste dia.';

  @override
  String get period => 'Período';

  @override
  String get last30Days => '30 dias';

  @override
  String get last90Days => '90 dias';

  @override
  String get last12Months => '12 meses';

  @override
  String get allTime => 'Tudo';

  @override
  String get crisesCount => 'Crises';

  @override
  String get averageDuration => 'Duração média';

  @override
  String get maxDuration => 'Duração máxima';

  @override
  String get daysSinceLast => 'Dias desde a última';

  @override
  String get averageInterval => 'Intervalo médio';

  @override
  String get byIntensity => 'Por intensidade';

  @override
  String get triggerRanking => 'Gatilhos mais frequentes';

  @override
  String get byHourOfDay => 'Por hora de início';

  @override
  String get byWeekday => 'Por dia da semana';

  @override
  String get medicationUses => 'Usos de medicamento';

  @override
  String get noDataPeriod => 'Sem registros no período.';

  @override
  String ongoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count em andamento',
      one: '1 em andamento',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get security => 'Proteção de acesso';

  @override
  String get securitySubtitle => 'PIN ou biometria ao abrir o app';

  @override
  String get securityOff => 'Desligada';

  @override
  String get securityPin => 'PIN de acesso';

  @override
  String get securityBiometric => 'Biometria';

  @override
  String get securityExplanation =>
      'Protege os registros de quem pegar o aparelho. Você pode desligar a qualquer momento.';

  @override
  String get setPin => 'Definir PIN';

  @override
  String get newPin => 'Novo PIN';

  @override
  String get confirmPin => 'Confirme o PIN';

  @override
  String get pinMismatch => 'Os PINs não coincidem.';

  @override
  String get pinLength => 'O PIN deve ter de 4 a 6 dígitos.';

  @override
  String get enterPin => 'Digite o PIN';

  @override
  String get wrongPin => 'PIN incorreto.';

  @override
  String get recoveryPinInfo =>
      'A biometria pode falhar ou ser removida do aparelho. Defina também um PIN de recuperação.';

  @override
  String get forgotPinWarning =>
      'Atenção: não há servidor nem conta. Se você esquecer o PIN, a única saída será apagar todos os dados do app.';

  @override
  String get iUnderstand => 'Entendi';

  @override
  String get biometricUnavailable =>
      'Este aparelho não tem biometria configurada.';

  @override
  String get biometricPrompt => 'Desbloqueie o Idiopatia';

  @override
  String get lockTimeout => 'Bloquear ao voltar';

  @override
  String get lockImmediately => 'Imediatamente';

  @override
  String get lockAfter1Min => 'Após 1 minuto';

  @override
  String get lockAfter5Min => 'Após 5 minutos';

  @override
  String get useBiometrics => 'Usar biometria';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get authenticateToChange => 'Autentique-se para alterar a proteção.';

  @override
  String get changePin => 'Alterar PIN';

  @override
  String get eraseAllData => 'Apagar todos os dados';

  @override
  String get eraseAllTitle => 'Apagar todos os dados?';

  @override
  String get eraseAllMessage =>
      'Todos os pacientes, crises e medicamentos serão apagados deste aparelho. Não há cópia em nenhum lugar. Esta ação não pode ser desfeita.';

  @override
  String get eraseAllSecondTitle => 'Tem certeza?';

  @override
  String get eraseAllSecondMessage => 'Digite APAGAR para confirmar.';

  @override
  String get eraseKeyword => 'APAGAR';

  @override
  String get eraseDone => 'Todos os dados foram apagados.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Seguir o sistema';

  @override
  String get exportImport => 'Exportar e importar';

  @override
  String get exportImportSubtitle => 'Backup, relatório e planilha';

  @override
  String get backupJson => 'Backup completo (JSON)';

  @override
  String get backupJsonSubtitle =>
      'Para guardar ou restaurar em outro aparelho';

  @override
  String get restoreJson => 'Restaurar backup (JSON)';

  @override
  String get restoreJsonSubtitle => 'Importa um arquivo gerado pelo Idiopatia';

  @override
  String get doctorReport => 'Relatório para o médico (PDF)';

  @override
  String get spreadsheet => 'Planilha (CSV)';

  @override
  String get whichPatients => 'Quais pacientes?';

  @override
  String get allPatients => 'Todos os pacientes';

  @override
  String onlyThisPatient(String name) {
    return 'Apenas $name';
  }

  @override
  String importSuccess(int patients, int occurrences, int uses, int skipped) {
    return 'Importação concluída: $patients pacientes, $occurrences crises, $uses medicamentos. Ignorados: $skipped.';
  }

  @override
  String importError(String reason) {
    return 'Não foi possível importar: $reason';
  }

  @override
  String get importConfirmTitle => 'Restaurar backup?';

  @override
  String get importConfirmMessage =>
      'Registros novos serão adicionados. Registros já existentes só serão substituídos se o backup for mais recente.';

  @override
  String get exportDone =>
      'Arquivo gerado. Escolha onde salvar ou com quem compartilhar.';

  @override
  String get backupReminderNever => 'Você ainda não fez backup dos seus dados.';

  @override
  String get backupReminderStale =>
      'Faça um backup. A última exportação foi há mais de 30 dias.';

  @override
  String get exportNow => 'Exportar agora';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get license => 'Licença';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get localDataNotice =>
      'Os dados existem apenas neste aparelho. Exporte um backup antes de trocar de celular.';

  @override
  String get aboutDescription =>
      'Registro pessoal de manifestações clínicas em patologias idiopáticas. Gratuito, sem anúncios, sem conta e sem coleta de dados.';

  @override
  String get errorGeneric => 'Algo deu errado.';

  @override
  String get reportTitle => 'Relatório de crises';

  @override
  String get generatedOn => 'Gerado em';

  @override
  String get type => 'Tipo';

  @override
  String get none => 'Nenhum';

  @override
  String get age => 'Idade';

  @override
  String get privacyFooter =>
      'Registros feitos pelo próprio usuário no aplicativo Idiopatia. Os dados existem apenas no aparelho do usuário.';

  @override
  String get occurrenceSaved => 'Crise registrada.';

  @override
  String get occurrenceEnded => 'Crise encerrada.';

  @override
  String get medicationSaved => 'Medicamento registrado.';

  @override
  String get savedGeneric => 'Salvo.';

  @override
  String get deletedGeneric => 'Excluído.';

  @override
  String get noPatientSelected => 'Nenhum paciente selecionado.';

  @override
  String get weekdayMon => 'Seg';

  @override
  String get weekdayTue => 'Ter';

  @override
  String get weekdayWed => 'Qua';

  @override
  String get weekdayThu => 'Qui';

  @override
  String get weekdayFri => 'Sex';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String hourLabel(int hour) {
    return '${hour}h';
  }

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String get showAll => 'Ver tudo';

  @override
  String get history => 'Histórico';

  @override
  String get triggerSuggestions => 'Sugestões';

  @override
  String get suggestedTriggerHeat => 'Calor';

  @override
  String get suggestedTriggerCold => 'Frio';

  @override
  String get suggestedTriggerExercise => 'Exercício';

  @override
  String get suggestedTriggerStress => 'Estresse';

  @override
  String get suggestedTriggerFood => 'Alimentação';

  @override
  String get suggestedTriggerSleep => 'Sono ruim';

  @override
  String get suggestedTriggerIllness => 'Doença / febre';

  @override
  String get suggestedTriggerEmotion => 'Emoção forte';

  @override
  String get endNow => 'Encerrar agora';

  @override
  String get durationSoFar => 'Duração até agora';
}
