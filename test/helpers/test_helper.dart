import 'package:mockito/annotations.dart';
import 'package:flutter_product_app_assesment/core/network/api_client.dart';
import 'package:flutter_product_app_assesment/core/network/network_info.dart';
import 'package:flutter_product_app_assesment/data/datasources/db_service.dart';
import 'package:flutter_product_app_assesment/domain/repositories/product_repository.dart';
import 'package:hive/hive.dart';
import 'package:flutter_product_app_assesment/presentation/controllers/product_controller.dart';

@GenerateMocks([
  ProductRepository,
  ApiClient,
  DbService,
  NetworkInfo,
  ProductController,
  Box,
])
void main() {}
