// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navStock => 'Cellar';

  @override
  String get navAjouter => 'Add';

  @override
  String get navEmplacements => 'Locations';

  @override
  String get navHistorique => 'History';

  @override
  String get navDonnees => 'Import / Export';

  @override
  String get navParametres => 'Settings';

  @override
  String get navPlus => 'More';

  @override
  String get actionAnnuler => 'Cancel';

  @override
  String get actionConfirmer => 'Confirm';

  @override
  String get actionRetour => 'Back';

  @override
  String get actionFermer => 'Close';

  @override
  String get actionReessayer => 'Retry';

  @override
  String get actionQuitter => 'Quit';

  @override
  String get actionOk => 'OK';

  @override
  String get actionModifier => 'Edit';

  @override
  String get actionAjouter => 'Add';

  @override
  String get actionSuivant => 'Next';

  @override
  String get actionContinuer => 'Continue';

  @override
  String get actionEnregistrer => 'Save';

  @override
  String get actionReinitialiser => 'Reset';

  @override
  String get validationObligatoire => 'Required';

  @override
  String errorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String get syncConnecting => 'Connecting to shared storage…';

  @override
  String get syncSaving => 'Saving…';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncSavedToDrive => 'Cellar saved to shared storage';

  @override
  String get syncSavedAndUnlocked => 'Cellar saved and lock released';

  @override
  String get syncReadOnlyUnavailable => 'Unavailable in read-only mode';

  @override
  String get syncVerrouPose =>
      'Lock acquired — cellar up to date from shared storage';

  @override
  String get syncModificationsAbandonnees =>
      'Changes discarded — shared version restored';

  @override
  String get tooltipModePartage => 'Shared mode';

  @override
  String get tooltipModeLocal => 'Local mode — PC only';

  @override
  String get tooltipCaveEcriture => 'Your cellar is open for writing';

  @override
  String get tooltipLectureSeule => 'Read-only mode';

  @override
  String get tooltipSynchronisation => 'Syncing…';

  @override
  String get tooltipErreurSync => 'Sync error';

  @override
  String get tooltipSauvegarder => 'Save';

  @override
  String get tooltipPrendreLaMain => 'Take control';

  @override
  String get syncCrashRecoveryTitle => 'Previous session interrupted';

  @override
  String get syncCrashRecoveryBody =>
      'The last session did not end properly. Choose which version of the cellar to keep.';

  @override
  String get syncCrashSendLocal => 'Send my local data';

  @override
  String get syncCrashDownloadDrive => 'Restore from shared storage';

  @override
  String get syncCrashSendLocalConfirmTitle => 'Send my local data?';

  @override
  String get syncCrashSendLocalConfirmBody =>
      'Your local database will replace the shared version. Since the cellar was locked, no other device could have modified it since the last sync.';

  @override
  String get syncCrashConfirmSend => 'Send';

  @override
  String get syncCrashDownloadConfirmTitle => 'Restore from shared storage?';

  @override
  String get syncCrashDownloadConfirmBody =>
      'The shared database will replace your local database. All unsaved local changes will be lost.';

  @override
  String get syncCrashConfirmReplace => 'Replace my local database';

  @override
  String get syncLockTiersTitle => 'Cellar in use on another device';

  @override
  String get syncLockTiersBody =>
      'Your cellar is currently open on another device.';

  @override
  String get syncEnterReadOnly => 'Browse in read-only mode';

  @override
  String get syncAcquireLockFailedTitle => 'Cannot take control';

  @override
  String get syncAcquireLockFailedBody =>
      'The cellar is currently locked by another device.';

  @override
  String get syncStayReadOnly => 'Stay in read-only mode';

  @override
  String get syncErrorTitle => 'Sync error';

  @override
  String get syncAcquireLockTitle => 'Switch to write mode?';

  @override
  String get syncAcquireLockBodyAndroid =>
      'The cellar will be locked during your session. Use the Quit button to save your changes and release the lock before closing the app.';

  @override
  String get syncAcquireLockBodyDesktop =>
      'The cellar will be locked for your entire session. The lock will be automatically released and your changes synced when you close the app or click \"Save\".';

  @override
  String get syncPrendreLaMain => 'Take control';

  @override
  String get syncSauvegarder => 'Save';

  @override
  String get syncWriteOnboardingTitle => 'Write mode activated';

  @override
  String get syncWriteOnboardingBody =>
      'On Android, always use the Quit button to save your changes and release the lock. Without this, your data would remain local only and write access from other devices would be blocked.';

  @override
  String get syncWriteOnboardingDontShow => 'Don\'t show this again';

  @override
  String get quitDialogTitle => 'Save and quit?';

  @override
  String get quitDialogBody =>
      'Your changes will be synced and the lock released.';

  @override
  String get quitFailTitle => 'Unable to save';

  @override
  String get quitFailBody =>
      'Data could not be synced and the lock was not released.\n\nYour changes remain available locally on this device. They can be synced on your next connection, unless the lock has been manually released from another device in the meantime.\n\nWhile the lock remains active, write access from other devices will be blocked.';

  @override
  String get quitAnyway => 'Quit anyway';

  @override
  String get driveSetupMissingTitle => 'Missing configuration';

  @override
  String get driveSetupMissingBody =>
      'The Google Drive configuration file was not found next to the application.\n\nIf you installed Cavea using the installer, please uninstall and reinstall a recent version.\n\nIf you copied the application manually, consult the online configuration guide.';

  @override
  String get driveGuideEnLigne => 'Online guide';

  @override
  String get driveAuthOpening => 'Opening Google authentication…';

  @override
  String driveAuthFailed(String error) {
    return 'Authentication failed: $error';
  }

  @override
  String get driveMigrateTitle => 'Migrate to shared storage';

  @override
  String get driveMigrateBodyExisting =>
      'A cellar already exists in shared storage.\n\nWhat would you like to do?';

  @override
  String get driveMigrateBodyNew =>
      'Do you want to send your local cellar to shared storage?';

  @override
  String get driveDownloadExisting => 'Download cellar from shared storage';

  @override
  String get driveUploadOverwrite =>
      'Overwrite shared storage with my local cellar';

  @override
  String get driveSendNew => 'Send my cellar to shared storage';

  @override
  String get driveConfirmOverwriteLocalTitle => 'Overwrite local database?';

  @override
  String get driveConfirmOverwriteLocalBody =>
      'Your local database will be replaced by the shared version. All local data not in shared storage will be lost.';

  @override
  String get driveConfirmOverwriteDriveTitle => 'Overwrite shared version?';

  @override
  String get driveConfirmOverwriteDriveBody =>
      'The shared version will be replaced by your local database. All shared data not present locally will be lost.';

  @override
  String get driveDownloading => 'Downloading…';

  @override
  String get driveUploading => 'Uploading…';

  @override
  String driveDownloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String driveUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get driveModeActivated => 'Mode 2 activated — sync available';

  @override
  String get driveDeactivateTitle => 'Switch to local mode?';

  @override
  String get driveDeactivateBody =>
      'The app will switch to PC-only mode.\nYour local cave.db is kept as-is.\nThe Drive file is not deleted.';

  @override
  String get driveModeDeactivated => 'Local mode activated';

  @override
  String get settingsSectionLangue => 'Language';

  @override
  String get settingsLangAuto => 'Automatic';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionCave => 'Cellar location';

  @override
  String get settingsSectionDefaults => 'Bulk add — default values';

  @override
  String get settingsSectionListes => 'Reference lists';

  @override
  String get settingsSectionSync => 'Sync mode';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsDbFolder => 'cave.db folder';

  @override
  String get settingsDbNotConfigured => '(not configured)';

  @override
  String get settingsCouleurDefaut => 'Default colour';

  @override
  String get settingsChoisir => 'Choose…';

  @override
  String get settingsContenanceDefaut => 'Default volume';

  @override
  String get settingsRefCouleurs => 'Colours';

  @override
  String get settingsRefContenances => 'Volumes';

  @override
  String get settingsRefCrus => 'Crus';

  @override
  String settingsRefCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values',
      one: '1 value',
    );
    return '$_temp0';
  }

  @override
  String get settingsRefAddHint => 'Add a value…';

  @override
  String get settingsActiverDrive => 'Enable shared mode';

  @override
  String get settingsModePartage => 'Shared mode';

  @override
  String get settingsModeLocalCurrent => 'Current mode: PC only (local)';

  @override
  String settingsModeSyncCurrent(String provider) {
    return 'Current mode: $provider active';
  }

  @override
  String get settingsRevenirLocal => 'Switch to local';

  @override
  String get settingsChangerFournisseur => 'Change provider';

  @override
  String get settingsChoisirFournisseur => 'Choose your provider';

  @override
  String get settingsResetWriteWarning => 'Android write mode warning';

  @override
  String get settingsRestartTitle => 'Restart required';

  @override
  String get settingsRestartBody =>
      'The cellar folder has been changed.\n\nThe application must restart to use the new path.';

  @override
  String get settingsQuitApp => 'Quit application';

  @override
  String get aboutTitle => 'Cavea';

  @override
  String get aboutSubtitle => 'Personal wine cellar manager';

  @override
  String get aboutButton => 'About';

  @override
  String get aboutVersion => 'Version 0.1.0';

  @override
  String get aboutCopyright => '© 2026 Alain Benard\nApache 2.0 Licence';

  @override
  String get aboutConfidentialite => 'Privacy';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get stockSearchHint => 'Search: domain, appellation, vintage…';

  @override
  String get stockFiltresActifs => 'Active filters';

  @override
  String get stockFiltres => 'Filters';

  @override
  String get stockReinitialiseFiltres => 'Reset filters';

  @override
  String get stockReinitialise => 'Reset';

  @override
  String get stockMaturityUrgent => 'Drink now!';

  @override
  String get stockMaturityOptimal => 'Ready to drink';

  @override
  String get stockMaturityJeune => 'Too young';

  @override
  String get stockFiltresAvances => 'Advanced filters';

  @override
  String get stockFilterAppellation => 'Appellation';

  @override
  String get stockFilterMillesime => 'Vintage';

  @override
  String get stockFilterTous => 'All';

  @override
  String get stockEmptyFiltered => 'No bottles match the filters.';

  @override
  String get stockEmptyTitle => 'No bottles in stock';

  @override
  String get stockImportCsv => 'Import a CSV';

  @override
  String stockCountFiltered(int shown, int total) {
    return '$shown / $total bottles';
  }

  @override
  String stockCountTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles in stock',
      one: '1 bottle in stock',
    );
    return '$_temp0';
  }

  @override
  String get tableHeaderDomaine => 'DOMAIN';

  @override
  String get tableHeaderAppellation => 'APPELLATION';

  @override
  String get tableHeaderMillesime => 'VINT.';

  @override
  String get tableHeaderEmplacement => 'LOCATION';

  @override
  String get tableHeaderGarde => 'AGING';

  @override
  String get tableHeaderPrix => 'PRICE';

  @override
  String get maturityTropJeune => 'Too young';

  @override
  String get maturityOptimal => 'Optimal';

  @override
  String get maturityUrgent => 'Drink now!';

  @override
  String get maturityUrgentDetail => 'Drink now — urgent';

  @override
  String get maturityInconnue => 'Unknown maturity';

  @override
  String gardeDepasse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count years',
      one: '+1 year',
    );
    return '$_temp0';
  }

  @override
  String gardeEncore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years left',
      one: '1 year left',
    );
    return '$_temp0';
  }

  @override
  String gardeDans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count years',
      one: 'in 1 year',
    );
    return '$_temp0';
  }

  @override
  String get actionsReadOnly => 'Read-only mode — changes unavailable';

  @override
  String get actionsConsulterFiche => 'View details';

  @override
  String get actionsConsommer => 'Consume';

  @override
  String get actionsDeplacer => 'Move';

  @override
  String get actionsModifierFiche => 'Edit bottle';

  @override
  String get consommerTitle => 'Consume';

  @override
  String consommerDateLabel(String date) {
    return 'Consumption date: $date';
  }

  @override
  String get consommerAjouterNote => 'Add a rating';

  @override
  String get consommerCommentaireHint => 'Comment (optional)';

  @override
  String get deplacerTitle => 'Move';

  @override
  String get deplacerEmplacementObligatoire => 'Location required';

  @override
  String get deplacerFormatError =>
      'Format: \"Level1\" or \"Level1 > Level2 > …\"\n(letters, digits, spaces; separator \" > \")';

  @override
  String bulkSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles selected',
      one: '1 bottle selected',
    );
    return '$_temp0';
  }

  @override
  String get bulkReadOnly => 'Read-only mode';

  @override
  String get bulkAnnulerSelection => 'Cancel selection';

  @override
  String deplacerBatchTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count bottles',
      one: 'Move 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String consommerBatchTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Consume $count bottles',
      one: 'Consume 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddTitle => 'Add bottles';

  @override
  String get bulkAddSectionIdentite => 'Identity';

  @override
  String get bulkAddFieldDomaine => 'Domain *';

  @override
  String get bulkAddFieldAppellation => 'Appellation *';

  @override
  String get bulkAddFieldMillesime => 'Vintage *';

  @override
  String get bulkAddFieldCouleur => 'Colour *';

  @override
  String get bulkAddFieldCru => 'Cru';

  @override
  String get bulkAddFieldContenance => 'Volume';

  @override
  String get bulkAddSectionGarde => 'Aging & price';

  @override
  String get bulkAddFieldGardeMin => 'Min aging (years)';

  @override
  String get bulkAddFieldGardeMax => 'Max aging (years)';

  @override
  String get bulkAddFieldPrix => 'Purchase price (€)';

  @override
  String get bulkAddSectionFournisseur => 'Supplier';

  @override
  String get bulkAddFieldFournisseur => 'Supplier name';

  @override
  String get bulkAddFieldFournisseurInfos => 'Supplier info';

  @override
  String get bulkAddFieldProducteur => 'Producer';

  @override
  String get bulkAddSectionCommentaire => 'Comment & date';

  @override
  String get bulkAddFieldCommentaire => 'Entry comment';

  @override
  String bulkAddDateEntreeLabel(String date) {
    return 'Entry date: $date';
  }

  @override
  String get bulkAddSectionRepartition => 'Distribution';

  @override
  String get bulkAddQuantiteTotal => 'Total quantity:';

  @override
  String bulkAddAssignees(int assigned, int total) {
    return 'Assigned: $assigned / $total';
  }

  @override
  String get bulkAddAjouterEmplacement => 'Add a location';

  @override
  String bulkAddConfirmer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirm — $count bottles',
      one: 'Confirm — 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddGardeError => 'Min aging must be ≤ max aging.';

  @override
  String get bulkAddGardeDialogTitle => 'Aging not set';

  @override
  String get bulkAddGardeDialogBody =>
      'Min or max aging is not set.\n\nThe maturity of these bottles cannot be determined in the Stock view.\n\nConfirm anyway without this data?';

  @override
  String get bulkAddRetourGarde => 'Back — enter aging';

  @override
  String get bulkAddConfirmerSansGarde => 'Confirm without aging';

  @override
  String get bulkAddCancelled => 'Switched to read-only — entry cancelled';

  @override
  String get repartitionQte => 'Qty';

  @override
  String get repartitionSupprimer => 'Delete';

  @override
  String get repartitionFormatError =>
      'Format: \"Level1\" or \"Level1 > Level2\"\n(letters, digits, spaces; separator \" > \")';

  @override
  String get fieldDomaine => 'Domain';

  @override
  String get fieldAppellation => 'Appellation';

  @override
  String get fieldMillesime => 'Vintage';

  @override
  String get fieldCouleur => 'Colour';

  @override
  String get fieldCru => 'Cru';

  @override
  String get fieldContenance => 'Volume';

  @override
  String get fieldEmplacement => 'Location';

  @override
  String get fieldEmplacementRequired => 'Location *';

  @override
  String get fieldCommentaireEntree => 'Entry comment';

  @override
  String get ficheTitle => 'Bottle details';

  @override
  String get ficheNotFound => 'Bottle not found.';

  @override
  String get ficheConsommation => 'Consumption';

  @override
  String get ficheNote => 'Rating /10';

  @override
  String get ficheCommentaireDegus => 'Tasting comment';

  @override
  String get editTitle => 'Edit bottle';

  @override
  String get editGardeDialogBody =>
      'Min or max aging is not set.\n\nThe maturity of this bottle cannot be determined in the Stock view.\n\nConfirm anyway without this data?';

  @override
  String get editRestore => 'Restore original value';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearchHint => 'Search domain or appellation…';

  @override
  String get historyEmpty => 'No consumed bottles.';

  @override
  String historyEmptySearch(String query) {
    return 'No results for \"$query\".';
  }

  @override
  String get historyEmplacementOrigine => 'Original location';

  @override
  String get historyDateConsommation => 'Consumption date';

  @override
  String get historyNote => 'Rating';

  @override
  String get historyCommentaire => 'Comment';

  @override
  String get historyRehabiliter => 'Restore (put back in stock)';

  @override
  String get historyRehabiliterTitle => 'Restore this bottle?';

  @override
  String get historyRehabiliterBody =>
      'The bottle will be put back in stock at its original location.\n\nThe rating and tasting comment will be deleted.';

  @override
  String get historyRehabiliterConfirm => 'Restore';

  @override
  String get locationsEmpty => 'No bottles.';

  @override
  String get locationsDirect => 'Directly at this location';

  @override
  String locationsBouteilles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$_temp0';
  }

  @override
  String locationsBouteillesAvecPrix(int count, int prix) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$_temp0 ($prix €)';
  }

  @override
  String locationsSansPrix(int count) {
    return ' incl. $count without price';
  }

  @override
  String get donneesTitle => 'Data';

  @override
  String get importSectionTitle => 'Import a CSV';

  @override
  String get exportSectionTitle => 'Export to CSV';

  @override
  String get exportScope => 'Scope';

  @override
  String get exportStockOnly => 'Stock only';

  @override
  String get exportTout => 'All (stock + consumed)';

  @override
  String get exportSeparateur => 'Separator';

  @override
  String get exportSeparateurPointVirgule => 'Semicolon  ;';

  @override
  String get exportSeparateurVirgule => 'Comma  ,';

  @override
  String get exportSeparateurTabulation => 'Tab';

  @override
  String get exportEnCours => 'Exporting…';

  @override
  String get exportButton => 'Export…';

  @override
  String get exportEnregistrer => 'Save';

  @override
  String get exportPartager => 'Share…';

  @override
  String get exportDialogTitle => 'Save CSV';

  @override
  String exportSaved(String filename) {
    return 'File saved: $filename';
  }

  @override
  String get exportSavedAndroid => 'File saved';

  @override
  String exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get importPickFileDialog => 'Choose a CSV file';

  @override
  String get importChoisirFichier => 'Choose a CSV file';

  @override
  String get importFormatInfo =>
      'Expected format: UTF-8, header row with column names.\nColumns: id, domain, appellation, vintage, colour, …';

  @override
  String get importEcraser => 'Overwrite existing rows';

  @override
  String get importEcraserSubtitle =>
      'If unchecked, bottles already present (same UUID) are skipped.';

  @override
  String get importEnCours => 'Importing…';

  @override
  String get importButton => 'Import';

  @override
  String get importReadOnly =>
      'Import unavailable — the cellar is locked by another device.';

  @override
  String get importTermine => 'Import complete';

  @override
  String get importInserted => 'Inserted';

  @override
  String get importUpdated => 'Updated';

  @override
  String get importIgnored => 'Skipped';

  @override
  String get importErrors => 'Errors';

  @override
  String get importMasquerDetail => 'Hide details';

  @override
  String get importVoirDetail => 'Show error details';

  @override
  String importFileError(String error) {
    return 'Error reading file: $error';
  }

  @override
  String get setupTitle => 'Cavea Setup';

  @override
  String get setupWelcome => 'Welcome to Cavea';

  @override
  String get setupChooseMode => 'Choose your operating mode:';

  @override
  String get setupModeLocal => 'PC only (local)';

  @override
  String get setupModeLocalDesc => 'The database is stored locally on this PC.';

  @override
  String get setupModeDrive => 'Shared mode';

  @override
  String get setupModeDriveDesc =>
      'Share your cellar across multiple devices via Google Drive or Dropbox.';

  @override
  String get setupChooseProvider => 'Choose your cloud provider';

  @override
  String get setupProviderDriveDesc =>
      'Requires a Google account and a GCP project.';

  @override
  String get setupProviderDropboxDesc =>
      'Requires a Dropbox account. Create an app at developer.dropbox.com.';

  @override
  String get setupDropboxTitle => 'Dropbox connection';

  @override
  String get setupDropboxDescDesktop =>
      'First choose the local folder for cave.db (working cache), then connect your Dropbox account.';

  @override
  String get setupDropboxDescAndroid =>
      'Enter your Dropbox App Key, then connect.\nThe browser will open — return to Cavea after authorization.';

  @override
  String get setupDropboxAppKey => 'Dropbox App Key';

  @override
  String get setupConnectDropbox => 'Connect Dropbox';

  @override
  String get setupDropboxConnectedTitle => 'Dropbox connected';

  @override
  String get setupDropboxNoCave => 'No cellar detected on Dropbox.';

  @override
  String get setupDropboxCaveFound => 'A cellar was detected on Dropbox.';

  @override
  String get setupModeMobile => 'Mobile only';

  @override
  String get setupModeMobileDesc => 'Not available in this version.';

  @override
  String get setupFolderTitle => 'Database folder';

  @override
  String get setupFolderDesc =>
      'Choose the folder where cave.db will be stored.\nThis folder must exist.';

  @override
  String get setupFolderPath => 'Folder path';

  @override
  String get setupParcourir => 'Browse';

  @override
  String get setupPickerTitle => 'Choose cave.db folder';

  @override
  String get setupConfirmTitle => 'Confirm configuration';

  @override
  String get setupConfirmMode => 'Mode';

  @override
  String get setupConfirmDb => 'Database';

  @override
  String get setupDemarrer => 'Start Cavea';

  @override
  String get setupModifierChemin => 'Change path';

  @override
  String get setupDriveTitle => 'Google Drive connection';

  @override
  String get setupDriveDescAndroid =>
      'A local cache of the database will be maintained in the app\'s private storage (not accessible from the Android file explorer).\nConnect your Google account to continue.';

  @override
  String get setupDriveDescDesktop =>
      'First choose the local folder for cave.db (working cache), then connect your Google account.';

  @override
  String get setupDriveLocalFolder => 'Local folder (cache)';

  @override
  String get setupDrivePickerTitle => 'Local folder for cave.db';

  @override
  String get setupConnectDrive => 'Connect Google Drive';

  @override
  String get setupFolderRequired => 'Please choose a valid local folder.';

  @override
  String get setupDriveConnectedTitle => 'Google Drive connected';

  @override
  String get setupNoCave => 'No cellar detected on Google Drive.';

  @override
  String get setupCreerCave => 'Create an empty cellar';

  @override
  String get setupCaveFound => 'A cellar was detected on Google Drive.';

  @override
  String get setupJoinReadOnly => 'Join existing cellar (read-only)';

  @override
  String get setupJoin => 'Join existing cellar';

  @override
  String get setupOverwriteButton => 'Overwrite with a new empty cellar';

  @override
  String get setupOverwriteLocked =>
      'Cannot overwrite: the cellar is locked by another device';

  @override
  String get setupOverwriteTitle => 'Overwrite existing cellar?';

  @override
  String get setupOverwriteBody =>
      'This action will permanently delete cave.db from shared storage and replace it with an empty database. All current data will be lost.';

  @override
  String get setupFinalConfirmTitle => 'Final confirmation';

  @override
  String get setupFinalConfirmBody =>
      'This operation is IRREVERSIBLE.\n\nThe existing cellar will be permanently erased. Are you sure you want to create a new empty cellar?';

  @override
  String get setupEcraserDefinitivement => 'Yes, overwrite permanently';

  @override
  String setupEchec(String error) {
    return 'Failed: $error';
  }

  @override
  String get csvHeaderId => 'id';

  @override
  String get csvHeaderDomaine => 'Domain';

  @override
  String get csvHeaderAppellation => 'Appellation';

  @override
  String get csvHeaderMillesime => 'Vintage';

  @override
  String get csvHeaderCouleur => 'Colour';

  @override
  String get csvHeaderCru => 'Cru';

  @override
  String get csvHeaderContenance => 'Volume';

  @override
  String get csvHeaderEmplacement => 'Location';

  @override
  String get csvHeaderDateEntree => 'Entry date';

  @override
  String get csvHeaderDateSortie => 'Exit date';

  @override
  String get csvHeaderPrixAchat => 'Purchase price';

  @override
  String get csvHeaderGardeMin => 'Min aging';

  @override
  String get csvHeaderGardeMax => 'Max aging';

  @override
  String get csvHeaderCommentaireEntree => 'Entry comment';

  @override
  String get csvHeaderNoteDegus => 'Tasting rating';

  @override
  String get csvHeaderCommentaireDegus => 'Tasting comment';

  @override
  String get csvHeaderFournisseurNom => 'Supplier name';

  @override
  String get csvHeaderFournisseurInfos => 'Supplier info';

  @override
  String get csvHeaderProducteur => 'Producer';

  @override
  String get csvHeaderUpdatedAt => 'Updated at';
}
