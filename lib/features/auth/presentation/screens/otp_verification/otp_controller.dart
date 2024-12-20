import 'package:flutter/material.dart';
import 'package:movemate_staff/features/auth/data/models/request/sign_up_request.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

// config
import 'package:movemate_staff/configs/routes/app_router.dart';

// domain - data
import 'package:movemate_staff/features/auth/data/models/request/otp_verify_request.dart';
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';

// utils
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';

part 'otp_controller.g.dart';

@riverpod
class OtpController extends _$OtpController {
  late final FirebaseAuth firebaseAuth;

  @override
  FutureOr<void> build() {
    firebaseAuth = FirebaseAuth.instance;
  }

  Future<void> verifyOTP({
    required BuildContext context,
    required String otpSms,
  }) async {
    state = const AsyncLoading();

    final verificationId =
        await SharedPreferencesUtils.getVerificationId("verificationId");

    try {
      if (verificationId == null) {
        throw Exception(
            'Không tìm thấy verificationId trong SharedPreferences');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpSms,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        registerAndSignIn(context, idToken);
      } else {
        throw Exception('Không lấy được idToken từ người dùng');
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        print('Firebase Error Code: ${e.code}');
      }
      showSnackBar(
        context: context,
        content: 'Xác thực OTP không thành công: ${e.toString()}',
        icon: AssetsConstants.iconError,
        backgroundColor: Colors.red,
        textColor: AssetsConstants.whiteColor,
      );
    }
  }

  Future<void> registerAndSignIn(BuildContext context, String idToken) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final userInfo =
        await SharedPreferencesUtils.getSignInRequestInfo('sign-up');

    final requestRegister = SignUpRequest(
      email: userInfo!.email,
      name: userInfo.name,
      phone: formatPhoneNumber(userInfo.phone),
      password: userInfo.password,
    );

    state = await AsyncValue.guard(() async {
      await authRepository.verifyToken(
          request: OTPVerifyRequest(idToken: idToken));

      final user = await authRepository.signUpAndRes(request: requestRegister);

      final userModel = UserModel(
        id: user.payload.id,
        roleName: user.payload.roleName,
        email: user.payload.email,
        roleId: user.payload.roleId,
        name: user.payload.name,
        avatarUrl: user.payload.avatarUrl,
        gender: user.payload.gender,
        phone: user.payload.phone,
        tokens: user.payload.tokens,
      );

      ref.read(authProvider.notifier).update(
            (state) => userModel,
          );
      await SharedPreferencesUtils.setInstance(
        userModel,
        'user_token',
      );

      context.router.replaceAll([const TabViewScreenRoute()]);
    });

    if (state.hasError) {
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        handleAPIError(
          statusCode: statusCode,
          stateError: state.error!,
          context: context,
        );
      }
    }
  }
}
