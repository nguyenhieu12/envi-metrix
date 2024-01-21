import 'package:dio/dio.dart';
import 'package:envi_metrix/services/time_converter/time_converter.dart';
import 'package:envi_metrix/utils/global_variables.dart';
import 'package:envi_metrix/core/errors/exceptions.dart';
import 'package:envi_metrix/core/keys/app_keys.dart';
import 'package:envi_metrix/features/air_pollution/data/models/air_pollution_model.dart';
import 'package:envi_metrix/features/air_pollution/domain/entities/aqi_entity.dart';

abstract class AirPollutionRemoteDataSource {
  Future<AirPollutionModel> getCurrentAirPollution(double lat, double long);

  Future<List<AirPollutionModel>> getAirPollutionForecast(
      double lat, double long);

  Future<List<AirPollutionModel>> getAirPollutionHistory(
      double lat, double long, int unixStartDate, int unixEndDate);
}

class AirPollutionRemoteDataSourceImpl implements AirPollutionRemoteDataSource {
  final Dio dio;

  AirPollutionRemoteDataSourceImpl(this.dio);

  @override
  Future<AirPollutionModel> getCurrentAirPollution(
      double lat, double long) async {
    DateTime now = DateTime.now();

    int currentUnixTime = TimeConverter.getUnixTimestamp(now);
    int yesterdayUnixTime =
        TimeConverter.getUnixTimestamp(now.subtract(const Duration(days: 1)));

    final respone = await dio.get(
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${long}&appid=${AppKeys.openWeatherMapKey}');

    final yesterday = await dio.get(
        'http://api.openweathermap.org/data/2.5/air_pollution/history?lat=${lat}&lon=${long}&start=${yesterdayUnixTime}&end=$currentUnixTime&appid=${AppKeys.openWeatherMapKey}');

    if (respone.statusCode == 200 && yesterday.statusCode == 200) {
      GlobalVariables.yesterdayAQI = yesterday.data['list'][0]['main']['aqi'];
      GlobalVariables.airQualityIndex = respone.data['list'][0]['main']['aqi'];
      return AirPollutionModel.fromJson(respone.data['list'][0]['components']);
    } else {
      throw ApiException();
    }
  }

  @override
  Future<List<AirPollutionModel>> getAirPollutionForecast(
      double lat, double long) async {
    final respone = await dio.get(
        'http://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=${lat}&lon=${long}&appid=${AppKeys.openWeatherMapKey}');

    if (respone.statusCode == 200) {
      AQI.airQualityIndex.clear();

      List<dynamic> listResponeModel = respone.data['list'];
      // List<AirPollutionModel> airPollutionModels = [];

      // for (int i = 0; i < listResponeModel.length; i++) {
      //   airPollutionModels
      //       .add(AirPollutionModel.fromJson(listResponeModel[i]['components']));
      //   AQI.airQualityIndex.add(listResponeModel[i]['main']['aqi']);
      // }

      // return airPollutionModels;

      return listResponeModel
          .map((airPollution) =>
              AirPollutionModel.fromJson(airPollution['components']))
          .toList();
    } else {
      throw ApiException();
    }
  }

  @override
  Future<List<AirPollutionModel>> getAirPollutionHistory(
      double lat, double long, int unixStartDate, int unixEndDate) async {
    final respone = await dio.get(
        'http://api.openweathermap.org/data/2.5/air_pollution/history?lat=${lat}&lon=${long}&start=${unixStartDate}&end=${unixEndDate}&appid=${AppKeys.openWeatherMapKey}');

    if (respone.statusCode == 200) {
      List<dynamic> listResponeModel = respone.data['list'];
      List<AirPollutionModel> airPollutionModels = [];

      for (int i = 0; i < listResponeModel.length; i++) {
        airPollutionModels
            .add(AirPollutionModel.fromJson(listResponeModel[i]['components']));
      }

      return airPollutionModels;
    } else {
      throw ApiException();
    }
  }
}