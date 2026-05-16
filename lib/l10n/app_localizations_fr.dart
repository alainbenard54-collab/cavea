// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navStock => 'Stock';

  @override
  String get navAjouter => 'Ajouter';

  @override
  String get navEmplacements => 'Emplacements';

  @override
  String get navHistorique => 'Historique';

  @override
  String get navDonnees => 'Import / Export';

  @override
  String get navParametres => 'Paramètres';

  @override
  String get navPlus => 'Plus';

  @override
  String get actionAnnuler => 'Annuler';

  @override
  String get actionConfirmer => 'Confirmer';

  @override
  String get actionRetour => 'Retour';

  @override
  String get actionFermer => 'Fermer';

  @override
  String get actionReessayer => 'Réessayer';

  @override
  String get actionQuitter => 'Quitter';

  @override
  String get actionOk => 'OK';

  @override
  String get actionModifier => 'Modifier';

  @override
  String get actionAjouter => 'Ajouter';

  @override
  String get actionSuivant => 'Suivant';

  @override
  String get actionContinuer => 'Continuer';

  @override
  String get actionEnregistrer => 'Enregistrer';

  @override
  String get actionReinitialiser => 'Réinitialiser';

  @override
  String get validationObligatoire => 'Obligatoire';

  @override
  String errorGeneric(String message) {
    return 'Erreur : $message';
  }

  @override
  String get syncConnecting => 'Connexion au partage…';

  @override
  String get syncSaving => 'Sauvegarde en cours…';

  @override
  String get syncSyncing => 'Synchronisation en cours…';

  @override
  String get syncSavedToDrive => 'Cave sauvegardée dans le partage';

  @override
  String get syncSavedAndUnlocked => 'Cave sauvegardée et verrou libéré';

  @override
  String get syncReadOnlyUnavailable => 'Indisponible en mode lecture seule';

  @override
  String get syncVerrouPose => 'Verrou posé — cave à jour depuis le partage';

  @override
  String get syncModificationsAbandonnees =>
      'Modifications abandonnées — version partagée restaurée';

  @override
  String get tooltipModePartage => 'Mode partagé';

  @override
  String get tooltipModeLocal => 'Mode local — PC seul';

  @override
  String get tooltipCaveEcriture => 'Votre cave est ouverte en écriture';

  @override
  String get tooltipLectureSeule => 'Mode lecture seule';

  @override
  String get tooltipSynchronisation => 'Synchronisation en cours…';

  @override
  String get tooltipErreurSync => 'Erreur de synchronisation';

  @override
  String get tooltipSauvegarder => 'Sauvegarder';

  @override
  String get tooltipPrendreLaMain => 'Prendre la main';

  @override
  String get syncCrashRecoveryTitle => 'Session précédente interrompue';

  @override
  String get syncCrashRecoveryBody =>
      'La dernière session ne s\'est pas terminée correctement. Choisissez quelle version de la cave conserver.';

  @override
  String get syncCrashSendLocal => 'Envoyer mes données locales';

  @override
  String get syncCrashDownloadDrive => 'Repartir depuis le partage';

  @override
  String get syncCrashSendLocalConfirmTitle => 'Envoyer mes données locales ?';

  @override
  String get syncCrashSendLocalConfirmBody =>
      'Votre base locale va remplacer la version partagée. Comme la cave était verrouillée, aucun autre appareil n\'a pu la modifier depuis la dernière synchronisation.';

  @override
  String get syncCrashConfirmSend => 'Envoyer';

  @override
  String get syncCrashDownloadConfirmTitle => 'Repartir depuis le partage ?';

  @override
  String get syncCrashDownloadConfirmBody =>
      'La version partagée va remplacer votre base locale. Toutes vos modifications locales non sauvegardées seront perdues.';

  @override
  String get syncCrashConfirmReplace => 'Remplacer ma base locale';

  @override
  String get syncLockTiersTitle => 'Cave utilisée sur un autre appareil';

  @override
  String get syncLockTiersBody =>
      'Votre cave est actuellement ouverte sur un autre appareil.';

  @override
  String get syncEnterReadOnly => 'Consulter en lecture seule';

  @override
  String get syncAcquireLockFailedTitle => 'Impossible de prendre la main';

  @override
  String get syncAcquireLockFailedBody =>
      'La cave est actuellement verrouillée par un autre appareil.';

  @override
  String get syncStayReadOnly => 'Rester en lecture seule';

  @override
  String get syncErrorTitle => 'Erreur de synchronisation';

  @override
  String get syncAcquireLockTitle => 'Passer en mode écriture ?';

  @override
  String get syncAcquireLockBodyAndroid =>
      'La cave sera verrouillée pendant votre session. Utilisez le bouton Quitter pour sauvegarder vos modifications et libérer le verrou avant de fermer l\'application.';

  @override
  String get syncAcquireLockBodyDesktop =>
      'La cave sera verrouillée pendant toute votre session. Le verrou sera automatiquement libéré et vos modifications synchronisées à la fermeture de l\'application ou via le bouton \"Sauvegarder\".';

  @override
  String get syncPrendreLaMain => 'Prendre la main';

  @override
  String get syncSauvegarder => 'Sauvegarder';

  @override
  String get syncWriteOnboardingTitle => 'Mode écriture activé';

  @override
  String get syncWriteOnboardingBody =>
      'Sur Android, utilisez toujours le bouton Quitter pour sauvegarder vos modifications et libérer le verrou. Sans cela, vos données resteraient uniquement en local et l\'accès en écriture depuis d\'autres appareils serait bloqué.';

  @override
  String get syncWriteOnboardingDontShow => 'Ne plus afficher ce message';

  @override
  String get quitDialogTitle => 'Sauvegarder et quitter ?';

  @override
  String get quitDialogBody =>
      'Vos modifications seront synchronisées et le verrou libéré.';

  @override
  String get quitFailTitle => 'Impossible de sauvegarder';

  @override
  String get quitFailBody =>
      'Les données n\'ont pas pu être synchronisées et le verrou n\'a pas été libéré.\n\nVos modifications restent disponibles localement sur cet appareil. Elles pourront être synchronisées lors d\'une prochaine connexion, sauf si le verrou a été libéré manuellement depuis un autre appareil entre-temps.\n\nTant que le verrou reste actif, l\'accès en écriture depuis d\'autres appareils sera bloqué.';

  @override
  String get quitAnyway => 'Quitter quand même';

  @override
  String get driveSetupMissingTitle => 'Configuration manquante';

  @override
  String get driveSetupMissingBody =>
      'Le fichier de configuration Google Drive est introuvable à côté de l\'application.\n\nSi vous avez installé Cavea via l\'installateur, veuillez le désinstaller puis réinstaller une version récente.\n\nSi vous avez copié l\'application manuellement, consultez le guide de configuration en ligne.';

  @override
  String get driveGuideEnLigne => 'Guide en ligne';

  @override
  String get driveAuthOpening => 'Ouverture de l\'authentification Google…';

  @override
  String driveAuthFailed(String error) {
    return 'Authentification échouée : $error';
  }

  @override
  String get driveMigrateTitle => 'Migrer vers le partage';

  @override
  String get driveMigrateBodyExisting =>
      'Une cave existe déjà dans le partage.\n\nQue souhaitez-vous faire ?';

  @override
  String get driveMigrateBodyNew =>
      'Voulez-vous envoyer votre cave locale vers le partage ?';

  @override
  String get driveDownloadExisting => 'Récupérer la cave depuis le partage';

  @override
  String get driveUploadOverwrite => 'Écraser le partage avec ma cave locale';

  @override
  String get driveSendNew => 'Envoyer ma cave vers le partage';

  @override
  String get driveConfirmOverwriteLocalTitle => 'Écraser la base locale ?';

  @override
  String get driveConfirmOverwriteLocalBody =>
      'Votre base locale sera remplacée par la version partagée. Toutes les données locales non présentes dans le partage seront perdues.';

  @override
  String get driveConfirmOverwriteDriveTitle => 'Écraser la version partagée ?';

  @override
  String get driveConfirmOverwriteDriveBody =>
      'La version partagée sera remplacée par votre base locale. Toutes les données du partage non présentes localement seront perdues.';

  @override
  String get driveDownloading => 'Téléchargement en cours…';

  @override
  String get driveUploading => 'Upload en cours…';

  @override
  String driveDownloadFailed(String error) {
    return 'Téléchargement échoué : $error';
  }

  @override
  String driveUploadFailed(String error) {
    return 'Upload échoué : $error';
  }

  @override
  String get driveModeActivated => 'Mode 2 activé — synchronisation disponible';

  @override
  String get driveDeactivateTitle => 'Revenir en mode local ?';

  @override
  String get driveDeactivateBody =>
      'L\'app passera en mode PC seul.\nVotre cave.db local est conservé tel quel.\nLe fichier Drive n\'est pas supprimé.';

  @override
  String get driveModeDeactivated => 'Mode local activé';

  @override
  String get dropboxSetupMissingTitle =>
      'Fichier de configuration Dropbox manquant';

  @override
  String get dropboxSetupMissingBody =>
      'Créez dropbox_desktop_secrets.json à côté de l\'exécutable ou à la racine du projet, avec les champs app_key et app_secret.';

  @override
  String get dropboxAppKeyLabel => 'App Key';

  @override
  String get settingsSectionLangue => 'Langue';

  @override
  String get settingsLangAuto => 'Automatique';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionCave => 'Emplacement de la cave';

  @override
  String get settingsSectionDefaults => 'Ajout en lot — valeurs par défaut';

  @override
  String get settingsSectionListes => 'Listes de référence';

  @override
  String get settingsSectionSync => 'Mode de synchronisation';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsDbFolder => 'Dossier cave.db';

  @override
  String get settingsDbNotConfigured => '(non configuré)';

  @override
  String get settingsCouleurDefaut => 'Couleur par défaut';

  @override
  String get settingsChoisir => 'Choisir…';

  @override
  String get settingsContenanceDefaut => 'Contenance par défaut';

  @override
  String get settingsRefCouleurs => 'Couleurs';

  @override
  String get settingsRefContenances => 'Contenances';

  @override
  String get settingsRefCrus => 'Crus';

  @override
  String settingsRefCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valeurs',
      one: '1 valeur',
    );
    return '$_temp0';
  }

  @override
  String get settingsRefAddHint => 'Ajouter une valeur…';

  @override
  String get settingsActiverDrive => 'Activer le mode partagé';

  @override
  String get settingsModePartage => 'Mode partagé';

  @override
  String get settingsModeLocalCurrent => 'Mode actuel : PC seul (local)';

  @override
  String settingsModeSyncCurrent(String provider) {
    return 'Mode actuel : $provider actif';
  }

  @override
  String get settingsRevenirLocal => 'Revenir en local';

  @override
  String get settingsChangerFournisseur => 'Changer de fournisseur';

  @override
  String settingsChangerFournisseurBody(String provider) {
    return 'Vous allez déconnecter $provider. Vos données locales seront conservées. Vous pourrez ensuite configurer un autre fournisseur.';
  }

  @override
  String get settingsChoisirFournisseur => 'Choisissez votre fournisseur';

  @override
  String get settingsResetWriteWarning => 'Avertissement mode écriture Android';

  @override
  String get settingsRestartTitle => 'Redémarrage requis';

  @override
  String get settingsRestartBody =>
      'Le dossier de la cave a été modifié.\n\nL\'application doit redémarrer pour utiliser le nouveau chemin.';

  @override
  String get settingsQuitApp => 'Quitter l\'application';

  @override
  String get aboutTitle => 'Cavea';

  @override
  String get aboutSubtitle => 'Gestionnaire de cave à vin personnel';

  @override
  String get aboutButton => 'À propos';

  @override
  String get aboutVersion => 'Version 0.1.0';

  @override
  String get aboutCopyright => '© 2026 Alain Benard\nLicence Apache 2.0';

  @override
  String get aboutConfidentialite => 'Confidentialité';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get stockSearchHint => 'Rechercher : domaine, appellation, millésime…';

  @override
  String get stockFiltresActifs => 'Filtres actifs';

  @override
  String get stockFiltres => 'Filtres';

  @override
  String get stockReinitialiseFiltres => 'Réinitialiser les filtres';

  @override
  String get stockReinitialise => 'Réinitialiser';

  @override
  String get stockMaturityUrgent => 'À boire urgent !';

  @override
  String get stockMaturityOptimal => 'À boire';

  @override
  String get stockMaturityJeune => 'Trop jeune';

  @override
  String get stockFiltresAvances => 'Filtres avancés';

  @override
  String get stockFilterAppellation => 'Appellation';

  @override
  String get stockFilterMillesime => 'Millésime';

  @override
  String get stockFilterTous => 'Tous';

  @override
  String get stockEmptyFiltered =>
      'Aucune bouteille ne correspond aux filtres.';

  @override
  String get stockEmptyTitle => 'Aucune bouteille en stock';

  @override
  String get stockImportCsv => 'Importer un CSV';

  @override
  String stockCountFiltered(int shown, int total) {
    return '$shown / $total bouteilles';
  }

  @override
  String stockCountTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles en stock',
      one: '1 bouteille en stock',
    );
    return '$_temp0';
  }

  @override
  String get tableHeaderDomaine => 'DOMAINE';

  @override
  String get tableHeaderAppellation => 'APPELLATION';

  @override
  String get tableHeaderMillesime => 'MILL.';

  @override
  String get tableHeaderEmplacement => 'EMPLACEMENT';

  @override
  String get tableHeaderGarde => 'GARDE';

  @override
  String get tableHeaderPrix => 'PRIX';

  @override
  String get maturityTropJeune => 'Trop jeune';

  @override
  String get maturityOptimal => 'Optimal';

  @override
  String get maturityUrgent => 'À boire !';

  @override
  String get maturityUrgentDetail => 'À boire — urgent';

  @override
  String get maturityInconnue => 'Maturité inconnue';

  @override
  String gardeDepasse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count ans',
      one: '+1 an',
    );
    return '$_temp0';
  }

  @override
  String gardeEncore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'encore $count ans',
      one: 'encore 1 an',
    );
    return '$_temp0';
  }

  @override
  String gardeDans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count ans',
      one: 'dans 1 an',
    );
    return '$_temp0';
  }

  @override
  String get actionsReadOnly =>
      'Mode lecture seule — modifications indisponibles';

  @override
  String get actionsConsulterFiche => 'Consulter la fiche';

  @override
  String get actionsConsommer => 'Consommer';

  @override
  String get actionsDeplacer => 'Déplacer';

  @override
  String get actionsModifierFiche => 'Modifier la fiche';

  @override
  String get consommerTitle => 'Consommer';

  @override
  String consommerDateLabel(String date) {
    return 'Date de consommation : $date';
  }

  @override
  String get consommerAjouterNote => 'Ajouter une note';

  @override
  String get consommerCommentaireHint => 'Commentaire (optionnel)';

  @override
  String get deplacerTitle => 'Déplacer';

  @override
  String get deplacerEmplacementObligatoire => 'Emplacement obligatoire';

  @override
  String get deplacerFormatError =>
      'Format : \"Niveau1\" ou \"Niveau1 > Niveau2 > …\"\n(lettres, chiffres, espaces ; séparateur \" > \")';

  @override
  String bulkSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles sélectionnées',
      one: '1 bouteille sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get bulkReadOnly => 'Mode lecture seule';

  @override
  String get bulkAnnulerSelection => 'Annuler la sélection';

  @override
  String deplacerBatchTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count bouteilles',
      one: 'Déplacer 1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String consommerBatchTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Consommer $count bouteilles',
      one: 'Consommer 1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddTitle => 'Ajouter des bouteilles';

  @override
  String get bulkAddSectionIdentite => 'Identité';

  @override
  String get bulkAddFieldDomaine => 'Domaine *';

  @override
  String get bulkAddFieldAppellation => 'Appellation *';

  @override
  String get bulkAddFieldMillesime => 'Millésime *';

  @override
  String get bulkAddFieldCouleur => 'Couleur *';

  @override
  String get bulkAddFieldCru => 'Cru';

  @override
  String get bulkAddFieldContenance => 'Contenance';

  @override
  String get bulkAddSectionGarde => 'Garde & prix';

  @override
  String get bulkAddFieldGardeMin => 'Garde min (ans)';

  @override
  String get bulkAddFieldGardeMax => 'Garde max (ans)';

  @override
  String get bulkAddFieldPrix => 'Prix achat (€)';

  @override
  String get bulkAddSectionFournisseur => 'Fournisseur';

  @override
  String get bulkAddFieldFournisseur => 'Nom fournisseur';

  @override
  String get bulkAddFieldFournisseurInfos => 'Infos fournisseur';

  @override
  String get bulkAddFieldProducteur => 'Producteur';

  @override
  String get bulkAddSectionCommentaire => 'Commentaire & date';

  @override
  String get bulkAddFieldCommentaire => 'Commentaire entrée';

  @override
  String bulkAddDateEntreeLabel(String date) {
    return 'Date d\'entrée : $date';
  }

  @override
  String get bulkAddSectionRepartition => 'Répartition';

  @override
  String get bulkAddQuantiteTotal => 'Quantité totale :';

  @override
  String bulkAddAssignees(int assigned, int total) {
    return 'Assignées : $assigned / $total';
  }

  @override
  String get bulkAddAjouterEmplacement => 'Ajouter un emplacement';

  @override
  String bulkAddConfirmer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmer — $count bouteilles',
      one: 'Confirmer — 1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddGardeError => 'Garde min doit être ≤ garde max.';

  @override
  String get bulkAddGardeDialogTitle => 'Garde non renseignée';

  @override
  String get bulkAddGardeDialogBody =>
      'La garde min ou max n\'est pas renseignée.\n\nLa maturité de ces bouteilles ne pourra pas être déterminée dans la vue Stock.\n\nConfirmer quand même sans ces données ?';

  @override
  String get bulkAddRetourGarde => 'Retour — saisir la garde';

  @override
  String get bulkAddConfirmerSansGarde => 'Confirmer sans garde';

  @override
  String get bulkAddCancelled => 'Retour en lecture seule — saisie annulée';

  @override
  String get repartitionQte => 'Qté';

  @override
  String get repartitionSupprimer => 'Supprimer';

  @override
  String get repartitionFormatError =>
      'Format : \"Niveau1\" ou \"Niveau1 > Niveau2\"\n(lettres, chiffres, espaces ; séparateur \" > \")';

  @override
  String get fieldDomaine => 'Domaine';

  @override
  String get fieldAppellation => 'Appellation';

  @override
  String get fieldMillesime => 'Millésime';

  @override
  String get fieldCouleur => 'Couleur';

  @override
  String get fieldCru => 'Cru';

  @override
  String get fieldContenance => 'Contenance';

  @override
  String get fieldEmplacement => 'Emplacement';

  @override
  String get fieldEmplacementRequired => 'Emplacement *';

  @override
  String get fieldCommentaireEntree => 'Commentaire d\'entrée';

  @override
  String get ficheTitle => 'Fiche bouteille';

  @override
  String get ficheNotFound => 'Bouteille introuvable.';

  @override
  String get ficheConsommation => 'Consommation';

  @override
  String get ficheNote => 'Note /10';

  @override
  String get ficheCommentaireDegus => 'Commentaire de dégustation';

  @override
  String get editTitle => 'Modifier la fiche';

  @override
  String get editGardeDialogBody =>
      'La garde min ou max n\'est pas renseignée.\n\nLa maturité de cette bouteille ne pourra pas être déterminée dans la vue Stock.\n\nConfirmer quand même sans ces données ?';

  @override
  String get editRestore => 'Restaurer la valeur initiale';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historySearchHint => 'Rechercher domaine ou appellation…';

  @override
  String get historyEmpty => 'Aucune bouteille consommée.';

  @override
  String historyEmptySearch(String query) {
    return 'Aucun résultat pour \"$query\".';
  }

  @override
  String get historyEmplacementOrigine => 'Emplacement d\'origine';

  @override
  String get historyDateConsommation => 'Date de consommation';

  @override
  String get historyNote => 'Note';

  @override
  String get historyCommentaire => 'Commentaire';

  @override
  String get historyRehabiliter => 'Réhabiliter (remettre en stock)';

  @override
  String get historyRehabiliterTitle => 'Réhabiliter cette bouteille ?';

  @override
  String get historyRehabiliterBody =>
      'La bouteille sera remise en stock à son emplacement d\'origine.\n\nLa note et le commentaire de dégustation seront effacés.';

  @override
  String get historyRehabiliterConfirm => 'Réhabiliter';

  @override
  String get locationsEmpty => 'Aucune bouteille.';

  @override
  String get locationsDirect => 'Directement dans cet emplacement';

  @override
  String locationsBouteilles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String locationsBouteillesAvecPrix(int count, int prix) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '1 bouteille',
    );
    return '$_temp0 ($prix €)';
  }

  @override
  String locationsSansPrix(int count) {
    return ' dont $count sans prix';
  }

  @override
  String get donneesTitle => 'Données';

  @override
  String get importSectionTitle => 'Importer un CSV';

  @override
  String get exportSectionTitle => 'Exporter en CSV';

  @override
  String get exportScope => 'Scope';

  @override
  String get exportStockOnly => 'Stock uniquement';

  @override
  String get exportTout => 'Tout (stock + consommées)';

  @override
  String get exportSeparateur => 'Séparateur';

  @override
  String get exportSeparateurPointVirgule => 'Point-virgule  ;';

  @override
  String get exportSeparateurVirgule => 'Virgule  ,';

  @override
  String get exportSeparateurTabulation => 'Tabulation';

  @override
  String get exportEnCours => 'Export en cours…';

  @override
  String get exportButton => 'Exporter…';

  @override
  String get exportEnregistrer => 'Enregistrer';

  @override
  String get exportPartager => 'Partager…';

  @override
  String get exportDialogTitle => 'Enregistrer le CSV';

  @override
  String exportSaved(String filename) {
    return 'Fichier enregistré : $filename';
  }

  @override
  String get exportSavedAndroid => 'Fichier enregistré';

  @override
  String exportError(String error) {
    return 'Erreur lors de l\'export : $error';
  }

  @override
  String get importPickFileDialog => 'Choisir un fichier CSV';

  @override
  String get importChoisirFichier => 'Choisir un fichier CSV';

  @override
  String get importFormatInfo =>
      'Format attendu : UTF-8, ligne d\'en-tête avec les noms de colonnes.\nColonnes : id, domaine, appellation, millesime, couleur, …';

  @override
  String get importEcraser => 'Écraser les lignes existantes';

  @override
  String get importEcraserSubtitle =>
      'Si décoché, les bouteilles déjà présentes (même UUID) sont ignorées.';

  @override
  String get importEnCours => 'Import en cours…';

  @override
  String get importButton => 'Importer';

  @override
  String get importReadOnly =>
      'Import indisponible — la cave est verrouillée par un autre appareil.';

  @override
  String get importTermine => 'Import terminé';

  @override
  String get importInserted => 'Insérées';

  @override
  String get importUpdated => 'Mises à jour';

  @override
  String get importIgnored => 'Ignorées';

  @override
  String get importErrors => 'Erreurs';

  @override
  String get importMasquerDetail => 'Masquer le détail';

  @override
  String get importVoirDetail => 'Voir le détail des erreurs';

  @override
  String importFileError(String error) {
    return 'Erreur lors de la lecture du fichier : $error';
  }

  @override
  String get setupTitle => 'Configuration de Cavea';

  @override
  String get setupWelcome => 'Bienvenue dans Cavea';

  @override
  String get setupChooseMode => 'Choisissez votre mode de fonctionnement :';

  @override
  String get setupModeLocal => 'PC seul (local)';

  @override
  String get setupModeLocalDesc =>
      'La base de données est stockée localement sur ce PC.';

  @override
  String get setupModeDrive => 'Mode partagé';

  @override
  String get setupModeDriveDesc =>
      'Partagez votre cave entre plusieurs appareils via Google Drive ou Dropbox.';

  @override
  String get setupChooseProvider => 'Choisissez votre fournisseur cloud';

  @override
  String get setupProviderDriveDesc =>
      'Compte Google requis. Nécessite la configuration d\'un projet GCP.';

  @override
  String get setupProviderDropboxDesc =>
      'Compte Dropbox requis. Créez une app sur developer.dropbox.com.';

  @override
  String get setupDropboxTitle => 'Connexion Dropbox';

  @override
  String get setupDropboxDescDesktop =>
      'Choisissez le dossier local pour cave.db (cache de travail), puis connectez votre compte Dropbox.';

  @override
  String get setupDropboxDescAndroid =>
      'Saisissez votre App Key Dropbox, puis connectez-vous.\nLe navigateur va s\'ouvrir — revenez dans Cavea après autorisation.';

  @override
  String get setupDropboxAppKey => 'App Key Dropbox';

  @override
  String get setupConnectDropbox => 'Connecter Dropbox';

  @override
  String get setupDropboxConnectedTitle => 'Dropbox connecté';

  @override
  String get setupDropboxNoCave => 'Aucune cave n\'a été détectée sur Dropbox.';

  @override
  String get setupDropboxCaveFound => 'Une cave a été détectée sur Dropbox.';

  @override
  String get setupModeMobile => 'Mobile seul';

  @override
  String get setupModeMobileDesc => 'Non disponible dans cette version.';

  @override
  String get setupFolderTitle => 'Dossier de la base de données';

  @override
  String get setupFolderDesc =>
      'Choisissez le dossier où sera stocké cave.db.\nCe dossier doit exister.';

  @override
  String get setupFolderPath => 'Chemin du dossier';

  @override
  String get setupParcourir => 'Parcourir';

  @override
  String get setupPickerTitle => 'Choisir le dossier de cave.db';

  @override
  String get setupConfirmTitle => 'Confirmer la configuration';

  @override
  String get setupConfirmMode => 'Mode';

  @override
  String get setupConfirmDb => 'Base de données';

  @override
  String get setupDemarrer => 'Démarrer Cavea';

  @override
  String get setupModifierChemin => 'Modifier le chemin';

  @override
  String get setupDriveTitle => 'Connexion Google Drive';

  @override
  String get setupDriveDescAndroid =>
      'Un cache local de la base sera maintenu dans le stockage privé de l\'application (non accessible depuis l\'explorateur de fichiers Android).\nConnectez votre compte Google pour continuer.';

  @override
  String get setupDriveDescDesktop =>
      'Choisissez d\'abord le dossier local pour cave.db (cache de travail), puis connectez votre compte Google.';

  @override
  String get setupDriveLocalFolder => 'Dossier local (cache)';

  @override
  String get setupDrivePickerTitle => 'Dossier local pour cave.db';

  @override
  String get setupConnectDrive => 'Connecter Google Drive';

  @override
  String get setupFolderRequired => 'Choisissez un dossier local valide.';

  @override
  String get setupDriveConnectedTitle => 'Google Drive connecté';

  @override
  String get setupNoCave => 'Aucune cave n\'a été détectée sur Google Drive.';

  @override
  String get setupCreerCave => 'Créer une cave vide';

  @override
  String get setupCaveFound => 'Une cave a été détectée sur Google Drive.';

  @override
  String get setupJoinReadOnly => 'Rejoindre la cave existante (lecture seule)';

  @override
  String get setupJoin => 'Rejoindre la cave existante';

  @override
  String get setupOverwriteButton => 'Écraser par une nouvelle cave vide';

  @override
  String get setupOverwriteLocked =>
      'Impossible d\'écraser : la cave est verrouillée par un autre appareil';

  @override
  String get setupOverwriteTitle => 'Écraser la cave existante ?';

  @override
  String get setupOverwriteBody =>
      'Cette action supprimera définitivement cave.db du partage et le remplacera par une base vide. Toutes les données actuelles seront perdues.';

  @override
  String get setupFinalConfirmTitle => 'Confirmation finale';

  @override
  String get setupFinalConfirmBody =>
      'Cette opération est IRRÉVERSIBLE.\n\nLa cave existante sera définitivement effacée. Confirmez-vous vouloir créer une nouvelle cave vide ?';

  @override
  String get setupEcraserDefinitivement => 'Oui, écraser définitivement';

  @override
  String setupEchec(String error) {
    return 'Échec : $error';
  }

  @override
  String get csvHeaderId => 'id';

  @override
  String get csvHeaderDomaine => 'Domaine';

  @override
  String get csvHeaderAppellation => 'Appellation';

  @override
  String get csvHeaderMillesime => 'Millésime';

  @override
  String get csvHeaderCouleur => 'Couleur';

  @override
  String get csvHeaderCru => 'Cru';

  @override
  String get csvHeaderContenance => 'Contenance';

  @override
  String get csvHeaderEmplacement => 'Emplacement';

  @override
  String get csvHeaderDateEntree => 'Date entrée';

  @override
  String get csvHeaderDateSortie => 'Date sortie';

  @override
  String get csvHeaderPrixAchat => 'Prix achat';

  @override
  String get csvHeaderGardeMin => 'Garde min';

  @override
  String get csvHeaderGardeMax => 'Garde max';

  @override
  String get csvHeaderCommentaireEntree => 'Commentaire entrée';

  @override
  String get csvHeaderNoteDegus => 'Note dégustation';

  @override
  String get csvHeaderCommentaireDegus => 'Commentaire dégustation';

  @override
  String get csvHeaderFournisseurNom => 'Fournisseur nom';

  @override
  String get csvHeaderFournisseurInfos => 'Fournisseur infos';

  @override
  String get csvHeaderProducteur => 'Producteur';

  @override
  String get csvHeaderUpdatedAt => 'Mis à jour le';
}
