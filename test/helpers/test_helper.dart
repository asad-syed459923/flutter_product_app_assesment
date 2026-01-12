import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_product_app_assesment/core/network/api_client.dart';
import 'package:flutter_product_app_assesment/core/network/network_info.dart';
import 'package:flutter_product_app_assesment/data/datasources/db_service.dart';
import 'package:flutter_product_app_assesment/domain/repositories/product_repository.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([
  ProductRepository,
  ApiClient,
  DbService,
  NetworkInfo,
  Database,
  DatabaseExecutor, // For batch
  Batch,
])
void main() {}
