import 'package:flutter_cielo/src/CieloError.dart';
import 'package:flutter_cielo/src/CieloException.dart';
import 'package:flutter_cielo/src/CreditCard.dart';
import 'package:flutter_cielo/src/Environment.dart';
import 'package:flutter_cielo/src/Merchant.dart';
import 'package:flutter_cielo/src/Sale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CieloEcommerce {
  final Environment environment;
  final Merchant merchant;
  Dio dio;

  CieloEcommerce({@required this.environment, @required this.merchant}) {
    dio = Dio(BaseOptions(headers: {
      "MerchantId": this.merchant.merchantId,
      "MerchantKey": this.merchant.merchantKey
    }));
  }

  Future<Sale> createSale(Sale sale) async {
    try {
      Response response =
          await dio.post("${environment.apiUrl}/1/sales/", data: sale.toJson());
      return Sale.fromJson(response.data);
    } on DioError catch (e) {
      _getErrorDio(e);
    } catch (e) {
      throw CieloException(
          List<CieloError>()
            ..add(CieloError(
              code: 0,
            )),
          "unknown");
    }
    return null;
  }

  Future<CreditCard> tokenizeCard(CreditCard card) async {
    Response response =
        await dio.post("${environment.apiUrl}/1/card/", data: card.toJson());
    return CreditCard.fromJson(response.data);
  }

  _getErrorDio(DioError e) {
    if (e?.response != null) {
      List<CieloError> errors =
          (e.response.data as List).map((i) => CieloError.fromJson(i)).toList();
      throw CieloException(errors, e.message);
    } else {
      throw CieloException(
          List<CieloError>()
            ..add(CieloError(
              code: 0,
              message: "unknown"
            )),
          e.message);
    }
  }
}
