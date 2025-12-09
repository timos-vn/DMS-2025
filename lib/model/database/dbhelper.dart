// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:core';
import 'dart:io';
import 'package:dms/model/entity/info_login.dart';
import 'package:dms/utils/const.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/log.dart';
import '../entity/app_settings.dart';
import '../entity/image_check_in.dart';
import '../entity/item_check_in.dart';
import '../entity/product.dart';

class DatabaseHelper {
 static const NEW_DB_VERSION = 20251208; // Thêm availableQuantity vào product table
  static final DatabaseHelper _instance = DatabaseHelper._();
  Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      print('db is exits');
      return _database!;
    }
    _database = await init();
    return _database!;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
    CREATE TABLE infoLogin(
      code TEXT,
      name TEXT,
      hot TEXT,
      id TEXT,
      pass TEXT,
      dateLogin TEXT,
      accessToken TEXT,
      refreshToken TEXT,
      userId TEXT,
      userName TEXT,
      fullName TEXT,
      woPrice INT,
      autoAddDiscount INT,
      addProductFollowStore INT,
      viewTotalMoneyGift INT)
  ''');
    print("Database InfoLogin was created!");
    db.execute('''
    CREATE TABLE appSettings(
      id TEXT,
      name TEXT,
      value TEXT, 
      holo TEXT)
  ''');
    print("Database appSettings was created!");
    db.execute('''
    CREATE TABLE product(
      code TEXT,
      maVt2 TEXT,
      name TEXT,
      name2 TEXT,
      dvt TEXT,
      description TEXT,
      price REAL,
      discountPercent REAL,
      priceAfter REAL,
      stockAmount REAL,
      taxPercent REAL,
      imageUrl TEXT,
      count REAL,
      countMax REAL,
      discountMoney TEXT,
      discountProduct TEXT,
      budgetForItem TEXT,
      budgetForProduct TEXT,
      residualValueProduct REAL,
      residualValue REAL,
      unit TEXT,
      unitProduct TEXT,
      isMark INT,
      dsCKLineItem TEXT,
      nhieu_dvt INT,
      ndvt TEXT,
      kColorFormatAlphaB INT,
      codeStock TEXT,
      nameStock TEXT,
      idVv TEXT,
      idHd TEXT,
      nameVv TEXT,
      nameHd TEXT,
      editPrice INT,
      isCheBien INT,
      isSanXuat INT,
      giaSuaDoi REAL,
      giaGui REAL,
      priceMin REAL,
      codeUnit TEXT,
      nameUnit TEXT,
      note TEXT,
      jsonOtherInfo TEXT,
      heSo TEXT,
      idNVKD TEXT,
      nameNVKD TEXT,
      nuocsx TEXT,
      quycach TEXT,
      contentDvt TEXT,
      maThue TEXT,
      tenThue TEXT,
      thueSuat REAL,
      applyPriceAfterTax INT,
      discountByHand INT,
      discountPercentByHand REAL,
      ckntByHand REAL,
      priceOk REAL,
      woPrice REAL,
      woPriceAfter REAL,
      so_luong_kd REAL,
      sttRec0 TEXT,
      availableQuantity REAL,
      originalPrice REAL
      )
  ''');
    print("Database Production was created!");
    db.execute('''
    CREATE TABLE saleOut(
      code TEXT,
      maVt2 TEXT,
      name TEXT,
      name2 TEXT,
      dvt TEXT,
      description TEXT,
      price REAL,
      discountPercent REAL,
      priceAfter REAL,
      stockAmount REAL,
      taxPercent REAL,
      imageUrl TEXT,
      count REAL,
      countMax REAL,
      discountMoney TEXT,
      discountProduct TEXT,
      budgetForItem TEXT,
      budgetForProduct TEXT,
      residualValueProduct REAL,
      residualValue REAL,
      unit TEXT,
      unitProduct TEXT,
      isMark INT,
      dsCKLineItem TEXT,
      nhieu_dvt INT,
      ndvt TEXT,
      kColorFormatAlphaB INT,
      codeStock TEXT,
      nameStock TEXT,
      idVv TEXT,
      idHd TEXT,
      nameVv TEXT,
      nameHd TEXT,
      editPrice INT,
      isCheBien INT,
      isSanXuat INT,
      giaSuaDoi REAL,
      giaGui REAL,
      priceMin REAL,
      codeUnit TEXT,
      nameUnit TEXT,
      note TEXT,
      jsonOtherInfo TEXT,heSo TEXT, idNVKD TEXT,
      nameNVKD TEXT,
      nuocsx TEXT,
      quycach TEXT,contentDvt TEXT,maThue TEXT,
      tenThue TEXT,
      thueSuat REAL,
      applyPriceAfterTax INT,
      discountByHand INT,
      discountPercentByHand REAL,
      ckntByHand REAL,
      priceOk REAL,
      woPrice REAL,
      woPriceAfter REAL,
      so_luong_kd REAL,
      sttRec0 TEXT,
      availableQuantity REAL,
      originalPrice REAL)
  ''');
    print("Database saleOut was created!");

    db.execute('''
    CREATE TABLE imageCheckIn(
      id TEXT,
      idCheckIn TEXT, 
      maAlbum TEXT,
      tenAlbum TEXT,
      fileName TEXT,
      filePath TEXT,
      isSync INT
     )
  ''');
    print("Database imageCheckIn was created!");

    db.execute('''
    CREATE TABLE listCheckIn(
      id TEXT,
    tieuDe TEXT,
    ngayCheckin TEXT,
    maKh TEXT,
    tenCh TEXT,
    diaChi TEXT,
    dienThoai TEXT,
    gps TEXT,
    trangThai TEXT,
    tgHoanThanh TEXT,
    lastChko TEXT,
    latlong TEXT,
    dateSave TEXT,
    numberTimeCheckOut INT,
    idCheckIn TEXT,
    timeCheckIn TEXT,
    openStore TEXT,
    timeCheckOut TEXT,
    note TEXT,
    isCheckInSuccessful INT,
    isSynSuccessful INT,
    addressDifferent TEXT,
    latDifferent REAL,
    longDifferent REAL
     )
  ''');
    print("Database listCheckIn was created!");
    db.execute('''
    CREATE TABLE listCheckInOffLine(
    id TEXT,
    tieuDe TEXT,
    ngayCheckin TEXT,
    maKh TEXT,
    tenCh TEXT,
    diaChi TEXT,
    dienThoai TEXT,
    gps TEXT,
    trangThai TEXT,
    tgHoanThanh TEXT,
    lastChko TEXT,
    latlong TEXT,
    dateSave TEXT,
    numberTimeCheckOut INT,
    idCheckIn TEXT,
    timeCheckIn TEXT,
    openStore TEXT,
    timeCheckOut TEXT,
    note TEXT,
    isCheckInSuccessful INT,
    isSynSuccessful INT,
    addressDifferent TEXT,
    latDifferent REAL,
    longDifferent REAL
     )
  ''');
    print("Database listCheckInOffLine was created!");

    db.execute('''
    CREATE TABLE listAlbumOffLine(
    maAlbum TEXT,
    tenAlbum TEXT,
    ycAnhYN INT
     )
  ''');
    print("Database listAlbumOffLine was created!");

    db.execute('''
    CREATE TABLE listAlbumTicketOffLine(
    ticketId TEXT,
    tenLoai TEXT
     )
  ''');
    print("Database listAlbumTicketOffLine was created!");

    db.execute('''
    CREATE TABLE listTicketOffLine(
    idIncrement integer primary key autoincrement,
    id TEXT,
    customerCode TEXT,
    idTicketType TEXT,
    nameTicketType TEXT,
    idCheckIn TEXT,
    comment TEXT,
    fileName TEXT,
    filePath TEXT,
    dateTimeCreate TEXT,
    status TEXT
     )
  ''');
    print("Database listTicketOffLine was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
    logger.i(
      "Migration: $oldVersion, $newVersion",
    );
    print('"Migration: $oldVersion, $newVersion"');
    
    // Migration for version 20250831 - Add availableQuantity column
    if (oldVersion < NEW_DB_VERSION) {
      try {
        // Add availableQuantity column to product table if it doesn't exist
        db.execute('ALTER TABLE product ADD COLUMN availableQuantity REAL');
        print("Added availableQuantity column to product table");
      } catch (e) {
        print("Column availableQuantity might already exist in product table: $e");
      }
      
      try {
        // Add availableQuantity column to saleOut table if it doesn't exist
        db.execute('ALTER TABLE saleOut ADD COLUMN availableQuantity REAL');
        print("Added availableQuantity column to saleOut table");
      } catch (e) {
        print("Column availableQuantity might already exist in saleOut table: $e");
      }
    }
    
    // Legacy migration logic (keeping for backward compatibility)
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE product ADD COLUMN attributes TEXT');
      db.delete("product");
    }
    db.execute('DROP TABLE IF EXISTS product');
    db.delete("product");
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE appSettings ADD COLUMN attributes TEXT');
      db.delete("appSettings");
    }
    db.execute('DROP TABLE IF EXISTS appSettings');
    db.delete("appSettings");
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE infoLogin ADD COLUMN attributes TEXT');
      db.delete("infoLogin");
    }
    db.execute('DROP TABLE IF EXISTS infoLogin');
    db.delete("infoLogin");
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE saleOut ADD COLUMN attributes TEXT');
      db.delete("saleOut");
    }
    db.execute('DROP TABLE IF EXISTS saleOut');
    db.delete("saleOut");
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE imageCheckIn ADD COLUMN attributes TEXT');
      db.delete("imageCheckIn");
    }
    db.execute('DROP TABLE IF EXISTS imageCheckIn');
    db.delete("imageCheckIn");
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE listCheckIn ADD COLUMN attributes TEXT');
      db.delete("listCheckIn");
    }
    db.execute('DROP TABLE IF EXISTS listCheckIn');
    db.delete("listCheckIn");

    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE listCheckInOffLine ADD COLUMN attributes TEXT');
      db.delete("listCheckInOffLine");
    }
    db.execute('DROP TABLE IF EXISTS listCheckInOffLine');
    db.delete("listCheckInOffLine");

    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE listAlbumOffLine ADD COLUMN attributes TEXT');
      db.delete("listAlbumOffLine");
    }
    db.execute('DROP TABLE IF EXISTS listAlbumOffLine');
    db.delete("listAlbumOffLine");

    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE listAlbumTicketOffLine ADD COLUMN attributes TEXT');
      db.delete("listAlbumTicketOffLine");
    }
    db.execute('DROP TABLE IF EXISTS listAlbumTicketOffLine');
    db.delete("listAlbumTicketOffLine");

    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE listTicketOffLine ADD COLUMN attributes TEXT');
      db.delete("listTicketOffLine");
    }
    db.execute('DROP TABLE IF EXISTS listTicketOffLine');
    db.delete("listTicketOffLine");
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = p.join(directory.toString(), 'database.db');
    var database = await openDatabase(dbPath);
    // var shouldCreate = false;
    // var database = await openDatabase(dbPath, version: 2, onCreate: _onCreate,
    //     onUpgrade: (db, oldVersion, newVersion) {
    //       if (oldVersion < 2) {
    //         // Need to recreate the db
    //         shouldCreate = true;
    //       }
    //     });
    // if (shouldCreate) {
    //   await database.close();
    //   await deleteDatabase(dbPath);
    //   database = await openDatabase(dbPath, version: 2, onCreate: _onCreate);
    // }

    if (await database.getVersion() < NEW_DB_VERSION) {

      print('check version db < ');
      database.close();
      await deleteDatabase(dbPath);

      //database = await openDatabase(dbPath, version: NEW_DB_VERSION, onCreate: _onCreate);
      database = await openDatabase(dbPath,onCreate: _onCreate,version: NEW_DB_VERSION);
      database.setVersion(NEW_DB_VERSION);
    }else{
      print('check version db ==');
      database = await openDatabase(dbPath,onCreate: _onCreate, onUpgrade: _onUpgrade,version: NEW_DB_VERSION);
    }

    // _onUpgrade(db, oldVersion, newVersion);
    // var database = openDatabase(dbPath, version: 2,
    //     onCreate: (db, version)async{
    //   _onCreate(db,version);
    // },
    //     onUpgrade:(Database db, int _, int __)async{
    //   _onUpgrade(db,_,__);
    // });
    return database;
  }

  ///InfoLogin

  Future<void> addInfoLogin(InfoLogin infoLogin) async {
    var client = await db;
    InfoLogin? oldLang = await fetchInfoLogin(infoLogin.code);
    if (oldLang == null) {
      await client.insert('infoLogin', infoLogin.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateInfoLogin(oldLang);
    }
  }

  Future<InfoLogin?> fetchInfoLogin(String code) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('infoLogin', where: 'code = ?', whereArgs: [code]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return InfoLogin.fromDb(maps.first);
    }
    return null;
  }

  Future<List<InfoLogin>> fetchAllInfoLogin() async {
    var client = await db;
    var res = await client.query('infoLogin');
    if (res.isNotEmpty) {
      var infoLogin =
          res.map((infoLoginMap) => InfoLogin.fromDb(infoLoginMap)).toList();
      return infoLogin;
    }
    return [];
  }

  Future<List<InfoLogin>> getInfoLogin() async {
    var client = await db;
    var res = await client.query('infoLogin',);
    if (res.isNotEmpty) {
      var infoLogin =
          res.map((infoLoginMap) => InfoLogin.fromDb(infoLoginMap)).toList();
      return infoLogin;
    }
    return [];
  }

  Future<void> deleteInfoLogin(InfoLogin infoLogin) async {
    var client = await db;
    await client.delete('infoLogin', where: 'code = ?', whereArgs: [infoLogin.code]);
  }

  Future<int> updateInfoLogin(InfoLogin infoLogin) async {
    var client = await db;
    return client.update('infoLogin', infoLogin.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeInfoLogin(int id) async {
    var client = await db;
    return client.delete('infoLogin', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllDBLogin() async {
    var client = await db;
    await client.delete('infoLogin');
  }

  ///appSettings

  Future<void> addAppSettings(AppSettings appSettings) async {
    var client = await db;
    AppSettings? oldLang = await fetchAppSettings(appSettings.id);
    if (oldLang == null) {
      await client.insert('appSettings', appSettings.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateAppSettings(oldLang);
    }
  }

  Future<AppSettings?> fetchAppSettings(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('appSettings', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return AppSettings.fromDb(maps.first);
    }
    return null;
  }

  Future<List<AppSettings>> fetchAllAppSettings() async {
    var client = await db;
    var res = await client.query('appSettings');
    if (res.isNotEmpty) {
      var appSettings =
      res.map((appSettingsMap) => AppSettings.fromDb(appSettingsMap)).toList();
      return appSettings;
    }
    return [];
  }

  Future<List<AppSettings>> getIAppSettings() async {
    var client = await db;
    var res = await client.query('appSettings',);
    if (res.isNotEmpty) {
      var appSettings =
      res.map((appSettingsMap) => AppSettings.fromDb(appSettingsMap)).toList();
      return appSettings;
    }
    return [];
  }

  Future<void> deleteAppSettings(int idCheckIn) async {
    var client = await db;
    await client.delete('appSettings', where: 'id = ?', whereArgs: [idCheckIn]);
  }

  Future<void> deleteAllAppSettings() async {
    var client = await db;
    await client.delete('appSettings');
  }

  Future<int> updateAppSettings(AppSettings appSettings) async {
    var client = await db;
    return client.update('appSettings', appSettings.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeAppSettings(int id) async {
    var client = await db;
    return client.delete('appSettings', where: 'id = ?', whereArgs: [id]);
  }

  ///ImageCheckIn

  Future<void> addImageCheckIn(ImageCheckIn imageCheckIn) async {
    var client = await db;
    ImageCheckIn? oldImage = await fetchImageCheckIn(imageCheckIn.fileName.toString());
    if (oldImage == null) {
      await client.insert('imageCheckIn', imageCheckIn.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateImageCheckIn(oldImage);
    }
  }

  Future<ImageCheckIn?> fetchImageCheckIn(String fileName) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('imageCheckIn', where: 'fileName = ?', whereArgs: [fileName]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ImageCheckIn.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ImageCheckIn>> fetchAllImageCheckIn() async {
    var client = await db;
    var res = await client.query('imageCheckIn');
    if (res.isNotEmpty) {
      var imageCheckIn =
      res.map((imageCheckInMap) => ImageCheckIn.fromDb(imageCheckInMap)).toList();
      return imageCheckIn;
    }
    return [];
  }

  Future<List<ImageCheckIn>> getImageCheckIn() async {
    var client = await db;
    var res = await client.query('imageCheckIn',);
    if (res.isNotEmpty) {
      var imageCheckIn =
      res.map((imageCheckInMap) => ImageCheckIn.fromDb(imageCheckInMap)).toList();
      return imageCheckIn;
    }
    return [];
  }

  Future<void> deleteImageCheckIn(String fileName) async {
    var client = await db;
    await client.delete('imageCheckIn', where: 'fileName = ?', whereArgs: [fileName]);
  }

  Future<void> deleteAllImageCheckIn() async {
    var client = await db;
    await client.delete('imageCheckIn');
  }

  Future<int> updateImageCheckIn(ImageCheckIn imageCheckIn) async {
    var client = await db;
    return client.update('imageCheckIn', imageCheckIn.toMapForDb(),
        where: 'id = ?',
        whereArgs: [imageCheckIn.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeImageCheckIn(String fileName) async {
    var client = await db;
    return client.delete('imageCheckIn', where: 'fileName = ?', whereArgs: [fileName]);
  }

  Future<Future<int>> removeImageCacheCheckIn(String id) async {
    var client = await db;
    return client.delete('imageCheckIn', where: 'id = ?', whereArgs: [id]);
  }

  ///listCheckIn

  Future<void> addListCheckIn(ItemCheckInOffline itemCheckIn) async {
    var client = await db;
    ItemCheckInOffline? oldItem = await fetchListCheckIn(itemCheckIn.id.toString());
    if (oldItem == null) {
      await client.insert('listCheckIn', itemCheckIn.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateListCheckIn(oldItem);
    }
  }

  Future<ItemCheckInOffline?> fetchListCheckIn(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('listCheckIn', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ItemCheckInOffline.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ItemCheckInOffline>> fetchAllListCheckIn() async {
    var client = await db;
    var res = await client.query('listCheckIn');
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemCheckInOffline.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<List<ItemCheckInOffline>> getListCheckIn() async {
    var client = await db;
    var res = await client.query('listCheckIn',);
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemCheckInOffline.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<void> deleteListCheckIn(String id) async {
    var client = await db;
    await client.delete('listCheckIn', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllListCheckIn() async {
    var client = await db;
    await client.delete('listCheckIn');
  }

  Future<int> updateListCheckIn(ItemCheckInOffline itemCheckIn) async {
    var client = await db;
    return client.update('listCheckIn', itemCheckIn.toMapForDb(),
        where: 'id = ?',
        whereArgs: [itemCheckIn.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeListCheckIn(String id) async {
    var client = await db;
    return client.delete('listCheckIn', where: 'id = ?', whereArgs: [id]);
  }

  ///listTicketOffLine

  Future<void> addListTicketOffLine(ItemListTicketOffLine item) async {
    var client = await db;
    ItemListTicketOffLine? oldItem = await fetchListTicketOffLine(item.idIncrement.toString());
    if (oldItem == null) {
      await client.insert('listTicketOffLine', item.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateListTicketOffLine(oldItem);
    }
  }

  Future<ItemListTicketOffLine?> fetchListTicketOffLine(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('listTicketOffLine', where: 'idIncrement = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ItemListTicketOffLine.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ItemListTicketOffLine>> fetchAllListTicketOffLine() async {
    var client = await db;
    var res = await client.query('listTicketOffLine');
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemListTicketOffLine.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<List<ItemListTicketOffLine>> getListTicketOffLine() async {
    var client = await db;
    var res = await client.query('listTicketOffLine',);
    if (res.isNotEmpty) {
      var item =
      res.map((itemCheckInMap) => ItemListTicketOffLine.fromDb(itemCheckInMap)).toList();
      return item;
    }
    return [];
  }

  Future<void> deleteListTicketOffLine(String id) async {
    var client = await db;
    await client.delete('listTicketOffLine', where: 'idIncrement = ?', whereArgs: [id]);
  }

  Future<void> deleteAllListTicketOffLine() async {
    var client = await db;
    await client.delete('listTicketOffLine');
  }

  Future<int> updateListTicketOffLine(ItemListTicketOffLine itemCheckIn) async {
    var client = await db;
    return client.update('listTicketOffLine', itemCheckIn.toMapForDb(),
        where: 'idIncrement = ?',
        whereArgs: [itemCheckIn.idIncrement],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeListTicketOffLine(String id) async {
    var client = await db;
    return client.delete('listTicketOffLine', where: 'idIncrement = ?', whereArgs: [id]);
  }

  /// ListCheckInOffLine

  Future<void> addListCheckInOffline(ItemCheckInOffline item) async {
    var client = await db;
    ItemCheckInOffline? oldItem = await fetchListCheckInOffline(item.id.toString());
    if (oldItem == null) {
      await client.insert('listCheckInOffLine', item.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateListCheckInOffline(oldItem);
    }
  }

  Future<ItemCheckInOffline?> fetchListCheckInOffline(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('listCheckInOffLine', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ItemCheckInOffline.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ItemCheckInOffline>> fetchAllListCheckInOffline() async {
    var client = await db;
    var res = await client.query('listCheckInOffLine');
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemCheckInOffline.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<List<ItemCheckInOffline>> getListCheckInOffline() async {
    var client = await db;
    var res = await client.query('listCheckInOffLine',);
    if (res.isNotEmpty) {
      var item =
      res.map((itemCheckInMap) => ItemCheckInOffline.fromDb(itemCheckInMap)).toList();
      return item;
    }
    return [];
  }

  Future<void> deleteListCheckInOffline(String id) async {
    var client = await db;
    await client.delete('listCheckInOffLine', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllListCheckInOffline() async {
    var client = await db;
    await client.delete('listCheckInOffLine');
  }

  Future<int> updateListCheckInOffline(ItemCheckInOffline item) async {
    var client = await db;
    return client.update('listCheckInOffLine', item.toMapForDb(),
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeListCheckInOffline(String id) async {
    var client = await db;
    return client.delete('listCheckInOffLine', where: 'id = ?', whereArgs: [id]);
  }

  /// ListAlbumOffLine

  Future<void> addListAlbumOffline(ItemAlbum item) async {
    var client = await db;
    ItemAlbum? oldItem = await fetchListAlbumOffline(item.maAlbum.toString());
    if (oldItem == null) {
      await client.insert('listAlbumOffLine', item.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateListAlbumOffline(oldItem);
    }
  }

  Future<ItemAlbum?> fetchListAlbumOffline(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('listAlbumOffLine', where: 'maAlbum = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ItemAlbum.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ItemAlbum>> fetchAllListAlbumOffline() async {
    var client = await db;
    var res = await client.query('listAlbumOffLine');
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemAlbum.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<List<ItemAlbum>> getListAlbumOffline() async {
    var client = await db;
    var res = await client.query('listAlbumOffLine',);
    if (res.isNotEmpty) {
      var item =
      res.map((itemCheckInMap) => ItemAlbum.fromDb(itemCheckInMap)).toList();
      return item;
    }
    return [];
  }

  Future<void> deleteListAlbumOffline(String id) async {
    var client = await db;
    await client.delete('listAlbumOffLine', where: 'maAlbum = ?', whereArgs: [id]);
  }

  Future<void> deleteAllListAlbumOffline() async {
    var client = await db;
    await client.delete('listAlbumOffLine');
  }

  Future<int> updateListAlbumOffline(ItemAlbum item) async {
    var client = await db;
    return client.update('listAlbumOffLine', item.toMapForDb(),
        where: 'maAlbum = ?',
        whereArgs: [item.maAlbum],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeListAlbumOffline(String id) async {
    var client = await db;
    return client.delete('listAlbumOffLine', where: 'maAlbum = ?', whereArgs: [id]);
  }

  /// listAlbumTicketOffLine

  Future<void> addListAlbumTicketOffLine(ItemTicket item) async {
    var client = await db;
    ItemTicket? oldItem = await fetchListAlbumTicketOffLine(item.ticketId.toString());
    if (oldItem == null) {
      await client.insert('listAlbumTicketOffLine', item.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await updateListAlbumTicketOffLine(oldItem);
    }
  }

  Future<ItemTicket?> fetchListAlbumTicketOffLine(String id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('listAlbumTicketOffLine', where: 'ticketId = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return ItemTicket.fromDb(maps.first);
    }
    return null;
  }

  Future<List<ItemTicket>> fetchAllListAlbumTicketOffLine() async {
    var client = await db;
    var res = await client.query('listAlbumTicketOffLine');
    if (res.isNotEmpty) {
      var itemCheckIn =
      res.map((itemCheckInMap) => ItemTicket.fromDb(itemCheckInMap)).toList();
      return itemCheckIn;
    }
    return [];
  }

  Future<List<ItemTicket>> getListAlbumTicketOffLine() async {
    var client = await db;
    var res = await client.query('listAlbumTicketOffLine',);
    if (res.isNotEmpty) {
      var item =
      res.map((itemCheckInMap) => ItemTicket.fromDb(itemCheckInMap)).toList();
      return item;
    }
    return [];
  }

  Future<void> deleteListAlbumTicketOffLine(String id) async {
    var client = await db;
    await client.delete('listAlbumTicketOffLine', where: 'ticketId = ?', whereArgs: [id]);
  }

  Future<void> deleteAllListAlbumTicketOffLine() async {
    var client = await db;
    await client.delete('listAlbumTicketOffLine');
  }

  Future<int> updateListAlbumTicketOffLine(ItemTicket item) async {
    var client = await db;
    return client.update('listAlbumTicketOffLine', item.toMapForDb(),
        where: 'ticketId = ?',
        whereArgs: [item.ticketId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeListAlbumTicketOffLine(String id) async {
    var client = await db;
    return client.delete('listAlbumTicketOffLine', where: 'ticketId = ?', whereArgs: [id]);
  }

  ///Product
  Future<void> addProduct(Product product) async {
    var client = await db;
    Product? oldProduct = await fetchProduct(product.code.toString().trim(),product.codeStock.toString().trim());
    if(Const.addProductFollowStore == true){
      if (oldProduct == null && oldProduct?.codeStock.toString().trim() != product.codeStock.toString().trim()) {
        // Set originalPrice = price ban đầu nếu chưa có
        if (product.originalPrice == null) {
          product.originalPrice = product.price;
        }
        await client.insert('product', product.toMapForDb(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        oldProduct?.count = product.count!;//oldProduct.count! + product.count!;
        await updateProduct(product,product.codeStock.toString(),false);
      }
    }
    else{
      if (oldProduct == null) {
        // Set originalPrice = price ban đầu nếu chưa có
        if (product.originalPrice == null) {
          product.originalPrice = product.price;
        }
        await client.insert('product', product.toMapForDb(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        oldProduct.count = product.count!;//oldProduct.count! + product.count!;
        await updateProduct(product,product.codeStock.toString(),false);
      }
    }
  }

  Future<void> decreaseProduct(Product product) async {
    if (product.count! > 1) {
      product.count = product.count! - 1;
      updateProduct(product,product.codeStock.toString(),false);
    }
  }

  Future<void> increaseProduct(Product product) async {
    product.count = product.count! + 1;
    updateProduct(product,product.codeStock.toString(),false);
  }

  Future<void> updateProductCount(Product product, double count) async {
    double countNumber = product.count!;
    product.count = (product.count! - countNumber) + count;
    updateProduct(product,product.codeStock.toString(),false);
  }

  Future<Product?> fetchProduct(String code, String codeStock) async {
    var client = await db;
    var maps;
    if(Const.addProductFollowStore == true){
      final Future<List<Map<String, dynamic>>> futureMaps =
      client.query('product', where: 'code = ? and codeStock = ?', whereArgs: [code,codeStock]);
      maps = await futureMaps;
    }else{
      final Future<List<Map<String, dynamic>>> futureMaps =
      client.query('product', where: 'code = ?', whereArgs: [code]);
      maps = await futureMaps;
    }
    if (maps.length != 0) {
      return Product.fromDb(maps.first);
    }
    return null;
  }

  Future<Product?> fetchProductOld(String code) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('product', where: 'code = ?', whereArgs: [code]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return Product.fromDb(maps.first);
    }
    return null;
  }

  // Method để fetch product bằng sttRec0
  Future<Product?> fetchProductBySttRec0(String sttRec0) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('product', where: 'sttRec0 = ?', whereArgs: [sttRec0]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return Product.fromDb(maps.first);
    }
    return null;
  }

  // Method để add product với sttRec0 làm key chính (thay thế số lượng)
  Future<void> addProductWithSttRec0Replace(Product product) async {
    var client = await db;
    Product? oldProduct = await fetchProductBySttRec0(product.sttRec0.toString().trim());
    
    if (oldProduct == null) {
      // Chưa có sản phẩm này, thêm mới
      await client.insert('product', product.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      // Đã có sản phẩm này, THAY THẾ số lượng
      oldProduct.count = product.count!; // THAY THẾ, không cộng dồn
      await client.update('product', oldProduct.toMapForDb(),
          where: 'sttRec0 = ?',
          whereArgs: [product.sttRec0],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> deleteAllProduct() async {
    var client = await db;
    await client.delete('product');
  }
 
  Future<List<Product>> fetchAllProduct() async {
    var client = await db;
    var res = await client.query('product');

    if (res.isNotEmpty) {
      var products =
      res.map((productMap) => Product.fromDb(productMap)).toList();
      return products;
    }
    return [];
  }

  Future<List<Product>> getAllProductSelected() async {
    var client = await db;
    var res =
    await client.query('product', where: 'ismark = ?', whereArgs: [1]);

    if (res.isNotEmpty) {
      var products =
      res.map((productMap) => Product.fromDb(productMap)).toList();
      return products;
    }
    return [];
  }

  Future<void> deleteProductSelected() async {
    var client = await db;
    await client.delete('product', where: 'ismark = ?', whereArgs: [1]);
  }

  Future<int> updateProduct(Product pr, String codeStockOld, bool update) async {
    var client = await db;
    if(Const.addProductFollowStore == true && update == true){
      print('check stock: ${pr.codeStock} - $codeStockOld');//CC-AP00000034 - 0101
      Product? oldProduct = await fetchProduct(pr.code.toString(),pr.codeStock.toString());
      if(oldProduct != null){ /// sửa chính nó
        if(pr.codeStock == codeStockOld){
          return client.update('product', pr.toMapForDb(),
              where: 'code = ? and codeStock = ?',
              whereArgs: [pr.code,codeStockOld],
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        else {
          removeProductAndUpdate(pr.code.toString(),codeStockOld.toString());
          Product replaceProduct = oldProduct;
          replaceProduct.count = replaceProduct.count! + pr.count!;
          return client.update('product', replaceProduct.toMapForDb(),
              where: 'code = ? and codeStock = ?',
              whereArgs: [replaceProduct.code,replaceProduct.codeStock],
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      else { /// gộp hàng if(oldProduct != null && oldProduct.codeStock != codeStockOld)
        return client.update('product', pr.toMapForDb(),
            where: 'code = ? and codeStock = ?',
            whereArgs: [pr.code,codeStockOld],
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      // else{
      //   return client.insert('product', pr.toMapForDb(),
      //       conflictAlgorithm: ConflictAlgorithm.replace);
      // }
    }
    else if(Const.addProductFollowStore == true && update == false){
      return client.update('product', pr.toMapForDb(),
          where: 'code = ? and codeStock = ?',
          whereArgs: [pr.code,codeStockOld],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    else{
      return client.update('product', pr.toMapForDb(),
          where: 'code = ?',
          whereArgs: [pr.code],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<Future<int>> removeProductAndUpdate(String code, String codeStock) async {
    var client = await db;
    return client.delete('product', where: 'code = ? and codeStock = ?', whereArgs: [code,codeStock]);
  }

  Future<Future<int>> removeProduct(String code, String codeStock) async {
    var client = await db;
    if(Const.addProductFollowStore == true){
      return client.delete('product', where: 'code = ? and codeStock = ?', whereArgs: [code,codeStock]);
    }else{
      return client.delete('product', where: 'code = ?', whereArgs: [code]);
    }
  }

  Future<List<Map<String, dynamic>>> countProduct({ Database? database}) async {
    var client = database ?? await db;
    return client.rawQuery('SELECT COUNT (code) FROM product', null);
  }

  Future<int> getCountProduct({Database? database}) async {
    var client = database ?? await db;
    var countDb = await countProduct(database: client);
    if (countDb == null) return 0;
    return countDb[0]['COUNT (id)'];
  }

  ///Sale Out

  Future<void> addProductSaleOut(Product product) async {
    var client = await db;
    Product? oldProduct = await fetchProductSaleOut(product.code.toString());
    if (oldProduct == null) {
      // Set originalPrice = price ban đầu nếu chưa có
      if (product.originalPrice == null) {
        product.originalPrice = product.price;
      }
      await client.insert('saleOut', product.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      oldProduct.count = product.count!;//oldProduct.count! + product.count!;
      // Giữ nguyên originalPrice của sản phẩm cũ (không ghi đè)
      await updateProductSaleOut(oldProduct);
    }
  }

  Future<void> decreaseProductSaleOut(Product product) async {
    if (product.count! > 1) {
      product.count = product.count! - 1;
      updateProductSaleOut(product);
    }
  }

  Future<void> increaseProductSaleOut(Product product) async {
    product.count = product.count! + 1;
    updateProductSaleOut(product);
  }

  Future<void> updateProductCountSaleOut(Product product, double count) async {
    double countNumber = product.count!;
    product.count = (product.count! - countNumber) + count;
    updateProductSaleOut(product);
  }

  Future<Product?> fetchProductSaleOut(String code) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client.query('saleOut', where: 'code = ?', whereArgs: [code]);
    var maps = await futureMaps;
    if (maps.length != 0) {
      return Product.fromDb(maps.first);
    }
    return null;
  }

  Future<void> deleteAllProductSaleOut() async {
    var client = await db;
    await client.delete('saleOut');
  }

  Future<List<Product>> fetchAllProductSaleOut() async {
    var client = await db;
    var res = await client.query('saleOut');

    if (res.isNotEmpty) {
      var products =
      res.map((productMap) => Product.fromDb(productMap)).toList();
      return products;
    }
    return [];
  }

  Future<List<Product>> getAllProductSaleOutSelected() async {
    var client = await db;
    var res =
    await client.query('saleOut', where: 'ismark = ?', whereArgs: [1]);

    if (res.isNotEmpty) {
      var products =
      res.map((productMap) => Product.fromDb(productMap)).toList();
      return products;
    }
    return [];
  }

  Future<void> deleteProductSaleOutSelected() async {
    var client = await db;
    await client.delete('saleOut', where: 'ismark = ?', whereArgs: [1]);
  }

  Future<int> updateProductSaleOut(Product pr) async {
    var client = await db;
    return client.update('saleOut', pr.toMapForDb(),
        where: 'code = ?',
        whereArgs: [pr.code],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Future<int>> removeProductSaleOut(String code) async {
    var client = await db;
    return client.delete('saleOut', where: 'code = ?', whereArgs: [code]);
  }

  Future<List<Map<String, dynamic>>> countProductSaleOut({ Database? database}) async {
    var client = database ?? await db;
    return client.rawQuery('SELECT COUNT (code) FROM saleOut', null);
  }

  Future<int> getCountProductSaleOut({Database? database}) async {
    var client = database ?? await db;
    var countDb = await countProduct(database: client);
    if (countDb == null) return 0;
    return countDb[0]['COUNT (id)'];
  }

  Future closeDb() async {
    var client = await db;
    client.close();
  }
}
