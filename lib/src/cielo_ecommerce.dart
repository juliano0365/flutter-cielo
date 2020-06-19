import 'package:flutter_cielo/src/CieloError.dart';
import 'package:flutter_cielo/src/CieloException.dart';
import 'package:flutter_cielo/src/CreditCard.dart';
import 'package:flutter_cielo/src/Environment.dart';
import 'package:flutter_cielo/src/Merchant.dart';
import 'package:flutter_cielo/src/Sale.dart';
import 'package:dio/dio.dart';

class CieloEcommerce {
  final Environment environment;
  final Merchant merchant;
  Dio dio;

  CieloEcommerce({this.environment, this.merchant}) {
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
              message: e.message,
            )),
          "unknown");
    }
    return null;
  }

  Future<CreditCard> tokenizeCard(CreditCard card) async {
    try {
      Response response =
          await dio.post("${environment.apiUrl}/1/card/", data: card.toJson());
      card.cardToken = response.data["CardToken"];
      card.cardNumber = "****"+card.cardNumber.substring(card.cardNumber.length - 4);
      return card;
    } on DioError catch (e) {
      _getErrorDio(e);
    } catch (e) {
      throw CieloException(
          List<CieloError>()
            ..add(CieloError(
              code: 0,
              message: e.message,
            )),
          "unknown");
    }
    return null;
  }

  _getErrorDio(DioError e) {
    var error;
    if (e?.response != null && e?.response != "") {
      if (e.response.data != null) {
        if (e.response.statusCode == 500) {
          if (e.response.data != null) {
            if (e.response?.data["Message"] != null) {
              error = e.response?.data["Message"]?.toString();
              if (e.response?.data["ExceptionMessage"] != null) {
                print('Foi Dio nested');
                error =
                "$error Details: ${e.response?.data["ExceptionMessage"]
                    ?.toString()}";
              }
            }
          }
        } else {
          print('Foi Dio Exception');
          error = e.response.toString();
        }
      }
    }
    print(error);
  }
}
