import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';


class DbService {
  static const String productsBoxName = 'products_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String settingsBoxName = 'settings_box';

  Box<ProductModel>? _productsBox;
  Box<ProductModel>? _favoritesBox;
  Box? _settingsBox;

  Future<void> init() async {
    // Initialize Hive
    
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
       Hive.registerAdapter(ProductModelAdapter());
    }

    _productsBox = await Hive.openBox<ProductModel>(productsBoxName);
    _favoritesBox = await Hive.openBox<ProductModel>(favoritesBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  Box<ProductModel> get productsBox {
    if (_productsBox == null) {
      throw Exception('DbService not initialized. Call init() first.');
    }
    return _productsBox!;
  }

  Box<ProductModel> get favoritesBox {
    if (_favoritesBox == null) {
      throw Exception('DbService not initialized. Call init() first.');
    }
    return _favoritesBox!;
  }

  Box get settingsBox {
    if (_settingsBox == null) {
      throw Exception('DbService not initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  Future<void> saveSetting(String key, String value) async {
    await settingsBox.put(key, value);
  }

  Future<String?> getSetting(String key) async {
    return settingsBox.get(key) as String?;
  }
}
