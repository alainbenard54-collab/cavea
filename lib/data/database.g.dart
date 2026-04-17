// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BouteillesTable extends Bouteilles
    with TableInfo<$BouteillesTable, Bouteille> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BouteillesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domaineMeta = const VerificationMeta(
    'domaine',
  );
  @override
  late final GeneratedColumn<String> domaine = GeneratedColumn<String>(
    'domaine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appellationMeta = const VerificationMeta(
    'appellation',
  );
  @override
  late final GeneratedColumn<String> appellation = GeneratedColumn<String>(
    'appellation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _millesimeMeta = const VerificationMeta(
    'millesime',
  );
  @override
  late final GeneratedColumn<int> millesime = GeneratedColumn<int>(
    'millesime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _couleurMeta = const VerificationMeta(
    'couleur',
  );
  @override
  late final GeneratedColumn<String> couleur = GeneratedColumn<String>(
    'couleur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cruMeta = const VerificationMeta('cru');
  @override
  late final GeneratedColumn<String> cru = GeneratedColumn<String>(
    'cru',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contenanceMeta = const VerificationMeta(
    'contenance',
  );
  @override
  late final GeneratedColumn<String> contenance = GeneratedColumn<String>(
    'contenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emplacementMeta = const VerificationMeta(
    'emplacement',
  );
  @override
  late final GeneratedColumn<String> emplacement = GeneratedColumn<String>(
    'emplacement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateEntreeMeta = const VerificationMeta(
    'dateEntree',
  );
  @override
  late final GeneratedColumn<String> dateEntree = GeneratedColumn<String>(
    'date_entree',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateSortieMeta = const VerificationMeta(
    'dateSortie',
  );
  @override
  late final GeneratedColumn<String> dateSortie = GeneratedColumn<String>(
    'date_sortie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prixAchatMeta = const VerificationMeta(
    'prixAchat',
  );
  @override
  late final GeneratedColumn<double> prixAchat = GeneratedColumn<double>(
    'prix_achat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gardeMinMeta = const VerificationMeta(
    'gardeMin',
  );
  @override
  late final GeneratedColumn<int> gardeMin = GeneratedColumn<int>(
    'garde_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gardeMaxMeta = const VerificationMeta(
    'gardeMax',
  );
  @override
  late final GeneratedColumn<int> gardeMax = GeneratedColumn<int>(
    'garde_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireEntreeMeta = const VerificationMeta(
    'commentaireEntree',
  );
  @override
  late final GeneratedColumn<String> commentaireEntree =
      GeneratedColumn<String>(
        'commentaire_entree',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteDegusMeta = const VerificationMeta(
    'noteDegus',
  );
  @override
  late final GeneratedColumn<double> noteDegus = GeneratedColumn<double>(
    'note_degus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireDegusMeta = const VerificationMeta(
    'commentaireDegus',
  );
  @override
  late final GeneratedColumn<String> commentaireDegus = GeneratedColumn<String>(
    'commentaire_degus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fournisseurNomMeta = const VerificationMeta(
    'fournisseurNom',
  );
  @override
  late final GeneratedColumn<String> fournisseurNom = GeneratedColumn<String>(
    'fournisseur_nom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fournisseurInfosMeta = const VerificationMeta(
    'fournisseurInfos',
  );
  @override
  late final GeneratedColumn<String> fournisseurInfos = GeneratedColumn<String>(
    'fournisseur_infos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _producteurMeta = const VerificationMeta(
    'producteur',
  );
  @override
  late final GeneratedColumn<String> producteur = GeneratedColumn<String>(
    'producteur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    domaine,
    appellation,
    millesime,
    couleur,
    cru,
    contenance,
    emplacement,
    dateEntree,
    dateSortie,
    prixAchat,
    gardeMin,
    gardeMax,
    commentaireEntree,
    noteDegus,
    commentaireDegus,
    fournisseurNom,
    fournisseurInfos,
    producteur,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bouteilles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bouteille> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('domaine')) {
      context.handle(
        _domaineMeta,
        domaine.isAcceptableOrUnknown(data['domaine']!, _domaineMeta),
      );
    } else if (isInserting) {
      context.missing(_domaineMeta);
    }
    if (data.containsKey('appellation')) {
      context.handle(
        _appellationMeta,
        appellation.isAcceptableOrUnknown(
          data['appellation']!,
          _appellationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appellationMeta);
    }
    if (data.containsKey('millesime')) {
      context.handle(
        _millesimeMeta,
        millesime.isAcceptableOrUnknown(data['millesime']!, _millesimeMeta),
      );
    } else if (isInserting) {
      context.missing(_millesimeMeta);
    }
    if (data.containsKey('couleur')) {
      context.handle(
        _couleurMeta,
        couleur.isAcceptableOrUnknown(data['couleur']!, _couleurMeta),
      );
    } else if (isInserting) {
      context.missing(_couleurMeta);
    }
    if (data.containsKey('cru')) {
      context.handle(
        _cruMeta,
        cru.isAcceptableOrUnknown(data['cru']!, _cruMeta),
      );
    }
    if (data.containsKey('contenance')) {
      context.handle(
        _contenanceMeta,
        contenance.isAcceptableOrUnknown(data['contenance']!, _contenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_contenanceMeta);
    }
    if (data.containsKey('emplacement')) {
      context.handle(
        _emplacementMeta,
        emplacement.isAcceptableOrUnknown(
          data['emplacement']!,
          _emplacementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_emplacementMeta);
    }
    if (data.containsKey('date_entree')) {
      context.handle(
        _dateEntreeMeta,
        dateEntree.isAcceptableOrUnknown(data['date_entree']!, _dateEntreeMeta),
      );
    } else if (isInserting) {
      context.missing(_dateEntreeMeta);
    }
    if (data.containsKey('date_sortie')) {
      context.handle(
        _dateSortieMeta,
        dateSortie.isAcceptableOrUnknown(data['date_sortie']!, _dateSortieMeta),
      );
    }
    if (data.containsKey('prix_achat')) {
      context.handle(
        _prixAchatMeta,
        prixAchat.isAcceptableOrUnknown(data['prix_achat']!, _prixAchatMeta),
      );
    }
    if (data.containsKey('garde_min')) {
      context.handle(
        _gardeMinMeta,
        gardeMin.isAcceptableOrUnknown(data['garde_min']!, _gardeMinMeta),
      );
    }
    if (data.containsKey('garde_max')) {
      context.handle(
        _gardeMaxMeta,
        gardeMax.isAcceptableOrUnknown(data['garde_max']!, _gardeMaxMeta),
      );
    }
    if (data.containsKey('commentaire_entree')) {
      context.handle(
        _commentaireEntreeMeta,
        commentaireEntree.isAcceptableOrUnknown(
          data['commentaire_entree']!,
          _commentaireEntreeMeta,
        ),
      );
    }
    if (data.containsKey('note_degus')) {
      context.handle(
        _noteDegusMeta,
        noteDegus.isAcceptableOrUnknown(data['note_degus']!, _noteDegusMeta),
      );
    }
    if (data.containsKey('commentaire_degus')) {
      context.handle(
        _commentaireDegusMeta,
        commentaireDegus.isAcceptableOrUnknown(
          data['commentaire_degus']!,
          _commentaireDegusMeta,
        ),
      );
    }
    if (data.containsKey('fournisseur_nom')) {
      context.handle(
        _fournisseurNomMeta,
        fournisseurNom.isAcceptableOrUnknown(
          data['fournisseur_nom']!,
          _fournisseurNomMeta,
        ),
      );
    }
    if (data.containsKey('fournisseur_infos')) {
      context.handle(
        _fournisseurInfosMeta,
        fournisseurInfos.isAcceptableOrUnknown(
          data['fournisseur_infos']!,
          _fournisseurInfosMeta,
        ),
      );
    }
    if (data.containsKey('producteur')) {
      context.handle(
        _producteurMeta,
        producteur.isAcceptableOrUnknown(data['producteur']!, _producteurMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bouteille map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bouteille(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      domaine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domaine'],
      )!,
      appellation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appellation'],
      )!,
      millesime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}millesime'],
      )!,
      couleur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couleur'],
      )!,
      cru: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cru'],
      ),
      contenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contenance'],
      )!,
      emplacement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emplacement'],
      )!,
      dateEntree: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_entree'],
      )!,
      dateSortie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_sortie'],
      ),
      prixAchat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_achat'],
      ),
      gardeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garde_min'],
      ),
      gardeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garde_max'],
      ),
      commentaireEntree: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire_entree'],
      ),
      noteDegus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}note_degus'],
      ),
      commentaireDegus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire_degus'],
      ),
      fournisseurNom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fournisseur_nom'],
      ),
      fournisseurInfos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fournisseur_infos'],
      ),
      producteur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producteur'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BouteillesTable createAlias(String alias) {
    return $BouteillesTable(attachedDatabase, alias);
  }
}

class Bouteille extends DataClass implements Insertable<Bouteille> {
  final String id;
  final String domaine;
  final String appellation;
  final int millesime;
  final String couleur;
  final String? cru;
  final String contenance;
  final String emplacement;
  final String dateEntree;
  final String? dateSortie;
  final double? prixAchat;
  final int? gardeMin;
  final int? gardeMax;
  final String? commentaireEntree;
  final double? noteDegus;
  final String? commentaireDegus;
  final String? fournisseurNom;
  final String? fournisseurInfos;
  final String? producteur;
  final String updatedAt;
  const Bouteille({
    required this.id,
    required this.domaine,
    required this.appellation,
    required this.millesime,
    required this.couleur,
    this.cru,
    required this.contenance,
    required this.emplacement,
    required this.dateEntree,
    this.dateSortie,
    this.prixAchat,
    this.gardeMin,
    this.gardeMax,
    this.commentaireEntree,
    this.noteDegus,
    this.commentaireDegus,
    this.fournisseurNom,
    this.fournisseurInfos,
    this.producteur,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['domaine'] = Variable<String>(domaine);
    map['appellation'] = Variable<String>(appellation);
    map['millesime'] = Variable<int>(millesime);
    map['couleur'] = Variable<String>(couleur);
    if (!nullToAbsent || cru != null) {
      map['cru'] = Variable<String>(cru);
    }
    map['contenance'] = Variable<String>(contenance);
    map['emplacement'] = Variable<String>(emplacement);
    map['date_entree'] = Variable<String>(dateEntree);
    if (!nullToAbsent || dateSortie != null) {
      map['date_sortie'] = Variable<String>(dateSortie);
    }
    if (!nullToAbsent || prixAchat != null) {
      map['prix_achat'] = Variable<double>(prixAchat);
    }
    if (!nullToAbsent || gardeMin != null) {
      map['garde_min'] = Variable<int>(gardeMin);
    }
    if (!nullToAbsent || gardeMax != null) {
      map['garde_max'] = Variable<int>(gardeMax);
    }
    if (!nullToAbsent || commentaireEntree != null) {
      map['commentaire_entree'] = Variable<String>(commentaireEntree);
    }
    if (!nullToAbsent || noteDegus != null) {
      map['note_degus'] = Variable<double>(noteDegus);
    }
    if (!nullToAbsent || commentaireDegus != null) {
      map['commentaire_degus'] = Variable<String>(commentaireDegus);
    }
    if (!nullToAbsent || fournisseurNom != null) {
      map['fournisseur_nom'] = Variable<String>(fournisseurNom);
    }
    if (!nullToAbsent || fournisseurInfos != null) {
      map['fournisseur_infos'] = Variable<String>(fournisseurInfos);
    }
    if (!nullToAbsent || producteur != null) {
      map['producteur'] = Variable<String>(producteur);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  BouteillesCompanion toCompanion(bool nullToAbsent) {
    return BouteillesCompanion(
      id: Value(id),
      domaine: Value(domaine),
      appellation: Value(appellation),
      millesime: Value(millesime),
      couleur: Value(couleur),
      cru: cru == null && nullToAbsent ? const Value.absent() : Value(cru),
      contenance: Value(contenance),
      emplacement: Value(emplacement),
      dateEntree: Value(dateEntree),
      dateSortie: dateSortie == null && nullToAbsent
          ? const Value.absent()
          : Value(dateSortie),
      prixAchat: prixAchat == null && nullToAbsent
          ? const Value.absent()
          : Value(prixAchat),
      gardeMin: gardeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeMin),
      gardeMax: gardeMax == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeMax),
      commentaireEntree: commentaireEntree == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaireEntree),
      noteDegus: noteDegus == null && nullToAbsent
          ? const Value.absent()
          : Value(noteDegus),
      commentaireDegus: commentaireDegus == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaireDegus),
      fournisseurNom: fournisseurNom == null && nullToAbsent
          ? const Value.absent()
          : Value(fournisseurNom),
      fournisseurInfos: fournisseurInfos == null && nullToAbsent
          ? const Value.absent()
          : Value(fournisseurInfos),
      producteur: producteur == null && nullToAbsent
          ? const Value.absent()
          : Value(producteur),
      updatedAt: Value(updatedAt),
    );
  }

  factory Bouteille.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bouteille(
      id: serializer.fromJson<String>(json['id']),
      domaine: serializer.fromJson<String>(json['domaine']),
      appellation: serializer.fromJson<String>(json['appellation']),
      millesime: serializer.fromJson<int>(json['millesime']),
      couleur: serializer.fromJson<String>(json['couleur']),
      cru: serializer.fromJson<String?>(json['cru']),
      contenance: serializer.fromJson<String>(json['contenance']),
      emplacement: serializer.fromJson<String>(json['emplacement']),
      dateEntree: serializer.fromJson<String>(json['dateEntree']),
      dateSortie: serializer.fromJson<String?>(json['dateSortie']),
      prixAchat: serializer.fromJson<double?>(json['prixAchat']),
      gardeMin: serializer.fromJson<int?>(json['gardeMin']),
      gardeMax: serializer.fromJson<int?>(json['gardeMax']),
      commentaireEntree: serializer.fromJson<String?>(
        json['commentaireEntree'],
      ),
      noteDegus: serializer.fromJson<double?>(json['noteDegus']),
      commentaireDegus: serializer.fromJson<String?>(json['commentaireDegus']),
      fournisseurNom: serializer.fromJson<String?>(json['fournisseurNom']),
      fournisseurInfos: serializer.fromJson<String?>(json['fournisseurInfos']),
      producteur: serializer.fromJson<String?>(json['producteur']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'domaine': serializer.toJson<String>(domaine),
      'appellation': serializer.toJson<String>(appellation),
      'millesime': serializer.toJson<int>(millesime),
      'couleur': serializer.toJson<String>(couleur),
      'cru': serializer.toJson<String?>(cru),
      'contenance': serializer.toJson<String>(contenance),
      'emplacement': serializer.toJson<String>(emplacement),
      'dateEntree': serializer.toJson<String>(dateEntree),
      'dateSortie': serializer.toJson<String?>(dateSortie),
      'prixAchat': serializer.toJson<double?>(prixAchat),
      'gardeMin': serializer.toJson<int?>(gardeMin),
      'gardeMax': serializer.toJson<int?>(gardeMax),
      'commentaireEntree': serializer.toJson<String?>(commentaireEntree),
      'noteDegus': serializer.toJson<double?>(noteDegus),
      'commentaireDegus': serializer.toJson<String?>(commentaireDegus),
      'fournisseurNom': serializer.toJson<String?>(fournisseurNom),
      'fournisseurInfos': serializer.toJson<String?>(fournisseurInfos),
      'producteur': serializer.toJson<String?>(producteur),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Bouteille copyWith({
    String? id,
    String? domaine,
    String? appellation,
    int? millesime,
    String? couleur,
    Value<String?> cru = const Value.absent(),
    String? contenance,
    String? emplacement,
    String? dateEntree,
    Value<String?> dateSortie = const Value.absent(),
    Value<double?> prixAchat = const Value.absent(),
    Value<int?> gardeMin = const Value.absent(),
    Value<int?> gardeMax = const Value.absent(),
    Value<String?> commentaireEntree = const Value.absent(),
    Value<double?> noteDegus = const Value.absent(),
    Value<String?> commentaireDegus = const Value.absent(),
    Value<String?> fournisseurNom = const Value.absent(),
    Value<String?> fournisseurInfos = const Value.absent(),
    Value<String?> producteur = const Value.absent(),
    String? updatedAt,
  }) => Bouteille(
    id: id ?? this.id,
    domaine: domaine ?? this.domaine,
    appellation: appellation ?? this.appellation,
    millesime: millesime ?? this.millesime,
    couleur: couleur ?? this.couleur,
    cru: cru.present ? cru.value : this.cru,
    contenance: contenance ?? this.contenance,
    emplacement: emplacement ?? this.emplacement,
    dateEntree: dateEntree ?? this.dateEntree,
    dateSortie: dateSortie.present ? dateSortie.value : this.dateSortie,
    prixAchat: prixAchat.present ? prixAchat.value : this.prixAchat,
    gardeMin: gardeMin.present ? gardeMin.value : this.gardeMin,
    gardeMax: gardeMax.present ? gardeMax.value : this.gardeMax,
    commentaireEntree: commentaireEntree.present
        ? commentaireEntree.value
        : this.commentaireEntree,
    noteDegus: noteDegus.present ? noteDegus.value : this.noteDegus,
    commentaireDegus: commentaireDegus.present
        ? commentaireDegus.value
        : this.commentaireDegus,
    fournisseurNom: fournisseurNom.present
        ? fournisseurNom.value
        : this.fournisseurNom,
    fournisseurInfos: fournisseurInfos.present
        ? fournisseurInfos.value
        : this.fournisseurInfos,
    producteur: producteur.present ? producteur.value : this.producteur,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Bouteille copyWithCompanion(BouteillesCompanion data) {
    return Bouteille(
      id: data.id.present ? data.id.value : this.id,
      domaine: data.domaine.present ? data.domaine.value : this.domaine,
      appellation: data.appellation.present
          ? data.appellation.value
          : this.appellation,
      millesime: data.millesime.present ? data.millesime.value : this.millesime,
      couleur: data.couleur.present ? data.couleur.value : this.couleur,
      cru: data.cru.present ? data.cru.value : this.cru,
      contenance: data.contenance.present
          ? data.contenance.value
          : this.contenance,
      emplacement: data.emplacement.present
          ? data.emplacement.value
          : this.emplacement,
      dateEntree: data.dateEntree.present
          ? data.dateEntree.value
          : this.dateEntree,
      dateSortie: data.dateSortie.present
          ? data.dateSortie.value
          : this.dateSortie,
      prixAchat: data.prixAchat.present ? data.prixAchat.value : this.prixAchat,
      gardeMin: data.gardeMin.present ? data.gardeMin.value : this.gardeMin,
      gardeMax: data.gardeMax.present ? data.gardeMax.value : this.gardeMax,
      commentaireEntree: data.commentaireEntree.present
          ? data.commentaireEntree.value
          : this.commentaireEntree,
      noteDegus: data.noteDegus.present ? data.noteDegus.value : this.noteDegus,
      commentaireDegus: data.commentaireDegus.present
          ? data.commentaireDegus.value
          : this.commentaireDegus,
      fournisseurNom: data.fournisseurNom.present
          ? data.fournisseurNom.value
          : this.fournisseurNom,
      fournisseurInfos: data.fournisseurInfos.present
          ? data.fournisseurInfos.value
          : this.fournisseurInfos,
      producteur: data.producteur.present
          ? data.producteur.value
          : this.producteur,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bouteille(')
          ..write('id: $id, ')
          ..write('domaine: $domaine, ')
          ..write('appellation: $appellation, ')
          ..write('millesime: $millesime, ')
          ..write('couleur: $couleur, ')
          ..write('cru: $cru, ')
          ..write('contenance: $contenance, ')
          ..write('emplacement: $emplacement, ')
          ..write('dateEntree: $dateEntree, ')
          ..write('dateSortie: $dateSortie, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('gardeMin: $gardeMin, ')
          ..write('gardeMax: $gardeMax, ')
          ..write('commentaireEntree: $commentaireEntree, ')
          ..write('noteDegus: $noteDegus, ')
          ..write('commentaireDegus: $commentaireDegus, ')
          ..write('fournisseurNom: $fournisseurNom, ')
          ..write('fournisseurInfos: $fournisseurInfos, ')
          ..write('producteur: $producteur, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    domaine,
    appellation,
    millesime,
    couleur,
    cru,
    contenance,
    emplacement,
    dateEntree,
    dateSortie,
    prixAchat,
    gardeMin,
    gardeMax,
    commentaireEntree,
    noteDegus,
    commentaireDegus,
    fournisseurNom,
    fournisseurInfos,
    producteur,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bouteille &&
          other.id == this.id &&
          other.domaine == this.domaine &&
          other.appellation == this.appellation &&
          other.millesime == this.millesime &&
          other.couleur == this.couleur &&
          other.cru == this.cru &&
          other.contenance == this.contenance &&
          other.emplacement == this.emplacement &&
          other.dateEntree == this.dateEntree &&
          other.dateSortie == this.dateSortie &&
          other.prixAchat == this.prixAchat &&
          other.gardeMin == this.gardeMin &&
          other.gardeMax == this.gardeMax &&
          other.commentaireEntree == this.commentaireEntree &&
          other.noteDegus == this.noteDegus &&
          other.commentaireDegus == this.commentaireDegus &&
          other.fournisseurNom == this.fournisseurNom &&
          other.fournisseurInfos == this.fournisseurInfos &&
          other.producteur == this.producteur &&
          other.updatedAt == this.updatedAt);
}

class BouteillesCompanion extends UpdateCompanion<Bouteille> {
  final Value<String> id;
  final Value<String> domaine;
  final Value<String> appellation;
  final Value<int> millesime;
  final Value<String> couleur;
  final Value<String?> cru;
  final Value<String> contenance;
  final Value<String> emplacement;
  final Value<String> dateEntree;
  final Value<String?> dateSortie;
  final Value<double?> prixAchat;
  final Value<int?> gardeMin;
  final Value<int?> gardeMax;
  final Value<String?> commentaireEntree;
  final Value<double?> noteDegus;
  final Value<String?> commentaireDegus;
  final Value<String?> fournisseurNom;
  final Value<String?> fournisseurInfos;
  final Value<String?> producteur;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const BouteillesCompanion({
    this.id = const Value.absent(),
    this.domaine = const Value.absent(),
    this.appellation = const Value.absent(),
    this.millesime = const Value.absent(),
    this.couleur = const Value.absent(),
    this.cru = const Value.absent(),
    this.contenance = const Value.absent(),
    this.emplacement = const Value.absent(),
    this.dateEntree = const Value.absent(),
    this.dateSortie = const Value.absent(),
    this.prixAchat = const Value.absent(),
    this.gardeMin = const Value.absent(),
    this.gardeMax = const Value.absent(),
    this.commentaireEntree = const Value.absent(),
    this.noteDegus = const Value.absent(),
    this.commentaireDegus = const Value.absent(),
    this.fournisseurNom = const Value.absent(),
    this.fournisseurInfos = const Value.absent(),
    this.producteur = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BouteillesCompanion.insert({
    required String id,
    required String domaine,
    required String appellation,
    required int millesime,
    required String couleur,
    this.cru = const Value.absent(),
    required String contenance,
    required String emplacement,
    required String dateEntree,
    this.dateSortie = const Value.absent(),
    this.prixAchat = const Value.absent(),
    this.gardeMin = const Value.absent(),
    this.gardeMax = const Value.absent(),
    this.commentaireEntree = const Value.absent(),
    this.noteDegus = const Value.absent(),
    this.commentaireDegus = const Value.absent(),
    this.fournisseurNom = const Value.absent(),
    this.fournisseurInfos = const Value.absent(),
    this.producteur = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       domaine = Value(domaine),
       appellation = Value(appellation),
       millesime = Value(millesime),
       couleur = Value(couleur),
       contenance = Value(contenance),
       emplacement = Value(emplacement),
       dateEntree = Value(dateEntree),
       updatedAt = Value(updatedAt);
  static Insertable<Bouteille> custom({
    Expression<String>? id,
    Expression<String>? domaine,
    Expression<String>? appellation,
    Expression<int>? millesime,
    Expression<String>? couleur,
    Expression<String>? cru,
    Expression<String>? contenance,
    Expression<String>? emplacement,
    Expression<String>? dateEntree,
    Expression<String>? dateSortie,
    Expression<double>? prixAchat,
    Expression<int>? gardeMin,
    Expression<int>? gardeMax,
    Expression<String>? commentaireEntree,
    Expression<double>? noteDegus,
    Expression<String>? commentaireDegus,
    Expression<String>? fournisseurNom,
    Expression<String>? fournisseurInfos,
    Expression<String>? producteur,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (domaine != null) 'domaine': domaine,
      if (appellation != null) 'appellation': appellation,
      if (millesime != null) 'millesime': millesime,
      if (couleur != null) 'couleur': couleur,
      if (cru != null) 'cru': cru,
      if (contenance != null) 'contenance': contenance,
      if (emplacement != null) 'emplacement': emplacement,
      if (dateEntree != null) 'date_entree': dateEntree,
      if (dateSortie != null) 'date_sortie': dateSortie,
      if (prixAchat != null) 'prix_achat': prixAchat,
      if (gardeMin != null) 'garde_min': gardeMin,
      if (gardeMax != null) 'garde_max': gardeMax,
      if (commentaireEntree != null) 'commentaire_entree': commentaireEntree,
      if (noteDegus != null) 'note_degus': noteDegus,
      if (commentaireDegus != null) 'commentaire_degus': commentaireDegus,
      if (fournisseurNom != null) 'fournisseur_nom': fournisseurNom,
      if (fournisseurInfos != null) 'fournisseur_infos': fournisseurInfos,
      if (producteur != null) 'producteur': producteur,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BouteillesCompanion copyWith({
    Value<String>? id,
    Value<String>? domaine,
    Value<String>? appellation,
    Value<int>? millesime,
    Value<String>? couleur,
    Value<String?>? cru,
    Value<String>? contenance,
    Value<String>? emplacement,
    Value<String>? dateEntree,
    Value<String?>? dateSortie,
    Value<double?>? prixAchat,
    Value<int?>? gardeMin,
    Value<int?>? gardeMax,
    Value<String?>? commentaireEntree,
    Value<double?>? noteDegus,
    Value<String?>? commentaireDegus,
    Value<String?>? fournisseurNom,
    Value<String?>? fournisseurInfos,
    Value<String?>? producteur,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return BouteillesCompanion(
      id: id ?? this.id,
      domaine: domaine ?? this.domaine,
      appellation: appellation ?? this.appellation,
      millesime: millesime ?? this.millesime,
      couleur: couleur ?? this.couleur,
      cru: cru ?? this.cru,
      contenance: contenance ?? this.contenance,
      emplacement: emplacement ?? this.emplacement,
      dateEntree: dateEntree ?? this.dateEntree,
      dateSortie: dateSortie ?? this.dateSortie,
      prixAchat: prixAchat ?? this.prixAchat,
      gardeMin: gardeMin ?? this.gardeMin,
      gardeMax: gardeMax ?? this.gardeMax,
      commentaireEntree: commentaireEntree ?? this.commentaireEntree,
      noteDegus: noteDegus ?? this.noteDegus,
      commentaireDegus: commentaireDegus ?? this.commentaireDegus,
      fournisseurNom: fournisseurNom ?? this.fournisseurNom,
      fournisseurInfos: fournisseurInfos ?? this.fournisseurInfos,
      producteur: producteur ?? this.producteur,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (domaine.present) {
      map['domaine'] = Variable<String>(domaine.value);
    }
    if (appellation.present) {
      map['appellation'] = Variable<String>(appellation.value);
    }
    if (millesime.present) {
      map['millesime'] = Variable<int>(millesime.value);
    }
    if (couleur.present) {
      map['couleur'] = Variable<String>(couleur.value);
    }
    if (cru.present) {
      map['cru'] = Variable<String>(cru.value);
    }
    if (contenance.present) {
      map['contenance'] = Variable<String>(contenance.value);
    }
    if (emplacement.present) {
      map['emplacement'] = Variable<String>(emplacement.value);
    }
    if (dateEntree.present) {
      map['date_entree'] = Variable<String>(dateEntree.value);
    }
    if (dateSortie.present) {
      map['date_sortie'] = Variable<String>(dateSortie.value);
    }
    if (prixAchat.present) {
      map['prix_achat'] = Variable<double>(prixAchat.value);
    }
    if (gardeMin.present) {
      map['garde_min'] = Variable<int>(gardeMin.value);
    }
    if (gardeMax.present) {
      map['garde_max'] = Variable<int>(gardeMax.value);
    }
    if (commentaireEntree.present) {
      map['commentaire_entree'] = Variable<String>(commentaireEntree.value);
    }
    if (noteDegus.present) {
      map['note_degus'] = Variable<double>(noteDegus.value);
    }
    if (commentaireDegus.present) {
      map['commentaire_degus'] = Variable<String>(commentaireDegus.value);
    }
    if (fournisseurNom.present) {
      map['fournisseur_nom'] = Variable<String>(fournisseurNom.value);
    }
    if (fournisseurInfos.present) {
      map['fournisseur_infos'] = Variable<String>(fournisseurInfos.value);
    }
    if (producteur.present) {
      map['producteur'] = Variable<String>(producteur.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BouteillesCompanion(')
          ..write('id: $id, ')
          ..write('domaine: $domaine, ')
          ..write('appellation: $appellation, ')
          ..write('millesime: $millesime, ')
          ..write('couleur: $couleur, ')
          ..write('cru: $cru, ')
          ..write('contenance: $contenance, ')
          ..write('emplacement: $emplacement, ')
          ..write('dateEntree: $dateEntree, ')
          ..write('dateSortie: $dateSortie, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('gardeMin: $gardeMin, ')
          ..write('gardeMax: $gardeMax, ')
          ..write('commentaireEntree: $commentaireEntree, ')
          ..write('noteDegus: $noteDegus, ')
          ..write('commentaireDegus: $commentaireDegus, ')
          ..write('fournisseurNom: $fournisseurNom, ')
          ..write('fournisseurInfos: $fournisseurInfos, ')
          ..write('producteur: $producteur, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BouteillesTable bouteilles = $BouteillesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bouteilles];
}

typedef $$BouteillesTableCreateCompanionBuilder =
    BouteillesCompanion Function({
      required String id,
      required String domaine,
      required String appellation,
      required int millesime,
      required String couleur,
      Value<String?> cru,
      required String contenance,
      required String emplacement,
      required String dateEntree,
      Value<String?> dateSortie,
      Value<double?> prixAchat,
      Value<int?> gardeMin,
      Value<int?> gardeMax,
      Value<String?> commentaireEntree,
      Value<double?> noteDegus,
      Value<String?> commentaireDegus,
      Value<String?> fournisseurNom,
      Value<String?> fournisseurInfos,
      Value<String?> producteur,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$BouteillesTableUpdateCompanionBuilder =
    BouteillesCompanion Function({
      Value<String> id,
      Value<String> domaine,
      Value<String> appellation,
      Value<int> millesime,
      Value<String> couleur,
      Value<String?> cru,
      Value<String> contenance,
      Value<String> emplacement,
      Value<String> dateEntree,
      Value<String?> dateSortie,
      Value<double?> prixAchat,
      Value<int?> gardeMin,
      Value<int?> gardeMax,
      Value<String?> commentaireEntree,
      Value<double?> noteDegus,
      Value<String?> commentaireDegus,
      Value<String?> fournisseurNom,
      Value<String?> fournisseurInfos,
      Value<String?> producteur,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$BouteillesTableFilterComposer
    extends Composer<_$AppDatabase, $BouteillesTable> {
  $$BouteillesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domaine => $composableBuilder(
    column: $table.domaine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get millesime => $composableBuilder(
    column: $table.millesime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get couleur => $composableBuilder(
    column: $table.couleur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cru => $composableBuilder(
    column: $table.cru,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contenance => $composableBuilder(
    column: $table.contenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emplacement => $composableBuilder(
    column: $table.emplacement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateEntree => $composableBuilder(
    column: $table.dateEntree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateSortie => $composableBuilder(
    column: $table.dateSortie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prixAchat => $composableBuilder(
    column: $table.prixAchat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gardeMin => $composableBuilder(
    column: $table.gardeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gardeMax => $composableBuilder(
    column: $table.gardeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentaireEntree => $composableBuilder(
    column: $table.commentaireEntree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get noteDegus => $composableBuilder(
    column: $table.noteDegus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentaireDegus => $composableBuilder(
    column: $table.commentaireDegus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fournisseurNom => $composableBuilder(
    column: $table.fournisseurNom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fournisseurInfos => $composableBuilder(
    column: $table.fournisseurInfos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BouteillesTableOrderingComposer
    extends Composer<_$AppDatabase, $BouteillesTable> {
  $$BouteillesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domaine => $composableBuilder(
    column: $table.domaine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get millesime => $composableBuilder(
    column: $table.millesime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get couleur => $composableBuilder(
    column: $table.couleur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cru => $composableBuilder(
    column: $table.cru,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contenance => $composableBuilder(
    column: $table.contenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emplacement => $composableBuilder(
    column: $table.emplacement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateEntree => $composableBuilder(
    column: $table.dateEntree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateSortie => $composableBuilder(
    column: $table.dateSortie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prixAchat => $composableBuilder(
    column: $table.prixAchat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gardeMin => $composableBuilder(
    column: $table.gardeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gardeMax => $composableBuilder(
    column: $table.gardeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentaireEntree => $composableBuilder(
    column: $table.commentaireEntree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get noteDegus => $composableBuilder(
    column: $table.noteDegus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentaireDegus => $composableBuilder(
    column: $table.commentaireDegus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fournisseurNom => $composableBuilder(
    column: $table.fournisseurNom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fournisseurInfos => $composableBuilder(
    column: $table.fournisseurInfos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BouteillesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BouteillesTable> {
  $$BouteillesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domaine =>
      $composableBuilder(column: $table.domaine, builder: (column) => column);

  GeneratedColumn<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get millesime =>
      $composableBuilder(column: $table.millesime, builder: (column) => column);

  GeneratedColumn<String> get couleur =>
      $composableBuilder(column: $table.couleur, builder: (column) => column);

  GeneratedColumn<String> get cru =>
      $composableBuilder(column: $table.cru, builder: (column) => column);

  GeneratedColumn<String> get contenance => $composableBuilder(
    column: $table.contenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emplacement => $composableBuilder(
    column: $table.emplacement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateEntree => $composableBuilder(
    column: $table.dateEntree,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateSortie => $composableBuilder(
    column: $table.dateSortie,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prixAchat =>
      $composableBuilder(column: $table.prixAchat, builder: (column) => column);

  GeneratedColumn<int> get gardeMin =>
      $composableBuilder(column: $table.gardeMin, builder: (column) => column);

  GeneratedColumn<int> get gardeMax =>
      $composableBuilder(column: $table.gardeMax, builder: (column) => column);

  GeneratedColumn<String> get commentaireEntree => $composableBuilder(
    column: $table.commentaireEntree,
    builder: (column) => column,
  );

  GeneratedColumn<double> get noteDegus =>
      $composableBuilder(column: $table.noteDegus, builder: (column) => column);

  GeneratedColumn<String> get commentaireDegus => $composableBuilder(
    column: $table.commentaireDegus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fournisseurNom => $composableBuilder(
    column: $table.fournisseurNom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fournisseurInfos => $composableBuilder(
    column: $table.fournisseurInfos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BouteillesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BouteillesTable,
          Bouteille,
          $$BouteillesTableFilterComposer,
          $$BouteillesTableOrderingComposer,
          $$BouteillesTableAnnotationComposer,
          $$BouteillesTableCreateCompanionBuilder,
          $$BouteillesTableUpdateCompanionBuilder,
          (
            Bouteille,
            BaseReferences<_$AppDatabase, $BouteillesTable, Bouteille>,
          ),
          Bouteille,
          PrefetchHooks Function()
        > {
  $$BouteillesTableTableManager(_$AppDatabase db, $BouteillesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BouteillesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BouteillesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BouteillesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> domaine = const Value.absent(),
                Value<String> appellation = const Value.absent(),
                Value<int> millesime = const Value.absent(),
                Value<String> couleur = const Value.absent(),
                Value<String?> cru = const Value.absent(),
                Value<String> contenance = const Value.absent(),
                Value<String> emplacement = const Value.absent(),
                Value<String> dateEntree = const Value.absent(),
                Value<String?> dateSortie = const Value.absent(),
                Value<double?> prixAchat = const Value.absent(),
                Value<int?> gardeMin = const Value.absent(),
                Value<int?> gardeMax = const Value.absent(),
                Value<String?> commentaireEntree = const Value.absent(),
                Value<double?> noteDegus = const Value.absent(),
                Value<String?> commentaireDegus = const Value.absent(),
                Value<String?> fournisseurNom = const Value.absent(),
                Value<String?> fournisseurInfos = const Value.absent(),
                Value<String?> producteur = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BouteillesCompanion(
                id: id,
                domaine: domaine,
                appellation: appellation,
                millesime: millesime,
                couleur: couleur,
                cru: cru,
                contenance: contenance,
                emplacement: emplacement,
                dateEntree: dateEntree,
                dateSortie: dateSortie,
                prixAchat: prixAchat,
                gardeMin: gardeMin,
                gardeMax: gardeMax,
                commentaireEntree: commentaireEntree,
                noteDegus: noteDegus,
                commentaireDegus: commentaireDegus,
                fournisseurNom: fournisseurNom,
                fournisseurInfos: fournisseurInfos,
                producteur: producteur,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String domaine,
                required String appellation,
                required int millesime,
                required String couleur,
                Value<String?> cru = const Value.absent(),
                required String contenance,
                required String emplacement,
                required String dateEntree,
                Value<String?> dateSortie = const Value.absent(),
                Value<double?> prixAchat = const Value.absent(),
                Value<int?> gardeMin = const Value.absent(),
                Value<int?> gardeMax = const Value.absent(),
                Value<String?> commentaireEntree = const Value.absent(),
                Value<double?> noteDegus = const Value.absent(),
                Value<String?> commentaireDegus = const Value.absent(),
                Value<String?> fournisseurNom = const Value.absent(),
                Value<String?> fournisseurInfos = const Value.absent(),
                Value<String?> producteur = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BouteillesCompanion.insert(
                id: id,
                domaine: domaine,
                appellation: appellation,
                millesime: millesime,
                couleur: couleur,
                cru: cru,
                contenance: contenance,
                emplacement: emplacement,
                dateEntree: dateEntree,
                dateSortie: dateSortie,
                prixAchat: prixAchat,
                gardeMin: gardeMin,
                gardeMax: gardeMax,
                commentaireEntree: commentaireEntree,
                noteDegus: noteDegus,
                commentaireDegus: commentaireDegus,
                fournisseurNom: fournisseurNom,
                fournisseurInfos: fournisseurInfos,
                producteur: producteur,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BouteillesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BouteillesTable,
      Bouteille,
      $$BouteillesTableFilterComposer,
      $$BouteillesTableOrderingComposer,
      $$BouteillesTableAnnotationComposer,
      $$BouteillesTableCreateCompanionBuilder,
      $$BouteillesTableUpdateCompanionBuilder,
      (Bouteille, BaseReferences<_$AppDatabase, $BouteillesTable, Bouteille>),
      Bouteille,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BouteillesTableTableManager get bouteilles =>
      $$BouteillesTableTableManager(_db, _db.bouteilles);
}
