// import local
import 'package:movemate_staff/features/profile/data/models/response/profile_response.dart';
import 'package:movemate_staff/features/profile/data/remote/profile_source.dart';
import 'package:movemate_staff/features/profile/domain/repositories/profile_repository.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';

// utils
import 'package:movemate_staff/utils/resources/remote_base_repository.dart';

class ProfileRepositoryImpl extends RemoteBaseRepository
    implements ProfileRepository {
  final bool addDelay;
  final ProfileSource _profileSource;

  ProfileRepositoryImpl(this._profileSource, {this.addDelay = true});

  @override
  Future<ProfileResponse> getUserInfo({
    required String accessToken,
    required int id,
  }) async {
    return getDataOf(
      request: () =>
          _profileSource.getUserInfo(APIConstants.contentType, accessToken, id),
    );
  }
}
