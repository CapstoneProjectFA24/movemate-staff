import 'package:movemate_staff/features/auth/data/models/request/register_token_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// data impl
import 'package:movemate_staff/features/auth/data/remote/auth_source.dart';
import 'package:movemate_staff/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movemate_staff/features/auth/data/models/response/account_response.dart';
import 'package:movemate_staff/features/auth/data/models/request/sign_in_request.dart';
import 'package:movemate_staff/features/auth/data/models/request/sign_up_request.dart';
import 'package:movemate_staff/features/auth/data/models/request/otp_verify_request.dart';

// model system
import 'package:movemate_staff/models/response/success_model.dart';
import 'package:movemate_staff/models/token_model.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<SuccessModel> signUp({required SignUpRequest request});

  Future<AccountReponse> signIn({required SignInRequest request});

  Future<TokenModel> generateToken({required TokenModel request});

  Future<SuccessModel> checkValidUser({required SignUpRequest request});

  Future<SuccessModel> verifyToken({required OTPVerifyRequest request});

  Future<AccountReponse> signUpAndRes({required SignUpRequest request});

  Future<SuccessModel> registerFcmToken(
      {required RegisterTokenRequest request, required String accessToken});

  Future<SuccessModel> deleteFcmToken({required int id});

  Future<void> signOut();
}

@Riverpod(keepAlive: false)
AuthRepository authRepository(AuthRepositoryRef ref) {
  final authSource = ref.read(authSourceProvider);
  return AuthRepositoryImpl(authSource);
}
