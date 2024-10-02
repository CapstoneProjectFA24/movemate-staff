// import local
import 'package:movemate_staff/features/test/data/models/house_response.dart';
import 'package:movemate_staff/features/test/data/remote/house_source.dart';
import 'package:movemate_staff/features/test/domain/repositories/house_type_repository.dart';

// utils
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/resources/remote_base_repository.dart';
import 'package:retrofit/dio.dart';

class HouseTypeRepositoryImpl extends RemoteBaseRepository
    implements HouseTypeRepository {
  final bool addDelay;
  final HouseSource _houseSource;

  HouseTypeRepositoryImpl(this._houseSource, {this.addDelay = true});

  @override
  Future<HouseResponse> getHouseTypeData() async {
    return getDataOf(
      request: () => _houseSource.getHouseType(APIConstants.contentType),
    );
  }
}
