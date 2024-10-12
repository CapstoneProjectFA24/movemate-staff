import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// data impl

// utils
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

part 'profile_source.g.dart';

@RestApi(baseUrl: APIConstants.baseUrl, parser: Parser.MapSerializable)
abstract class ProfileSource {
  factory ProfileSource(Dio dio, {String baseUrl}) = _ProfileSource;
}

@riverpod
ProfileSource profileSource(ProfileSourceRef ref) {
  final dio = ref.read(dioProvider);
  return ProfileSource(dio);
}
