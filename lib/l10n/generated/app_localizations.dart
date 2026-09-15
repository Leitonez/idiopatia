import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idiopatia'**
  String get appTitle;

  /// No description provided for @privacyPromise.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados ficam apenas neste aparelho. Nada é enviado a servidores ou a terceiros.'**
  String get privacyPromise;

  /// No description provided for @onboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos começar cadastrando o primeiro paciente. Pode ser você ou alguém de quem você cuida.'**
  String get onboardingSubtitle;

  /// No description provided for @patient.
  ///
  /// In pt, this message translates to:
  /// **'Paciente'**
  String get patient;

  /// No description provided for @patients.
  ///
  /// In pt, this message translates to:
  /// **'Pacientes'**
  String get patients;

  /// No description provided for @newPatient.
  ///
  /// In pt, this message translates to:
  /// **'Novo paciente'**
  String get newPatient;

  /// No description provided for @editPatient.
  ///
  /// In pt, this message translates to:
  /// **'Editar paciente'**
  String get editPatient;

  /// No description provided for @managePatients.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar pacientes'**
  String get managePatients;

  /// No description provided for @selectPatient.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar paciente'**
  String get selectPatient;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @birthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get birthDate;

  /// No description provided for @sex.
  ///
  /// In pt, this message translates to:
  /// **'Sexo'**
  String get sex;

  /// No description provided for @sexFemale.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get sexMale;

  /// No description provided for @sexOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro / prefiro não informar'**
  String get sexOther;

  /// No description provided for @condition.
  ///
  /// In pt, this message translates to:
  /// **'Idiopatia'**
  String get condition;

  /// No description provided for @conditionHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: hiperidrose craniofacial'**
  String get conditionHint;

  /// No description provided for @ageYears.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{menos de 1 ano} =1{1 ano} other{{count} anos}}'**
  String ageYears(int count);

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @continueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @later.
  ///
  /// In pt, this message translates to:
  /// **'Depois'**
  String get later;

  /// No description provided for @requiredField.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get requiredField;

  /// No description provided for @selectDate.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar data'**
  String get selectDate;

  /// No description provided for @deletePatientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir paciente?'**
  String get deletePatientTitle;

  /// No description provided for @deletePatientMessage.
  ///
  /// In pt, this message translates to:
  /// **'Todos os registros de {name} serão apagados. Esta ação não pode ser desfeita.'**
  String deletePatientMessage(String name);

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get calendar;

  /// No description provided for @summary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo'**
  String get summary;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @registerCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Registrar crise'**
  String get registerCrisis;

  /// No description provided for @registerMedication.
  ///
  /// In pt, this message translates to:
  /// **'Registrar medicamento'**
  String get registerMedication;

  /// No description provided for @ongoingCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Crise em andamento'**
  String get ongoingCrisis;

  /// No description provided for @startedAgo.
  ///
  /// In pt, this message translates to:
  /// **'Início há {duration}'**
  String startedAgo(String duration);

  /// No description provided for @endCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar crise'**
  String get endCrisis;

  /// No description provided for @recentEvents.
  ///
  /// In pt, this message translates to:
  /// **'Últimos eventos'**
  String get recentEvents;

  /// No description provided for @noEvents.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro ainda. Toque em \"Registrar crise\" quando houver uma manifestação.'**
  String get noEvents;

  /// No description provided for @crisis.
  ///
  /// In pt, this message translates to:
  /// **'Crise'**
  String get crisis;

  /// No description provided for @crises.
  ///
  /// In pt, this message translates to:
  /// **'Crises'**
  String get crises;

  /// No description provided for @medicationUse.
  ///
  /// In pt, this message translates to:
  /// **'Medicamento'**
  String get medicationUse;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get start;

  /// No description provided for @end.
  ///
  /// In pt, this message translates to:
  /// **'Término'**
  String get end;

  /// No description provided for @ongoing.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get ongoing;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @intensity.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade'**
  String get intensity;

  /// No description provided for @intensityMild.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get intensityMild;

  /// No description provided for @intensityModerate.
  ///
  /// In pt, this message translates to:
  /// **'Moderada'**
  String get intensityModerate;

  /// No description provided for @intensityIntense.
  ///
  /// In pt, this message translates to:
  /// **'Intensa'**
  String get intensityIntense;

  /// No description provided for @triggers.
  ///
  /// In pt, this message translates to:
  /// **'Gatilhos'**
  String get triggers;

  /// No description provided for @unknownTrigger.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get unknownTrigger;

  /// No description provided for @newTrigger.
  ///
  /// In pt, this message translates to:
  /// **'Novo gatilho'**
  String get newTrigger;

  /// No description provided for @notes.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get notes;

  /// No description provided for @setEnd.
  ///
  /// In pt, this message translates to:
  /// **'Informar término'**
  String get setEnd;

  /// No description provided for @endMustBeAfterStart.
  ///
  /// In pt, this message translates to:
  /// **'O término deve ser posterior ao início.'**
  String get endMustBeAfterStart;

  /// No description provided for @anotherOngoingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma crise em andamento'**
  String get anotherOngoingTitle;

  /// No description provided for @anotherOngoingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Normalmente isso indica que a crise anterior não foi encerrada. Deseja registrar outra mesmo assim?'**
  String get anotherOngoingMessage;

  /// No description provided for @registerAnyway.
  ///
  /// In pt, this message translates to:
  /// **'Registrar mesmo assim'**
  String get registerAnyway;

  /// No description provided for @newCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Nova crise'**
  String get newCrisis;

  /// No description provided for @editCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Editar crise'**
  String get editCrisis;

  /// No description provided for @deleteCrisisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir crise?'**
  String get deleteCrisisTitle;

  /// No description provided for @deleteConfirmGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita.'**
  String get deleteConfirmGeneric;

  /// No description provided for @medication.
  ///
  /// In pt, this message translates to:
  /// **'Medicamento'**
  String get medication;

  /// No description provided for @medications.
  ///
  /// In pt, this message translates to:
  /// **'Medicamentos'**
  String get medications;

  /// No description provided for @newMedication.
  ///
  /// In pt, this message translates to:
  /// **'Novo medicamento'**
  String get newMedication;

  /// No description provided for @dose.
  ///
  /// In pt, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @defaultDose.
  ///
  /// In pt, this message translates to:
  /// **'Dose padrão'**
  String get defaultDose;

  /// No description provided for @doseHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 10 mg, 5 ml, 1 comprimido'**
  String get doseHint;

  /// No description provided for @linkedCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Crise relacionada'**
  String get linkedCrisis;

  /// No description provided for @noLinkedCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma (uso preventivo)'**
  String get noLinkedCrisis;

  /// No description provided for @crisisStartedAt.
  ///
  /// In pt, this message translates to:
  /// **'Crise de {dateTime}'**
  String crisisStartedAt(String dateTime);

  /// No description provided for @dateTime.
  ///
  /// In pt, this message translates to:
  /// **'Data e hora'**
  String get dateTime;

  /// No description provided for @date.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @time.
  ///
  /// In pt, this message translates to:
  /// **'Hora'**
  String get time;

  /// No description provided for @editMedicationUse.
  ///
  /// In pt, this message translates to:
  /// **'Editar medicamento'**
  String get editMedicationUse;

  /// No description provided for @deleteMedicationUseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir registro?'**
  String get deleteMedicationUseTitle;

  /// No description provided for @selectMedication.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o medicamento'**
  String get selectMedication;

  /// No description provided for @catalogs.
  ///
  /// In pt, this message translates to:
  /// **'Listas'**
  String get catalogs;

  /// No description provided for @catalogsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gatilhos e medicamentos do paciente'**
  String get catalogsSubtitle;

  /// No description provided for @manageTriggers.
  ///
  /// In pt, this message translates to:
  /// **'Gatilhos'**
  String get manageTriggers;

  /// No description provided for @manageMedications.
  ///
  /// In pt, this message translates to:
  /// **'Medicamentos'**
  String get manageMedications;

  /// No description provided for @active.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get inactive;

  /// No description provided for @rename.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get rename;

  /// No description provided for @deactivate.
  ///
  /// In pt, this message translates to:
  /// **'Desativar'**
  String get deactivate;

  /// No description provided for @reactivate.
  ///
  /// In pt, this message translates to:
  /// **'Reativar'**
  String get reactivate;

  /// No description provided for @nameAlreadyExists.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um item com esse nome.'**
  String get nameAlreadyExists;

  /// No description provided for @noCatalogItems.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item. Toque em + para adicionar.'**
  String get noCatalogItems;

  /// No description provided for @cannotDeleteUsedItem.
  ///
  /// In pt, this message translates to:
  /// **'Este item já foi usado em registros e não pode ser excluído. Você pode desativá-lo.'**
  String get cannotDeleteUsedItem;

  /// No description provided for @inactiveItemsHint.
  ///
  /// In pt, this message translates to:
  /// **'Itens desativados não aparecem ao registrar, mas continuam no histórico.'**
  String get inactiveItemsHint;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @noEventsOnDay.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento neste dia.'**
  String get noEventsOnDay;

  /// No description provided for @period.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get period;

  /// No description provided for @last30Days.
  ///
  /// In pt, this message translates to:
  /// **'30 dias'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In pt, this message translates to:
  /// **'90 dias'**
  String get last90Days;

  /// No description provided for @last12Months.
  ///
  /// In pt, this message translates to:
  /// **'12 meses'**
  String get last12Months;

  /// No description provided for @allTime.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get allTime;

  /// No description provided for @crisesCount.
  ///
  /// In pt, this message translates to:
  /// **'Crises'**
  String get crisesCount;

  /// No description provided for @averageDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração média'**
  String get averageDuration;

  /// No description provided for @maxDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração máxima'**
  String get maxDuration;

  /// No description provided for @daysSinceLast.
  ///
  /// In pt, this message translates to:
  /// **'Dias desde a última'**
  String get daysSinceLast;

  /// No description provided for @averageInterval.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo médio'**
  String get averageInterval;

  /// No description provided for @byIntensity.
  ///
  /// In pt, this message translates to:
  /// **'Por intensidade'**
  String get byIntensity;

  /// No description provided for @triggerRanking.
  ///
  /// In pt, this message translates to:
  /// **'Gatilhos mais frequentes'**
  String get triggerRanking;

  /// No description provided for @byHourOfDay.
  ///
  /// In pt, this message translates to:
  /// **'Por hora de início'**
  String get byHourOfDay;

  /// No description provided for @byWeekday.
  ///
  /// In pt, this message translates to:
  /// **'Por dia da semana'**
  String get byWeekday;

  /// No description provided for @medicationUses.
  ///
  /// In pt, this message translates to:
  /// **'Usos de medicamento'**
  String get medicationUses;

  /// No description provided for @noDataPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros no período.'**
  String get noDataPeriod;

  /// No description provided for @ongoingCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 em andamento} other{{count} em andamento}}'**
  String ongoingCount(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{hours}h {minutes}min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationDaysHours.
  ///
  /// In pt, this message translates to:
  /// **'{days}d {hours}h'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @daysCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String daysCount(int count);

  /// No description provided for @security.
  ///
  /// In pt, this message translates to:
  /// **'Proteção de acesso'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'PIN ou biometria ao abrir o app'**
  String get securitySubtitle;

  /// No description provided for @securityOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligada'**
  String get securityOff;

  /// No description provided for @securityPin.
  ///
  /// In pt, this message translates to:
  /// **'PIN de acesso'**
  String get securityPin;

  /// No description provided for @securityBiometric.
  ///
  /// In pt, this message translates to:
  /// **'Biometria'**
  String get securityBiometric;

  /// No description provided for @securityExplanation.
  ///
  /// In pt, this message translates to:
  /// **'Protege os registros de quem pegar o aparelho. Você pode desligar a qualquer momento.'**
  String get securityExplanation;

  /// No description provided for @setPin.
  ///
  /// In pt, this message translates to:
  /// **'Definir PIN'**
  String get setPin;

  /// No description provided for @newPin.
  ///
  /// In pt, this message translates to:
  /// **'Novo PIN'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In pt, this message translates to:
  /// **'Confirme o PIN'**
  String get confirmPin;

  /// No description provided for @pinMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os PINs não coincidem.'**
  String get pinMismatch;

  /// No description provided for @pinLength.
  ///
  /// In pt, this message translates to:
  /// **'O PIN deve ter de 4 a 6 dígitos.'**
  String get pinLength;

  /// No description provided for @enterPin.
  ///
  /// In pt, this message translates to:
  /// **'Digite o PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In pt, this message translates to:
  /// **'PIN incorreto.'**
  String get wrongPin;

  /// No description provided for @recoveryPinInfo.
  ///
  /// In pt, this message translates to:
  /// **'A biometria pode falhar ou ser removida do aparelho. Defina também um PIN de recuperação.'**
  String get recoveryPinInfo;

  /// No description provided for @forgotPinWarning.
  ///
  /// In pt, this message translates to:
  /// **'Atenção: não há servidor nem conta. Se você esquecer o PIN, a única saída será apagar todos os dados do app.'**
  String get forgotPinWarning;

  /// No description provided for @iUnderstand.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get iUnderstand;

  /// No description provided for @biometricUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Este aparelho não tem biometria configurada.'**
  String get biometricUnavailable;

  /// No description provided for @biometricPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie o Idiopatia'**
  String get biometricPrompt;

  /// No description provided for @lockTimeout.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear ao voltar'**
  String get lockTimeout;

  /// No description provided for @lockImmediately.
  ///
  /// In pt, this message translates to:
  /// **'Imediatamente'**
  String get lockImmediately;

  /// No description provided for @lockAfter1Min.
  ///
  /// In pt, this message translates to:
  /// **'Após 1 minuto'**
  String get lockAfter1Min;

  /// No description provided for @lockAfter5Min.
  ///
  /// In pt, this message translates to:
  /// **'Após 5 minutos'**
  String get lockAfter5Min;

  /// No description provided for @useBiometrics.
  ///
  /// In pt, this message translates to:
  /// **'Usar biometria'**
  String get useBiometrics;

  /// No description provided for @unlock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear'**
  String get unlock;

  /// No description provided for @authenticateToChange.
  ///
  /// In pt, this message translates to:
  /// **'Autentique-se para alterar a proteção.'**
  String get authenticateToChange;

  /// No description provided for @changePin.
  ///
  /// In pt, this message translates to:
  /// **'Alterar PIN'**
  String get changePin;

  /// No description provided for @eraseAllData.
  ///
  /// In pt, this message translates to:
  /// **'Apagar todos os dados'**
  String get eraseAllData;

  /// No description provided for @eraseAllTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar todos os dados?'**
  String get eraseAllTitle;

  /// No description provided for @eraseAllMessage.
  ///
  /// In pt, this message translates to:
  /// **'Todos os pacientes, crises e medicamentos serão apagados deste aparelho. Não há cópia em nenhum lugar. Esta ação não pode ser desfeita.'**
  String get eraseAllMessage;

  /// No description provided for @eraseAllSecondTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza?'**
  String get eraseAllSecondTitle;

  /// No description provided for @eraseAllSecondMessage.
  ///
  /// In pt, this message translates to:
  /// **'Digite APAGAR para confirmar.'**
  String get eraseAllSecondMessage;

  /// No description provided for @eraseKeyword.
  ///
  /// In pt, this message translates to:
  /// **'APAGAR'**
  String get eraseKeyword;

  /// No description provided for @eraseDone.
  ///
  /// In pt, this message translates to:
  /// **'Todos os dados foram apagados.'**
  String get eraseDone;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Seguir o sistema'**
  String get languageSystem;

  /// No description provided for @exportImport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar e importar'**
  String get exportImport;

  /// No description provided for @exportImportSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Backup, relatório e planilha'**
  String get exportImportSubtitle;

  /// No description provided for @backupJson.
  ///
  /// In pt, this message translates to:
  /// **'Backup completo (JSON)'**
  String get backupJson;

  /// No description provided for @backupJsonSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Para guardar ou restaurar em outro aparelho'**
  String get backupJsonSubtitle;

  /// No description provided for @restoreJson.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar backup (JSON)'**
  String get restoreJson;

  /// No description provided for @restoreJsonSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Importa um arquivo gerado pelo Idiopatia'**
  String get restoreJsonSubtitle;

  /// No description provided for @doctorReport.
  ///
  /// In pt, this message translates to:
  /// **'Relatório para o médico (PDF)'**
  String get doctorReport;

  /// No description provided for @spreadsheet.
  ///
  /// In pt, this message translates to:
  /// **'Planilha (CSV)'**
  String get spreadsheet;

  /// No description provided for @whichPatients.
  ///
  /// In pt, this message translates to:
  /// **'Quais pacientes?'**
  String get whichPatients;

  /// No description provided for @allPatients.
  ///
  /// In pt, this message translates to:
  /// **'Todos os pacientes'**
  String get allPatients;

  /// No description provided for @onlyThisPatient.
  ///
  /// In pt, this message translates to:
  /// **'Apenas {name}'**
  String onlyThisPatient(String name);

  /// No description provided for @importSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Importação concluída: {patients} pacientes, {occurrences} crises, {uses} medicamentos. Ignorados: {skipped}.'**
  String importSuccess(int patients, int occurrences, int uses, int skipped);

  /// No description provided for @importError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível importar: {reason}'**
  String importError(String reason);

  /// No description provided for @importConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar backup?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'Registros novos serão adicionados. Registros já existentes só serão substituídos se o backup for mais recente.'**
  String get importConfirmMessage;

  /// No description provided for @exportDone.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo gerado. Escolha onde salvar ou com quem compartilhar.'**
  String get exportDone;

  /// No description provided for @backupReminderNever.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não fez backup dos seus dados.'**
  String get backupReminderNever;

  /// No description provided for @backupReminderStale.
  ///
  /// In pt, this message translates to:
  /// **'Faça um backup. A última exportação foi há mais de 30 dias.'**
  String get backupReminderStale;

  /// No description provided for @exportNow.
  ///
  /// In pt, this message translates to:
  /// **'Exportar agora'**
  String get exportNow;

  /// No description provided for @about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about;

  /// No description provided for @version.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get version;

  /// No description provided for @license.
  ///
  /// In pt, this message translates to:
  /// **'Licença'**
  String get license;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get privacyPolicy;

  /// No description provided for @localDataNotice.
  ///
  /// In pt, this message translates to:
  /// **'Os dados existem apenas neste aparelho. Exporte um backup antes de trocar de celular.'**
  String get localDataNotice;

  /// No description provided for @aboutDescription.
  ///
  /// In pt, this message translates to:
  /// **'Registro pessoal de manifestações clínicas em patologias idiopáticas. Gratuito, sem anúncios, sem conta e sem coleta de dados.'**
  String get aboutDescription;

  /// No description provided for @errorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado.'**
  String get errorGeneric;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatório de crises'**
  String get reportTitle;

  /// No description provided for @generatedOn.
  ///
  /// In pt, this message translates to:
  /// **'Gerado em'**
  String get generatedOn;

  /// No description provided for @type.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @none.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum'**
  String get none;

  /// No description provided for @age.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get age;

  /// No description provided for @privacyFooter.
  ///
  /// In pt, this message translates to:
  /// **'Registros feitos pelo próprio usuário no aplicativo Idiopatia. Os dados existem apenas no aparelho do usuário.'**
  String get privacyFooter;

  /// No description provided for @occurrenceSaved.
  ///
  /// In pt, this message translates to:
  /// **'Crise registrada.'**
  String get occurrenceSaved;

  /// No description provided for @occurrenceEnded.
  ///
  /// In pt, this message translates to:
  /// **'Crise encerrada.'**
  String get occurrenceEnded;

  /// No description provided for @medicationSaved.
  ///
  /// In pt, this message translates to:
  /// **'Medicamento registrado.'**
  String get medicationSaved;

  /// No description provided for @savedGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Salvo.'**
  String get savedGeneric;

  /// No description provided for @deletedGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Excluído.'**
  String get deletedGeneric;

  /// No description provided for @noPatientSelected.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum paciente selecionado.'**
  String get noPatientSelected;

  /// No description provided for @weekdayMon.
  ///
  /// In pt, this message translates to:
  /// **'Seg'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In pt, this message translates to:
  /// **'Ter'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In pt, this message translates to:
  /// **'Qua'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In pt, this message translates to:
  /// **'Qui'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In pt, this message translates to:
  /// **'Sex'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In pt, this message translates to:
  /// **'Sáb'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In pt, this message translates to:
  /// **'Dom'**
  String get weekdaySun;

  /// No description provided for @previousMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In pt, this message translates to:
  /// **'Próximo mês'**
  String get nextMonth;

  /// No description provided for @hourLabel.
  ///
  /// In pt, this message translates to:
  /// **'{hour}h'**
  String hourLabel(int hour);

  /// No description provided for @eventsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 evento} other{{count} eventos}}'**
  String eventsCount(int count);

  /// No description provided for @showAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get showAll;

  /// No description provided for @history.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get history;

  /// No description provided for @triggerSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões'**
  String get triggerSuggestions;

  /// No description provided for @suggestedTriggerHeat.
  ///
  /// In pt, this message translates to:
  /// **'Calor'**
  String get suggestedTriggerHeat;

  /// No description provided for @suggestedTriggerCold.
  ///
  /// In pt, this message translates to:
  /// **'Frio'**
  String get suggestedTriggerCold;

  /// No description provided for @suggestedTriggerExercise.
  ///
  /// In pt, this message translates to:
  /// **'Exercício'**
  String get suggestedTriggerExercise;

  /// No description provided for @suggestedTriggerStress.
  ///
  /// In pt, this message translates to:
  /// **'Estresse'**
  String get suggestedTriggerStress;

  /// No description provided for @suggestedTriggerFood.
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get suggestedTriggerFood;

  /// No description provided for @suggestedTriggerSleep.
  ///
  /// In pt, this message translates to:
  /// **'Sono ruim'**
  String get suggestedTriggerSleep;

  /// No description provided for @suggestedTriggerIllness.
  ///
  /// In pt, this message translates to:
  /// **'Doença / febre'**
  String get suggestedTriggerIllness;

  /// No description provided for @suggestedTriggerEmotion.
  ///
  /// In pt, this message translates to:
  /// **'Emoção forte'**
  String get suggestedTriggerEmotion;

  /// No description provided for @endNow.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar agora'**
  String get endNow;

  /// No description provided for @durationSoFar.
  ///
  /// In pt, this message translates to:
  /// **'Duração até agora'**
  String get durationSoFar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
