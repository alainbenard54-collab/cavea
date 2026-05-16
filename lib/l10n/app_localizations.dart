import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('fr'),
    Locale('en'),
  ];

  /// No description provided for @navStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// No description provided for @navAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get navAjouter;

  /// No description provided for @navEmplacements.
  ///
  /// In fr, this message translates to:
  /// **'Emplacements'**
  String get navEmplacements;

  /// No description provided for @navHistorique.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get navHistorique;

  /// No description provided for @navDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Import / Export'**
  String get navDonnees;

  /// No description provided for @navParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navParametres;

  /// No description provided for @navPlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navPlus;

  /// No description provided for @actionAnnuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionAnnuler;

  /// No description provided for @actionConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get actionConfirmer;

  /// No description provided for @actionRetour.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get actionRetour;

  /// No description provided for @actionFermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionFermer;

  /// No description provided for @actionReessayer.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionReessayer;

  /// No description provided for @actionQuitter.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get actionQuitter;

  /// No description provided for @actionOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionModifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionModifier;

  /// No description provided for @actionAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAjouter;

  /// No description provided for @actionSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get actionSuivant;

  /// No description provided for @actionContinuer.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get actionContinuer;

  /// No description provided for @actionEnregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionEnregistrer;

  /// No description provided for @actionReinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get actionReinitialiser;

  /// No description provided for @validationObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get validationObligatoire;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {message}'**
  String errorGeneric(String message);

  /// No description provided for @syncConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à Google Drive…'**
  String get syncConnecting;

  /// No description provided for @syncSaving.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en cours…'**
  String get syncSaving;

  /// No description provided for @syncSyncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours…'**
  String get syncSyncing;

  /// No description provided for @syncSavedToDrive.
  ///
  /// In fr, this message translates to:
  /// **'Cave sauvegardée sur Drive'**
  String get syncSavedToDrive;

  /// No description provided for @syncSavedAndUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Cave sauvegardée et verrou libéré'**
  String get syncSavedAndUnlocked;

  /// No description provided for @syncReadOnlyUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible en mode lecture seule'**
  String get syncReadOnlyUnavailable;

  /// No description provided for @syncVerrouPose.
  ///
  /// In fr, this message translates to:
  /// **'Verrou posé — cave à jour depuis Drive'**
  String get syncVerrouPose;

  /// No description provided for @syncModificationsAbandonnees.
  ///
  /// In fr, this message translates to:
  /// **'Modifications abandonnées — version Drive restaurée'**
  String get syncModificationsAbandonnees;

  /// No description provided for @tooltipModePartage.
  ///
  /// In fr, this message translates to:
  /// **'Mode partagé — Google Drive'**
  String get tooltipModePartage;

  /// No description provided for @tooltipModeLocal.
  ///
  /// In fr, this message translates to:
  /// **'Mode local — PC seul'**
  String get tooltipModeLocal;

  /// No description provided for @tooltipCaveEcriture.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est ouverte en écriture'**
  String get tooltipCaveEcriture;

  /// No description provided for @tooltipLectureSeule.
  ///
  /// In fr, this message translates to:
  /// **'Mode lecture seule'**
  String get tooltipLectureSeule;

  /// No description provided for @tooltipSynchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours…'**
  String get tooltipSynchronisation;

  /// No description provided for @tooltipErreurSync.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get tooltipErreurSync;

  /// No description provided for @tooltipSauvegarder.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get tooltipSauvegarder;

  /// No description provided for @tooltipPrendreLaMain.
  ///
  /// In fr, this message translates to:
  /// **'Prendre la main'**
  String get tooltipPrendreLaMain;

  /// No description provided for @syncCrashRecoveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Session précédente interrompue'**
  String get syncCrashRecoveryTitle;

  /// No description provided for @syncCrashRecoveryBody.
  ///
  /// In fr, this message translates to:
  /// **'La dernière session ne s\'est pas terminée correctement. Choisissez quelle version de la cave conserver.'**
  String get syncCrashRecoveryBody;

  /// No description provided for @syncCrashSendLocal.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer mes données locales'**
  String get syncCrashSendLocal;

  /// No description provided for @syncCrashDownloadDrive.
  ///
  /// In fr, this message translates to:
  /// **'Repartir depuis Google Drive'**
  String get syncCrashDownloadDrive;

  /// No description provided for @syncCrashSendLocalConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer mes données locales ?'**
  String get syncCrashSendLocalConfirmTitle;

  /// No description provided for @syncCrashSendLocalConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre base locale va remplacer la version sur Google Drive. Comme la cave était verrouillée, aucun autre appareil n\'a pu la modifier depuis la dernière synchronisation.'**
  String get syncCrashSendLocalConfirmBody;

  /// No description provided for @syncCrashConfirmSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get syncCrashConfirmSend;

  /// No description provided for @syncCrashDownloadConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Repartir depuis Google Drive ?'**
  String get syncCrashDownloadConfirmTitle;

  /// No description provided for @syncCrashDownloadConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'La base Google Drive va remplacer votre base locale. Toutes vos modifications locales non sauvegardées seront perdues.'**
  String get syncCrashDownloadConfirmBody;

  /// No description provided for @syncCrashConfirmReplace.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer ma base locale'**
  String get syncCrashConfirmReplace;

  /// No description provided for @syncLockTiersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cave utilisée sur un autre appareil'**
  String get syncLockTiersTitle;

  /// No description provided for @syncLockTiersBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est actuellement ouverte sur un autre appareil.'**
  String get syncLockTiersBody;

  /// No description provided for @syncEnterReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Consulter en lecture seule'**
  String get syncEnterReadOnly;

  /// No description provided for @syncAcquireLockFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de prendre la main'**
  String get syncAcquireLockFailedTitle;

  /// No description provided for @syncAcquireLockFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'La cave est actuellement verrouillée par un autre appareil.'**
  String get syncAcquireLockFailedBody;

  /// No description provided for @syncStayReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Rester en lecture seule'**
  String get syncStayReadOnly;

  /// No description provided for @syncErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get syncErrorTitle;

  /// No description provided for @syncAcquireLockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passer en mode écriture ?'**
  String get syncAcquireLockTitle;

  /// No description provided for @syncAcquireLockBodyAndroid.
  ///
  /// In fr, this message translates to:
  /// **'La cave sera verrouillée pendant votre session. Utilisez le bouton Quitter pour sauvegarder vos modifications et libérer le verrou avant de fermer l\'application.'**
  String get syncAcquireLockBodyAndroid;

  /// No description provided for @syncAcquireLockBodyDesktop.
  ///
  /// In fr, this message translates to:
  /// **'La cave sera verrouillée pendant toute votre session. Le verrou sera automatiquement libéré et vos modifications sauvegardées sur Google Drive à la fermeture de l\'application ou via le bouton \"Sauvegarder\".'**
  String get syncAcquireLockBodyDesktop;

  /// No description provided for @syncPrendreLaMain.
  ///
  /// In fr, this message translates to:
  /// **'Prendre la main'**
  String get syncPrendreLaMain;

  /// No description provided for @syncSauvegarder.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get syncSauvegarder;

  /// No description provided for @syncWriteOnboardingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode écriture activé'**
  String get syncWriteOnboardingTitle;

  /// No description provided for @syncWriteOnboardingBody.
  ///
  /// In fr, this message translates to:
  /// **'Sur Android, utilisez toujours le bouton Quitter pour sauvegarder vos modifications et libérer le verrou. Sans cela, vos données resteraient uniquement en local et l\'accès en écriture depuis d\'autres appareils serait bloqué.'**
  String get syncWriteOnboardingBody;

  /// No description provided for @syncWriteOnboardingDontShow.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus afficher ce message'**
  String get syncWriteOnboardingDontShow;

  /// No description provided for @quitDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder et quitter ?'**
  String get quitDialogTitle;

  /// No description provided for @quitDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos modifications seront envoyées sur Drive et le verrou libéré.'**
  String get quitDialogBody;

  /// No description provided for @quitFailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de sauvegarder'**
  String get quitFailTitle;

  /// No description provided for @quitFailBody.
  ///
  /// In fr, this message translates to:
  /// **'Les données n\'ont pas pu être envoyées sur Drive et le verrou n\'a pas été libéré.\n\nVos modifications restent disponibles localement sur cet appareil. Elles pourront être synchronisées lors d\'une prochaine connexion à Drive, sauf si le verrou a été libéré manuellement depuis un autre appareil entre-temps.\n\nTant que le verrou reste actif, l\'accès en écriture depuis d\'autres appareils sera bloqué.'**
  String get quitFailBody;

  /// No description provided for @quitAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Quitter quand même'**
  String get quitAnyway;

  /// No description provided for @driveSetupMissingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration manquante'**
  String get driveSetupMissingTitle;

  /// No description provided for @driveSetupMissingBody.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier de configuration Google Drive est introuvable à côté de l\'application.\n\nSi vous avez installé Cavea via l\'installateur, veuillez le désinstaller puis réinstaller une version récente.\n\nSi vous avez copié l\'application manuellement, consultez le guide de configuration en ligne.'**
  String get driveSetupMissingBody;

  /// No description provided for @driveGuideEnLigne.
  ///
  /// In fr, this message translates to:
  /// **'Guide en ligne'**
  String get driveGuideEnLigne;

  /// No description provided for @driveAuthOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de l\'authentification Google…'**
  String get driveAuthOpening;

  /// No description provided for @driveAuthFailed.
  ///
  /// In fr, this message translates to:
  /// **'Authentification échouée : {error}'**
  String driveAuthFailed(String error);

  /// No description provided for @driveMigrateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Migrer vers Google Drive'**
  String get driveMigrateTitle;

  /// No description provided for @driveMigrateBodyExisting.
  ///
  /// In fr, this message translates to:
  /// **'Une cave existe déjà sur Google Drive.\n\nQue souhaitez-vous faire ?'**
  String get driveMigrateBodyExisting;

  /// No description provided for @driveMigrateBodyNew.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous envoyer votre cave locale vers Google Drive ?'**
  String get driveMigrateBodyNew;

  /// No description provided for @driveDownloadExisting.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer la cave du Drive'**
  String get driveDownloadExisting;

  /// No description provided for @driveUploadOverwrite.
  ///
  /// In fr, this message translates to:
  /// **'Écraser le Drive avec ma cave locale'**
  String get driveUploadOverwrite;

  /// No description provided for @driveSendNew.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer ma cave vers Drive'**
  String get driveSendNew;

  /// No description provided for @driveConfirmOverwriteLocalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écraser la base locale ?'**
  String get driveConfirmOverwriteLocalTitle;

  /// No description provided for @driveConfirmOverwriteLocalBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre base locale sera remplacée par la version Google Drive. Toutes les données locales non présentes sur Drive seront perdues.'**
  String get driveConfirmOverwriteLocalBody;

  /// No description provided for @driveConfirmOverwriteDriveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écraser la version Drive ?'**
  String get driveConfirmOverwriteDriveTitle;

  /// No description provided for @driveConfirmOverwriteDriveBody.
  ///
  /// In fr, this message translates to:
  /// **'La version sur Google Drive sera remplacée par votre base locale. Toutes les données Drive non présentes localement seront perdues.'**
  String get driveConfirmOverwriteDriveBody;

  /// No description provided for @driveDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement en cours…'**
  String get driveDownloading;

  /// No description provided for @driveUploading.
  ///
  /// In fr, this message translates to:
  /// **'Upload en cours…'**
  String get driveUploading;

  /// No description provided for @driveDownloadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement échoué : {error}'**
  String driveDownloadFailed(String error);

  /// No description provided for @driveUploadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Upload échoué : {error}'**
  String driveUploadFailed(String error);

  /// No description provided for @driveModeActivated.
  ///
  /// In fr, this message translates to:
  /// **'Mode 2 activé — synchronisation Google Drive disponible'**
  String get driveModeActivated;

  /// No description provided for @driveDeactivateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Revenir en mode local ?'**
  String get driveDeactivateTitle;

  /// No description provided for @driveDeactivateBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'app passera en mode PC seul.\nVotre cave.db local est conservé tel quel.\nLe fichier Drive n\'est pas supprimé.'**
  String get driveDeactivateBody;

  /// No description provided for @driveModeDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Mode local activé'**
  String get driveModeDeactivated;

  /// No description provided for @settingsSectionLangue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsSectionLangue;

  /// No description provided for @settingsLangAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get settingsLangAuto;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsSectionCave.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement de la cave'**
  String get settingsSectionCave;

  /// No description provided for @settingsSectionDefaults.
  ///
  /// In fr, this message translates to:
  /// **'Ajout en lot — valeurs par défaut'**
  String get settingsSectionDefaults;

  /// No description provided for @settingsSectionListes.
  ///
  /// In fr, this message translates to:
  /// **'Listes de référence'**
  String get settingsSectionListes;

  /// No description provided for @settingsSectionSync.
  ///
  /// In fr, this message translates to:
  /// **'Mode de synchronisation'**
  String get settingsSectionSync;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsSectionAbout;

  /// No description provided for @settingsDbFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier cave.db'**
  String get settingsDbFolder;

  /// No description provided for @settingsDbNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'(non configuré)'**
  String get settingsDbNotConfigured;

  /// No description provided for @settingsCouleurDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Couleur par défaut'**
  String get settingsCouleurDefaut;

  /// No description provided for @settingsChoisir.
  ///
  /// In fr, this message translates to:
  /// **'Choisir…'**
  String get settingsChoisir;

  /// No description provided for @settingsContenanceDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Contenance par défaut'**
  String get settingsContenanceDefaut;

  /// No description provided for @settingsRefCouleurs.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs'**
  String get settingsRefCouleurs;

  /// No description provided for @settingsRefContenances.
  ///
  /// In fr, this message translates to:
  /// **'Contenances'**
  String get settingsRefContenances;

  /// No description provided for @settingsRefCrus.
  ///
  /// In fr, this message translates to:
  /// **'Crus'**
  String get settingsRefCrus;

  /// No description provided for @settingsRefCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 valeur} other{{count} valeurs}}'**
  String settingsRefCount(int count);

  /// No description provided for @settingsRefAddHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une valeur…'**
  String get settingsRefAddHint;

  /// No description provided for @settingsActiverDrive.
  ///
  /// In fr, this message translates to:
  /// **'Activer le mode partagé'**
  String get settingsActiverDrive;

  /// No description provided for @settingsModePartage.
  ///
  /// In fr, this message translates to:
  /// **'Mode partagé'**
  String get settingsModePartage;

  /// No description provided for @settingsModeLocalCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Mode actuel : PC seul (local)'**
  String get settingsModeLocalCurrent;

  /// No description provided for @settingsModeSyncCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Mode actuel : {provider} actif'**
  String settingsModeSyncCurrent(String provider);

  /// No description provided for @settingsRevenirLocal.
  ///
  /// In fr, this message translates to:
  /// **'Revenir en local'**
  String get settingsRevenirLocal;

  /// No description provided for @settingsChangerFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Changer de fournisseur'**
  String get settingsChangerFournisseur;

  /// No description provided for @settingsChoisirFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre fournisseur'**
  String get settingsChoisirFournisseur;

  /// No description provided for @settingsResetWriteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement mode écriture Android'**
  String get settingsResetWriteWarning;

  /// No description provided for @settingsRestartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage requis'**
  String get settingsRestartTitle;

  /// No description provided for @settingsRestartBody.
  ///
  /// In fr, this message translates to:
  /// **'Le dossier de la cave a été modifié.\n\nL\'application doit redémarrer pour utiliser le nouveau chemin.'**
  String get settingsRestartBody;

  /// No description provided for @settingsQuitApp.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'application'**
  String get settingsQuitApp;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cavea'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestionnaire de cave à vin personnel'**
  String get aboutSubtitle;

  /// No description provided for @aboutButton.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutButton;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version 0.1.0'**
  String get aboutVersion;

  /// No description provided for @aboutCopyright.
  ///
  /// In fr, this message translates to:
  /// **'© 2026 Alain Benard\nLicence Apache 2.0'**
  String get aboutCopyright;

  /// No description provided for @aboutConfidentialite.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get aboutConfidentialite;

  /// No description provided for @aboutLicences.
  ///
  /// In fr, this message translates to:
  /// **'Licences'**
  String get aboutLicences;

  /// No description provided for @stockSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher : domaine, appellation, millésime…'**
  String get stockSearchHint;

  /// No description provided for @stockFiltresActifs.
  ///
  /// In fr, this message translates to:
  /// **'Filtres actifs'**
  String get stockFiltresActifs;

  /// No description provided for @stockFiltres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get stockFiltres;

  /// No description provided for @stockReinitialiseFiltres.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get stockReinitialiseFiltres;

  /// No description provided for @stockReinitialise.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get stockReinitialise;

  /// No description provided for @stockMaturityUrgent.
  ///
  /// In fr, this message translates to:
  /// **'À boire urgent !'**
  String get stockMaturityUrgent;

  /// No description provided for @stockMaturityOptimal.
  ///
  /// In fr, this message translates to:
  /// **'À boire'**
  String get stockMaturityOptimal;

  /// No description provided for @stockMaturityJeune.
  ///
  /// In fr, this message translates to:
  /// **'Trop jeune'**
  String get stockMaturityJeune;

  /// No description provided for @stockFiltresAvances.
  ///
  /// In fr, this message translates to:
  /// **'Filtres avancés'**
  String get stockFiltresAvances;

  /// No description provided for @stockFilterAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get stockFilterAppellation;

  /// No description provided for @stockFilterMillesime.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get stockFilterMillesime;

  /// No description provided for @stockFilterTous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get stockFilterTous;

  /// No description provided for @stockEmptyFiltered.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bouteille ne correspond aux filtres.'**
  String get stockEmptyFiltered;

  /// No description provided for @stockEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bouteille en stock'**
  String get stockEmptyTitle;

  /// No description provided for @stockImportCsv.
  ///
  /// In fr, this message translates to:
  /// **'Importer un CSV'**
  String get stockImportCsv;

  /// No description provided for @stockCountFiltered.
  ///
  /// In fr, this message translates to:
  /// **'{shown} / {total} bouteilles'**
  String stockCountFiltered(int shown, int total);

  /// No description provided for @stockCountTotal.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille en stock} other{{count} bouteilles en stock}}'**
  String stockCountTotal(int count);

  /// No description provided for @tableHeaderDomaine.
  ///
  /// In fr, this message translates to:
  /// **'DOMAINE'**
  String get tableHeaderDomaine;

  /// No description provided for @tableHeaderAppellation.
  ///
  /// In fr, this message translates to:
  /// **'APPELLATION'**
  String get tableHeaderAppellation;

  /// No description provided for @tableHeaderMillesime.
  ///
  /// In fr, this message translates to:
  /// **'MILL.'**
  String get tableHeaderMillesime;

  /// No description provided for @tableHeaderEmplacement.
  ///
  /// In fr, this message translates to:
  /// **'EMPLACEMENT'**
  String get tableHeaderEmplacement;

  /// No description provided for @tableHeaderGarde.
  ///
  /// In fr, this message translates to:
  /// **'GARDE'**
  String get tableHeaderGarde;

  /// No description provided for @tableHeaderPrix.
  ///
  /// In fr, this message translates to:
  /// **'PRIX'**
  String get tableHeaderPrix;

  /// No description provided for @maturityTropJeune.
  ///
  /// In fr, this message translates to:
  /// **'Trop jeune'**
  String get maturityTropJeune;

  /// No description provided for @maturityOptimal.
  ///
  /// In fr, this message translates to:
  /// **'Optimal'**
  String get maturityOptimal;

  /// No description provided for @maturityUrgent.
  ///
  /// In fr, this message translates to:
  /// **'À boire !'**
  String get maturityUrgent;

  /// No description provided for @maturityUrgentDetail.
  ///
  /// In fr, this message translates to:
  /// **'À boire — urgent'**
  String get maturityUrgentDetail;

  /// No description provided for @maturityInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Maturité inconnue'**
  String get maturityInconnue;

  /// No description provided for @gardeDepasse.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{+1 an} other{+{count} ans}}'**
  String gardeDepasse(int count);

  /// No description provided for @gardeEncore.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{encore 1 an} other{encore {count} ans}}'**
  String gardeEncore(int count);

  /// No description provided for @gardeDans.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{dans 1 an} other{dans {count} ans}}'**
  String gardeDans(int count);

  /// No description provided for @actionsReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Mode lecture seule — modifications indisponibles'**
  String get actionsReadOnly;

  /// No description provided for @actionsConsulterFiche.
  ///
  /// In fr, this message translates to:
  /// **'Consulter la fiche'**
  String get actionsConsulterFiche;

  /// No description provided for @actionsConsommer.
  ///
  /// In fr, this message translates to:
  /// **'Consommer'**
  String get actionsConsommer;

  /// No description provided for @actionsDeplacer.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer'**
  String get actionsDeplacer;

  /// No description provided for @actionsModifierFiche.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get actionsModifierFiche;

  /// No description provided for @consommerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consommer'**
  String get consommerTitle;

  /// No description provided for @consommerDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de consommation : {date}'**
  String consommerDateLabel(String date);

  /// No description provided for @consommerAjouterNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get consommerAjouterNote;

  /// No description provided for @consommerCommentaireHint.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire (optionnel)'**
  String get consommerCommentaireHint;

  /// No description provided for @deplacerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer'**
  String get deplacerTitle;

  /// No description provided for @deplacerEmplacementObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement obligatoire'**
  String get deplacerEmplacementObligatoire;

  /// No description provided for @deplacerFormatError.
  ///
  /// In fr, this message translates to:
  /// **'Format : \"Niveau1\" ou \"Niveau1 > Niveau2 > …\"\n(lettres, chiffres, espaces ; séparateur \" > \")'**
  String get deplacerFormatError;

  /// No description provided for @bulkSelectionCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille sélectionnée} other{{count} bouteilles sélectionnées}}'**
  String bulkSelectionCount(int count);

  /// No description provided for @bulkReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Mode lecture seule'**
  String get bulkReadOnly;

  /// No description provided for @bulkAnnulerSelection.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la sélection'**
  String get bulkAnnulerSelection;

  /// No description provided for @deplacerBatchTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Déplacer 1 bouteille} other{Déplacer {count} bouteilles}}'**
  String deplacerBatchTitle(int count);

  /// No description provided for @consommerBatchTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Consommer 1 bouteille} other{Consommer {count} bouteilles}}'**
  String consommerBatchTitle(int count);

  /// No description provided for @bulkAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des bouteilles'**
  String get bulkAddTitle;

  /// No description provided for @bulkAddSectionIdentite.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get bulkAddSectionIdentite;

  /// No description provided for @bulkAddFieldDomaine.
  ///
  /// In fr, this message translates to:
  /// **'Domaine *'**
  String get bulkAddFieldDomaine;

  /// No description provided for @bulkAddFieldAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation *'**
  String get bulkAddFieldAppellation;

  /// No description provided for @bulkAddFieldMillesime.
  ///
  /// In fr, this message translates to:
  /// **'Millésime *'**
  String get bulkAddFieldMillesime;

  /// No description provided for @bulkAddFieldCouleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleur *'**
  String get bulkAddFieldCouleur;

  /// No description provided for @bulkAddFieldCru.
  ///
  /// In fr, this message translates to:
  /// **'Cru'**
  String get bulkAddFieldCru;

  /// No description provided for @bulkAddFieldContenance.
  ///
  /// In fr, this message translates to:
  /// **'Contenance'**
  String get bulkAddFieldContenance;

  /// No description provided for @bulkAddSectionGarde.
  ///
  /// In fr, this message translates to:
  /// **'Garde & prix'**
  String get bulkAddSectionGarde;

  /// No description provided for @bulkAddFieldGardeMin.
  ///
  /// In fr, this message translates to:
  /// **'Garde min (ans)'**
  String get bulkAddFieldGardeMin;

  /// No description provided for @bulkAddFieldGardeMax.
  ///
  /// In fr, this message translates to:
  /// **'Garde max (ans)'**
  String get bulkAddFieldGardeMax;

  /// No description provided for @bulkAddFieldPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix achat (€)'**
  String get bulkAddFieldPrix;

  /// No description provided for @bulkAddSectionFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get bulkAddSectionFournisseur;

  /// No description provided for @bulkAddFieldFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Nom fournisseur'**
  String get bulkAddFieldFournisseur;

  /// No description provided for @bulkAddFieldFournisseurInfos.
  ///
  /// In fr, this message translates to:
  /// **'Infos fournisseur'**
  String get bulkAddFieldFournisseurInfos;

  /// No description provided for @bulkAddFieldProducteur.
  ///
  /// In fr, this message translates to:
  /// **'Producteur'**
  String get bulkAddFieldProducteur;

  /// No description provided for @bulkAddSectionCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire & date'**
  String get bulkAddSectionCommentaire;

  /// No description provided for @bulkAddFieldCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire entrée'**
  String get bulkAddFieldCommentaire;

  /// No description provided for @bulkAddDateEntreeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'entrée : {date}'**
  String bulkAddDateEntreeLabel(String date);

  /// No description provided for @bulkAddSectionRepartition.
  ///
  /// In fr, this message translates to:
  /// **'Répartition'**
  String get bulkAddSectionRepartition;

  /// No description provided for @bulkAddQuantiteTotal.
  ///
  /// In fr, this message translates to:
  /// **'Quantité totale :'**
  String get bulkAddQuantiteTotal;

  /// No description provided for @bulkAddAssignees.
  ///
  /// In fr, this message translates to:
  /// **'Assignées : {assigned} / {total}'**
  String bulkAddAssignees(int assigned, int total);

  /// No description provided for @bulkAddAjouterEmplacement.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un emplacement'**
  String get bulkAddAjouterEmplacement;

  /// No description provided for @bulkAddConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Confirmer — 1 bouteille} other{Confirmer — {count} bouteilles}}'**
  String bulkAddConfirmer(int count);

  /// No description provided for @bulkAddGardeError.
  ///
  /// In fr, this message translates to:
  /// **'Garde min doit être ≤ garde max.'**
  String get bulkAddGardeError;

  /// No description provided for @bulkAddGardeDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Garde non renseignée'**
  String get bulkAddGardeDialogTitle;

  /// No description provided for @bulkAddGardeDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'La garde min ou max n\'est pas renseignée.\n\nLa maturité de ces bouteilles ne pourra pas être déterminée dans la vue Stock.\n\nConfirmer quand même sans ces données ?'**
  String get bulkAddGardeDialogBody;

  /// No description provided for @bulkAddRetourGarde.
  ///
  /// In fr, this message translates to:
  /// **'Retour — saisir la garde'**
  String get bulkAddRetourGarde;

  /// No description provided for @bulkAddConfirmerSansGarde.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer sans garde'**
  String get bulkAddConfirmerSansGarde;

  /// No description provided for @bulkAddCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Retour en lecture seule — saisie annulée'**
  String get bulkAddCancelled;

  /// No description provided for @repartitionQte.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get repartitionQte;

  /// No description provided for @repartitionSupprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get repartitionSupprimer;

  /// No description provided for @repartitionFormatError.
  ///
  /// In fr, this message translates to:
  /// **'Format : \"Niveau1\" ou \"Niveau1 > Niveau2\"\n(lettres, chiffres, espaces ; séparateur \" > \")'**
  String get repartitionFormatError;

  /// No description provided for @fieldDomaine.
  ///
  /// In fr, this message translates to:
  /// **'Domaine'**
  String get fieldDomaine;

  /// No description provided for @fieldAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get fieldAppellation;

  /// No description provided for @fieldMillesime.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get fieldMillesime;

  /// No description provided for @fieldCouleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get fieldCouleur;

  /// No description provided for @fieldCru.
  ///
  /// In fr, this message translates to:
  /// **'Cru'**
  String get fieldCru;

  /// No description provided for @fieldContenance.
  ///
  /// In fr, this message translates to:
  /// **'Contenance'**
  String get fieldContenance;

  /// No description provided for @fieldEmplacement.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get fieldEmplacement;

  /// No description provided for @fieldEmplacementRequired.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement *'**
  String get fieldEmplacementRequired;

  /// No description provided for @fieldCommentaireEntree.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire d\'entrée'**
  String get fieldCommentaireEntree;

  /// No description provided for @ficheTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche bouteille'**
  String get ficheTitle;

  /// No description provided for @ficheNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bouteille introuvable.'**
  String get ficheNotFound;

  /// No description provided for @ficheConsommation.
  ///
  /// In fr, this message translates to:
  /// **'Consommation'**
  String get ficheConsommation;

  /// No description provided for @ficheNote.
  ///
  /// In fr, this message translates to:
  /// **'Note /10'**
  String get ficheNote;

  /// No description provided for @ficheCommentaireDegus.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire de dégustation'**
  String get ficheCommentaireDegus;

  /// No description provided for @editTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get editTitle;

  /// No description provided for @editGardeDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'La garde min ou max n\'est pas renseignée.\n\nLa maturité de cette bouteille ne pourra pas être déterminée dans la vue Stock.\n\nConfirmer quand même sans ces données ?'**
  String get editGardeDialogBody;

  /// No description provided for @editRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer la valeur initiale'**
  String get editRestore;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTitle;

  /// No description provided for @historySearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher domaine ou appellation…'**
  String get historySearchHint;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bouteille consommée.'**
  String get historyEmpty;

  /// No description provided for @historyEmptySearch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour \"{query}\".'**
  String historyEmptySearch(String query);

  /// No description provided for @historyEmplacementOrigine.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement d\'origine'**
  String get historyEmplacementOrigine;

  /// No description provided for @historyDateConsommation.
  ///
  /// In fr, this message translates to:
  /// **'Date de consommation'**
  String get historyDateConsommation;

  /// No description provided for @historyNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get historyNote;

  /// No description provided for @historyCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get historyCommentaire;

  /// No description provided for @historyRehabiliter.
  ///
  /// In fr, this message translates to:
  /// **'Réhabiliter (remettre en stock)'**
  String get historyRehabiliter;

  /// No description provided for @historyRehabiliterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réhabiliter cette bouteille ?'**
  String get historyRehabiliterTitle;

  /// No description provided for @historyRehabiliterBody.
  ///
  /// In fr, this message translates to:
  /// **'La bouteille sera remise en stock à son emplacement d\'origine.\n\nLa note et le commentaire de dégustation seront effacés.'**
  String get historyRehabiliterBody;

  /// No description provided for @historyRehabiliterConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Réhabiliter'**
  String get historyRehabiliterConfirm;

  /// No description provided for @locationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bouteille.'**
  String get locationsEmpty;

  /// No description provided for @locationsDirect.
  ///
  /// In fr, this message translates to:
  /// **'Directement dans cet emplacement'**
  String get locationsDirect;

  /// No description provided for @locationsBouteilles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille} other{{count} bouteilles}}'**
  String locationsBouteilles(int count);

  /// No description provided for @locationsBouteillesAvecPrix.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille} other{{count} bouteilles}} ({prix} €)'**
  String locationsBouteillesAvecPrix(int count, int prix);

  /// No description provided for @locationsSansPrix.
  ///
  /// In fr, this message translates to:
  /// **' dont {count} sans prix'**
  String locationsSansPrix(int count);

  /// No description provided for @donneesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get donneesTitle;

  /// No description provided for @importSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer un CSV'**
  String get importSectionTitle;

  /// No description provided for @exportSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportSectionTitle;

  /// No description provided for @exportScope.
  ///
  /// In fr, this message translates to:
  /// **'Scope'**
  String get exportScope;

  /// No description provided for @exportStockOnly.
  ///
  /// In fr, this message translates to:
  /// **'Stock uniquement'**
  String get exportStockOnly;

  /// No description provided for @exportTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout (stock + consommées)'**
  String get exportTout;

  /// No description provided for @exportSeparateur.
  ///
  /// In fr, this message translates to:
  /// **'Séparateur'**
  String get exportSeparateur;

  /// No description provided for @exportSeparateurPointVirgule.
  ///
  /// In fr, this message translates to:
  /// **'Point-virgule  ;'**
  String get exportSeparateurPointVirgule;

  /// No description provided for @exportSeparateurVirgule.
  ///
  /// In fr, this message translates to:
  /// **'Virgule  ,'**
  String get exportSeparateurVirgule;

  /// No description provided for @exportSeparateurTabulation.
  ///
  /// In fr, this message translates to:
  /// **'Tabulation'**
  String get exportSeparateurTabulation;

  /// No description provided for @exportEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours…'**
  String get exportEnCours;

  /// No description provided for @exportButton.
  ///
  /// In fr, this message translates to:
  /// **'Exporter…'**
  String get exportButton;

  /// No description provided for @exportEnregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get exportEnregistrer;

  /// No description provided for @exportPartager.
  ///
  /// In fr, this message translates to:
  /// **'Partager…'**
  String get exportPartager;

  /// No description provided for @exportDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le CSV'**
  String get exportDialogTitle;

  /// No description provided for @exportSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {filename}'**
  String exportSaved(String filename);

  /// No description provided for @exportSavedAndroid.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré'**
  String get exportSavedAndroid;

  /// No description provided for @exportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export : {error}'**
  String exportError(String error);

  /// No description provided for @importPickFileDialog.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier CSV'**
  String get importPickFileDialog;

  /// No description provided for @importChoisirFichier.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier CSV'**
  String get importChoisirFichier;

  /// No description provided for @importFormatInfo.
  ///
  /// In fr, this message translates to:
  /// **'Format attendu : UTF-8, ligne d\'en-tête avec les noms de colonnes.\nColonnes : id, domaine, appellation, millesime, couleur, …'**
  String get importFormatInfo;

  /// No description provided for @importEcraser.
  ///
  /// In fr, this message translates to:
  /// **'Écraser les lignes existantes'**
  String get importEcraser;

  /// No description provided for @importEcraserSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Si décoché, les bouteilles déjà présentes (même UUID) sont ignorées.'**
  String get importEcraserSubtitle;

  /// No description provided for @importEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Import en cours…'**
  String get importEnCours;

  /// No description provided for @importButton.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importButton;

  /// No description provided for @importReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Import indisponible — la cave est verrouillée par un autre appareil.'**
  String get importReadOnly;

  /// No description provided for @importTermine.
  ///
  /// In fr, this message translates to:
  /// **'Import terminé'**
  String get importTermine;

  /// No description provided for @importInserted.
  ///
  /// In fr, this message translates to:
  /// **'Insérées'**
  String get importInserted;

  /// No description provided for @importUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour'**
  String get importUpdated;

  /// No description provided for @importIgnored.
  ///
  /// In fr, this message translates to:
  /// **'Ignorées'**
  String get importIgnored;

  /// No description provided for @importErrors.
  ///
  /// In fr, this message translates to:
  /// **'Erreurs'**
  String get importErrors;

  /// No description provided for @importMasquerDetail.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le détail'**
  String get importMasquerDetail;

  /// No description provided for @importVoirDetail.
  ///
  /// In fr, this message translates to:
  /// **'Voir le détail des erreurs'**
  String get importVoirDetail;

  /// No description provided for @importFileError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la lecture du fichier : {error}'**
  String importFileError(String error);

  /// No description provided for @setupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration de Cavea'**
  String get setupTitle;

  /// No description provided for @setupWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans Cavea'**
  String get setupWelcome;

  /// No description provided for @setupChooseMode.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre mode de fonctionnement :'**
  String get setupChooseMode;

  /// No description provided for @setupModeLocal.
  ///
  /// In fr, this message translates to:
  /// **'PC seul (local)'**
  String get setupModeLocal;

  /// No description provided for @setupModeLocalDesc.
  ///
  /// In fr, this message translates to:
  /// **'La base de données est stockée localement sur ce PC.'**
  String get setupModeLocalDesc;

  /// No description provided for @setupModeDrive.
  ///
  /// In fr, this message translates to:
  /// **'Mode partagé'**
  String get setupModeDrive;

  /// No description provided for @setupModeDriveDesc.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre cave entre plusieurs appareils via Google Drive ou Dropbox.'**
  String get setupModeDriveDesc;

  /// No description provided for @setupChooseProvider.
  String get setupChooseProvider;

  /// No description provided for @setupProviderDriveDesc.
  String get setupProviderDriveDesc;

  /// No description provided for @setupProviderDropboxDesc.
  String get setupProviderDropboxDesc;

  /// No description provided for @setupDropboxTitle.
  String get setupDropboxTitle;

  /// No description provided for @setupDropboxDescDesktop.
  String get setupDropboxDescDesktop;

  /// No description provided for @setupDropboxDescAndroid.
  String get setupDropboxDescAndroid;

  /// No description provided for @setupDropboxAppKey.
  String get setupDropboxAppKey;

  /// No description provided for @setupConnectDropbox.
  String get setupConnectDropbox;

  /// No description provided for @setupModeMobile.
  ///
  /// In fr, this message translates to:
  /// **'Mobile seul'**
  String get setupModeMobile;

  /// No description provided for @setupModeMobileDesc.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible dans cette version.'**
  String get setupModeMobileDesc;

  /// No description provided for @setupFolderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier de la base de données'**
  String get setupFolderTitle;

  /// No description provided for @setupFolderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le dossier où sera stocké cave.db.\nCe dossier doit exister.'**
  String get setupFolderDesc;

  /// No description provided for @setupFolderPath.
  ///
  /// In fr, this message translates to:
  /// **'Chemin du dossier'**
  String get setupFolderPath;

  /// No description provided for @setupParcourir.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir'**
  String get setupParcourir;

  /// No description provided for @setupPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le dossier de cave.db'**
  String get setupPickerTitle;

  /// No description provided for @setupConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la configuration'**
  String get setupConfirmTitle;

  /// No description provided for @setupConfirmMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get setupConfirmMode;

  /// No description provided for @setupConfirmDb.
  ///
  /// In fr, this message translates to:
  /// **'Base de données'**
  String get setupConfirmDb;

  /// No description provided for @setupDemarrer.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer Cavea'**
  String get setupDemarrer;

  /// No description provided for @setupModifierChemin.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le chemin'**
  String get setupModifierChemin;

  /// No description provided for @setupDriveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google Drive'**
  String get setupDriveTitle;

  /// No description provided for @setupDriveDescAndroid.
  ///
  /// In fr, this message translates to:
  /// **'Un cache local de la base sera maintenu dans le stockage privé de l\'application (non accessible depuis l\'explorateur de fichiers Android).\nConnectez votre compte Google pour continuer.'**
  String get setupDriveDescAndroid;

  /// No description provided for @setupDriveDescDesktop.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord le dossier local pour cave.db (cache de travail), puis connectez votre compte Google.'**
  String get setupDriveDescDesktop;

  /// No description provided for @setupDriveLocalFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier local (cache)'**
  String get setupDriveLocalFolder;

  /// No description provided for @setupDrivePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier local pour cave.db'**
  String get setupDrivePickerTitle;

  /// No description provided for @setupConnectDrive.
  ///
  /// In fr, this message translates to:
  /// **'Connecter Google Drive'**
  String get setupConnectDrive;

  /// No description provided for @setupFolderRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un dossier local valide.'**
  String get setupFolderRequired;

  /// No description provided for @setupDriveConnectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Google Drive connecté'**
  String get setupDriveConnectedTitle;

  /// No description provided for @setupNoCave.
  ///
  /// In fr, this message translates to:
  /// **'Aucune cave n\'a été détectée sur Google Drive.'**
  String get setupNoCave;

  /// No description provided for @setupCreerCave.
  ///
  /// In fr, this message translates to:
  /// **'Créer une cave vide'**
  String get setupCreerCave;

  /// No description provided for @setupCaveFound.
  ///
  /// In fr, this message translates to:
  /// **'Une cave a été détectée sur Google Drive.'**
  String get setupCaveFound;

  /// No description provided for @setupJoinReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre la cave existante (lecture seule)'**
  String get setupJoinReadOnly;

  /// No description provided for @setupJoin.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre la cave existante'**
  String get setupJoin;

  /// No description provided for @setupOverwriteButton.
  ///
  /// In fr, this message translates to:
  /// **'Écraser par une nouvelle cave vide'**
  String get setupOverwriteButton;

  /// No description provided for @setupOverwriteLocked.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'écraser : la cave est verrouillée par un autre appareil'**
  String get setupOverwriteLocked;

  /// No description provided for @setupOverwriteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écraser la cave existante ?'**
  String get setupOverwriteTitle;

  /// No description provided for @setupOverwriteBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action supprimera définitivement cave.db du Drive et le remplacera par une base vide. Toutes les données actuelles seront perdues.'**
  String get setupOverwriteBody;

  /// No description provided for @setupFinalConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation finale'**
  String get setupFinalConfirmTitle;

  /// No description provided for @setupFinalConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette opération est IRRÉVERSIBLE.\n\nLa cave existante sera définitivement effacée. Confirmez-vous vouloir créer une nouvelle cave vide ?'**
  String get setupFinalConfirmBody;

  /// No description provided for @setupEcraserDefinitivement.
  ///
  /// In fr, this message translates to:
  /// **'Oui, écraser définitivement'**
  String get setupEcraserDefinitivement;

  /// No description provided for @setupEchec.
  ///
  /// In fr, this message translates to:
  /// **'Échec : {error}'**
  String setupEchec(String error);

  /// No description provided for @csvHeaderId.
  ///
  /// In fr, this message translates to:
  /// **'id'**
  String get csvHeaderId;

  /// No description provided for @csvHeaderDomaine.
  ///
  /// In fr, this message translates to:
  /// **'Domaine'**
  String get csvHeaderDomaine;

  /// No description provided for @csvHeaderAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get csvHeaderAppellation;

  /// No description provided for @csvHeaderMillesime.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get csvHeaderMillesime;

  /// No description provided for @csvHeaderCouleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get csvHeaderCouleur;

  /// No description provided for @csvHeaderCru.
  ///
  /// In fr, this message translates to:
  /// **'Cru'**
  String get csvHeaderCru;

  /// No description provided for @csvHeaderContenance.
  ///
  /// In fr, this message translates to:
  /// **'Contenance'**
  String get csvHeaderContenance;

  /// No description provided for @csvHeaderEmplacement.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get csvHeaderEmplacement;

  /// No description provided for @csvHeaderDateEntree.
  ///
  /// In fr, this message translates to:
  /// **'Date entrée'**
  String get csvHeaderDateEntree;

  /// No description provided for @csvHeaderDateSortie.
  ///
  /// In fr, this message translates to:
  /// **'Date sortie'**
  String get csvHeaderDateSortie;

  /// No description provided for @csvHeaderPrixAchat.
  ///
  /// In fr, this message translates to:
  /// **'Prix achat'**
  String get csvHeaderPrixAchat;

  /// No description provided for @csvHeaderGardeMin.
  ///
  /// In fr, this message translates to:
  /// **'Garde min'**
  String get csvHeaderGardeMin;

  /// No description provided for @csvHeaderGardeMax.
  ///
  /// In fr, this message translates to:
  /// **'Garde max'**
  String get csvHeaderGardeMax;

  /// No description provided for @csvHeaderCommentaireEntree.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire entrée'**
  String get csvHeaderCommentaireEntree;

  /// No description provided for @csvHeaderNoteDegus.
  ///
  /// In fr, this message translates to:
  /// **'Note dégustation'**
  String get csvHeaderNoteDegus;

  /// No description provided for @csvHeaderCommentaireDegus.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire dégustation'**
  String get csvHeaderCommentaireDegus;

  /// No description provided for @csvHeaderFournisseurNom.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur nom'**
  String get csvHeaderFournisseurNom;

  /// No description provided for @csvHeaderFournisseurInfos.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur infos'**
  String get csvHeaderFournisseurInfos;

  /// No description provided for @csvHeaderProducteur.
  ///
  /// In fr, this message translates to:
  /// **'Producteur'**
  String get csvHeaderProducteur;

  /// No description provided for @csvHeaderUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour le'**
  String get csvHeaderUpdatedAt;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
