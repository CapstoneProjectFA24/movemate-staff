// rest API
import 'package:dio/dio.dart';
import 'package:movemate_staff/features/test/data/models/house_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// data impl

// utils
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

part 'house_source.g.dart';

@RestApi(baseUrl:
//  APIConstants.baseUrl
 "https://dummyjson.com/c/daa3-02b0-479a-be2d"
 , parser: Parser.MapSerializable)
abstract class HouseSource {
  factory HouseSource(Dio dio, {String baseUrl}) = _HouseSource;

  @GET(APIConstants.get_house_types)
  Future<HttpResponse<HouseResponse>> getHouseType(
    @Header(APIConstants.contentHeader) String contentType,
  );
}

@riverpod
HouseSource houseSource(HouseSourceRef ref) {
  final dio = ref.read(dioProvider);
  return HouseSource(dio);
}
