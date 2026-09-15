// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Idiopatia';

  @override
  String get privacyPromise =>
      'Your data stays only on this device. Nothing is sent to servers or third parties.';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingSubtitle =>
      'Let\'s start by adding the first patient. It can be you or someone you care for.';

  @override
  String get patient => 'Patient';

  @override
  String get patients => 'Patients';

  @override
  String get newPatient => 'New patient';

  @override
  String get editPatient => 'Edit patient';

  @override
  String get managePatients => 'Manage patients';

  @override
  String get selectPatient => 'Select patient';

  @override
  String get name => 'Name';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get sex => 'Sex';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexMale => 'Male';

  @override
  String get sexOther => 'Other / prefer not to say';

  @override
  String get condition => 'Idiopathic condition';

  @override
  String get conditionHint => 'E.g. craniofacial hyperhidrosis';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
      zero: 'under 1 year',
    );
    return '$_temp0';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get continueLabel => 'Continue';

  @override
  String get later => 'Later';

  @override
  String get requiredField => 'Required field';

  @override
  String get selectDate => 'Select date';

  @override
  String get deletePatientTitle => 'Delete patient?';

  @override
  String deletePatientMessage(String name) {
    return 'All records of $name will be erased. This cannot be undone.';
  }

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get summary => 'Summary';

  @override
  String get settings => 'Settings';

  @override
  String get registerCrisis => 'Log an episode';

  @override
  String get registerMedication => 'Log medication';

  @override
  String get ongoingCrisis => 'Episode in progress';

  @override
  String startedAgo(String duration) {
    return 'Started $duration ago';
  }

  @override
  String get endCrisis => 'End episode';

  @override
  String get recentEvents => 'Recent events';

  @override
  String get noEvents =>
      'No records yet. Tap \"Log an episode\" when a manifestation occurs.';

  @override
  String get crisis => 'Episode';

  @override
  String get crises => 'Episodes';

  @override
  String get medicationUse => 'Medication';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get ongoing => 'In progress';

  @override
  String get duration => 'Duration';

  @override
  String get intensity => 'Intensity';

  @override
  String get intensityMild => 'Mild';

  @override
  String get intensityModerate => 'Moderate';

  @override
  String get intensityIntense => 'Intense';

  @override
  String get triggers => 'Triggers';

  @override
  String get unknownTrigger => 'Unknown';

  @override
  String get newTrigger => 'New trigger';

  @override
  String get notes => 'Notes';

  @override
  String get setEnd => 'Set end time';

  @override
  String get endMustBeAfterStart => 'End must be after start.';

  @override
  String get anotherOngoingTitle => 'An episode is already in progress';

  @override
  String get anotherOngoingMessage =>
      'This usually means the previous episode was not ended. Log another one anyway?';

  @override
  String get registerAnyway => 'Log anyway';

  @override
  String get newCrisis => 'New episode';

  @override
  String get editCrisis => 'Edit episode';

  @override
  String get deleteCrisisTitle => 'Delete episode?';

  @override
  String get deleteConfirmGeneric => 'This cannot be undone.';

  @override
  String get medication => 'Medication';

  @override
  String get medications => 'Medications';

  @override
  String get newMedication => 'New medication';

  @override
  String get dose => 'Dose';

  @override
  String get defaultDose => 'Default dose';

  @override
  String get doseHint => 'E.g. 10 mg, 5 ml, 1 tablet';

  @override
  String get linkedCrisis => 'Related episode';

  @override
  String get noLinkedCrisis => 'None (preventive use)';

  @override
  String crisisStartedAt(String dateTime) {
    return 'Episode of $dateTime';
  }

  @override
  String get dateTime => 'Date and time';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get editMedicationUse => 'Edit medication';

  @override
  String get deleteMedicationUseTitle => 'Delete record?';

  @override
  String get selectMedication => 'Select the medication';

  @override
  String get catalogs => 'Lists';

  @override
  String get catalogsSubtitle => 'Patient\'s triggers and medications';

  @override
  String get manageTriggers => 'Triggers';

  @override
  String get manageMedications => 'Medications';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get rename => 'Rename';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get nameAlreadyExists => 'An item with this name already exists.';

  @override
  String get noCatalogItems => 'No items. Tap + to add.';

  @override
  String get cannotDeleteUsedItem =>
      'This item is used in records and cannot be deleted. You can deactivate it.';

  @override
  String get inactiveItemsHint =>
      'Deactivated items are hidden when logging but remain in history.';

  @override
  String get today => 'Today';

  @override
  String get noEventsOnDay => 'No events on this day.';

  @override
  String get period => 'Period';

  @override
  String get last30Days => '30 days';

  @override
  String get last90Days => '90 days';

  @override
  String get last12Months => '12 months';

  @override
  String get allTime => 'All';

  @override
  String get crisesCount => 'Episodes';

  @override
  String get averageDuration => 'Average duration';

  @override
  String get maxDuration => 'Longest duration';

  @override
  String get daysSinceLast => 'Days since last';

  @override
  String get averageInterval => 'Average interval';

  @override
  String get byIntensity => 'By intensity';

  @override
  String get triggerRanking => 'Most frequent triggers';

  @override
  String get byHourOfDay => 'By start hour';

  @override
  String get byWeekday => 'By weekday';

  @override
  String get medicationUses => 'Medication uses';

  @override
  String get noDataPeriod => 'No records in this period.';

  @override
  String ongoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in progress',
      one: '1 in progress',
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
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get security => 'Access protection';

  @override
  String get securitySubtitle => 'PIN or biometrics when opening the app';

  @override
  String get securityOff => 'Off';

  @override
  String get securityPin => 'Access PIN';

  @override
  String get securityBiometric => 'Biometrics';

  @override
  String get securityExplanation =>
      'Protects the records from anyone who picks up the device. You can turn it off at any time.';

  @override
  String get setPin => 'Set PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMismatch => 'PINs do not match.';

  @override
  String get pinLength => 'PIN must have 4 to 6 digits.';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get wrongPin => 'Wrong PIN.';

  @override
  String get recoveryPinInfo =>
      'Biometrics may fail or be removed from the device. Also set a recovery PIN.';

  @override
  String get forgotPinWarning =>
      'Warning: there is no server or account. If you forget the PIN, the only way out is to erase all app data.';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get biometricUnavailable => 'This device has no biometrics set up.';

  @override
  String get biometricPrompt => 'Unlock Idiopatia';

  @override
  String get lockTimeout => 'Lock when returning';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get lockAfter1Min => 'After 1 minute';

  @override
  String get lockAfter5Min => 'After 5 minutes';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get unlock => 'Unlock';

  @override
  String get authenticateToChange => 'Authenticate to change protection.';

  @override
  String get changePin => 'Change PIN';

  @override
  String get eraseAllData => 'Erase all data';

  @override
  String get eraseAllTitle => 'Erase all data?';

  @override
  String get eraseAllMessage =>
      'All patients, episodes and medications will be erased from this device. There is no copy anywhere. This cannot be undone.';

  @override
  String get eraseAllSecondTitle => 'Are you sure?';

  @override
  String get eraseAllSecondMessage => 'Type ERASE to confirm.';

  @override
  String get eraseKeyword => 'ERASE';

  @override
  String get eraseDone => 'All data has been erased.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get exportImport => 'Export and import';

  @override
  String get exportImportSubtitle => 'Backup, report and spreadsheet';

  @override
  String get backupJson => 'Full backup (JSON)';

  @override
  String get backupJsonSubtitle => 'To keep or restore on another device';

  @override
  String get restoreJson => 'Restore backup (JSON)';

  @override
  String get restoreJsonSubtitle => 'Imports a file created by Idiopatia';

  @override
  String get doctorReport => 'Report for the doctor (PDF)';

  @override
  String get spreadsheet => 'Spreadsheet (CSV)';

  @override
  String get whichPatients => 'Which patients?';

  @override
  String get allPatients => 'All patients';

  @override
  String onlyThisPatient(String name) {
    return 'Only $name';
  }

  @override
  String importSuccess(int patients, int occurrences, int uses, int skipped) {
    return 'Import complete: $patients patients, $occurrences episodes, $uses medications. Skipped: $skipped.';
  }

  @override
  String importError(String reason) {
    return 'Could not import: $reason';
  }

  @override
  String get importConfirmTitle => 'Restore backup?';

  @override
  String get importConfirmMessage =>
      'New records will be added. Existing records are only replaced if the backup is newer.';

  @override
  String get exportDone =>
      'File created. Choose where to save it or who to share it with.';

  @override
  String get backupReminderNever => 'You have not backed up your data yet.';

  @override
  String get backupReminderStale =>
      'Make a backup. The last export was more than 30 days ago.';

  @override
  String get exportNow => 'Export now';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get license => 'License';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get localDataNotice =>
      'Data exists only on this device. Export a backup before changing phones.';

  @override
  String get aboutDescription =>
      'Personal log of clinical manifestations in idiopathic conditions. Free, no ads, no account and no data collection.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get reportTitle => 'Episode report';

  @override
  String get generatedOn => 'Generated on';

  @override
  String get type => 'Type';

  @override
  String get none => 'None';

  @override
  String get age => 'Age';

  @override
  String get privacyFooter =>
      'Records entered by the user in the Idiopatia app. Data exists only on the user\'s device.';

  @override
  String get occurrenceSaved => 'Episode logged.';

  @override
  String get occurrenceEnded => 'Episode ended.';

  @override
  String get medicationSaved => 'Medication logged.';

  @override
  String get savedGeneric => 'Saved.';

  @override
  String get deletedGeneric => 'Deleted.';

  @override
  String get noPatientSelected => 'No patient selected.';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String hourLabel(int hour) {
    return '${hour}h';
  }

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get showAll => 'Show all';

  @override
  String get history => 'History';

  @override
  String get triggerSuggestions => 'Suggestions';

  @override
  String get suggestedTriggerHeat => 'Heat';

  @override
  String get suggestedTriggerCold => 'Cold';

  @override
  String get suggestedTriggerExercise => 'Exercise';

  @override
  String get suggestedTriggerStress => 'Stress';

  @override
  String get suggestedTriggerFood => 'Food';

  @override
  String get suggestedTriggerSleep => 'Poor sleep';

  @override
  String get suggestedTriggerIllness => 'Illness / fever';

  @override
  String get suggestedTriggerEmotion => 'Strong emotion';

  @override
  String get endNow => 'End now';

  @override
  String get durationSoFar => 'Duration so far';
}
