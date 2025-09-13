import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:maktub/core/exceptions/app_exception.dart';
import 'package:maktub/data/services/crashlytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;
  final FirebaseCrashlytics crashlytics = CrashlyticsService.crashlytics
  ;
  Future<T> handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request().timeout(Duration(seconds: 5));
    } on SocketException {
      throw NetworkException();
    } on TimeoutException catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw ServerException(
        "Время ожидания запроса истекло. Попробуйте позже.",
      );
    } on PostgrestException catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw ServerException("Ошибка БД: ${e.message}");
    } on AuthException catch (e) {
      if (_shouldLogAuthError(e.message)) {
        _logError(e, StackTrace.current);
      }
      if (e.message.contains("Invalid login credentials")) {
        throw WrongPasswordException();
      } else if (e.message.contains("User not found")) {
        throw UserNotFoundException();
      } else {
        throw ServerException("Ошибка аутентификации: ${e.message}");
      }
    } on FormatException catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw ServerException("Ошибка формата данных: ${e.message}");
    } on TypeError catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw ServerException("Ошибка типов данных: ${e.toString()}");
    } on http.Response catch (response) {
    // 🔥 Добавлена обработка HTTP-ошибок
    throw ServerException("Ошибка сервера: ${response.statusCode} - ${response.data}");
  } catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw UnknownException("Неизвестная ошибка: ${e.toString()}");
    }
  }

  bool _shouldLogAuthError(String message) {
    // Логируем только неожиданные ошибки
    return !(message.contains("Invalid login credentials") ||
        message.contains("User not found") ||
        message.contains("Session expired"));
  }

  void _logError(dynamic error, StackTrace stackTrace) {
    crashlytics.recordError(error, stackTrace);
  }
}


  //todo login 

  //todo logout

  //todo signup

  //todo getMaktubOrganization

  //todo addMaktubOrganization

  //todo updateMaktubOrganization

  //todo getMaktubUser

  //todo addMaktubUser

  //todo updateMaktubUser
  
  //todo getAdsCarousel

  //todo getBannerAds

  //todo getBannerAdsByCategory

  //todo getHomeScreenCategories

  //todo getProductOfWeek

  //todo getProduct

  //todo addProductToFavorites

  //todo removeProductFromFavorites

  //todo getProductList

  //todo getProductListById

  //todo getProductListByCategory

  //todo getProductListByFilter

  //todo getProductListBySearch

  //todo getProductListBySupplier

  //todo getSupplierList

  //todo getSupplierListByCategory

  //todo getSupplierListByFilter

  //todo getSupplierListBySearch

  //todo getSupplier

  //todo addSupplierToFavorites

  //todo removeSupplierFromFavorites

  //todo getCartItemList

  //todo addProductToCart

  //todo removeProductFromCart

  //todo updateProductInCart

  //todo clearCart

  //todo getOrderList

  //todo getOrderItemList

  //todo downloarOrderInvoice

  //todo uploadOrderInvoice

  //todo getFavoriteProductList

  //todo getFavoriteSupplierList

  //todo getRegions
