// import local
import 'package:movemate_staff/features/profile/data/remote/profile_source.dart';
import 'package:movemate_staff/features/profile/domain/repositories/profile_repository.dart';

// utils
import 'package:movemate_staff/utils/resources/remote_base_repository.dart';

class ProfileRepositoryImpl extends RemoteBaseRepository
    implements ProfileRepository {
  final bool addDelay;
  final ProfileSource _profileSource;

  ProfileRepositoryImpl(this._profileSource, {this.addDelay = true});

  // @override
  // Future<HouseResponse> getHouseTypeData() async {
  //   return getDataOf(
  //     request: () => _profileSource.getHouseType(APIConstants.contentType),
  //   );
  // }
}
