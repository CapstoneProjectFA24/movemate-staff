import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemate_staff/configs/routes/guard/role_guard.dart';
import 'package:movemate_staff/features/driver/presentation/screen/driver_screen.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/screen/generate_new_job_screen/generate_new_job_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/vehicles_screen/vehicles_available_screen.dart';
import 'package:movemate_staff/features/order/presentation/screen/order_screen.dart';

// guard
import 'package:movemate_staff/configs/routes/guard/auth_guard.dart';

// screen
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_screen.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import 'package:movemate_staff/features/auth/presentation/screens/privacy_term/privacy_screen.dart';
import 'package:movemate_staff/features/auth/presentation/screens/privacy_term/term_screen.dart';
import 'package:movemate_staff/features/auth/presentation/screens/otp_verification/otp_verification_screen.dart';

import 'package:movemate_staff/features/test/presentation/screens/test_screen/test_screen.dart';

import 'package:movemate_staff/features/home/presentation/screens/home_screen.dart';
import 'package:movemate_staff/features/profile/presentation/screens/wallet/wallet_screen.dart';
import 'package:movemate_staff/features/profile/presentation/screens/profile_detail_screen/profile_detail_screen.dart';
import 'package:movemate_staff/features/profile/presentation/screens/info_screen/info_screen.dart';
import 'package:movemate_staff/features/profile/presentation/screens/profile_screen/profile_screen.dart';
import 'package:movemate_staff/features/profile/presentation/screens/contact/contact_screen.dart';

import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_screen/job_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/add_job_screen/add_job_screen.dart';
import 'package:movemate_staff/features/history/presentation/screen/history_screen.dart';

import 'package:movemate_staff/splash_screen.dart';
import 'package:movemate_staff/tab_screen.dart';
// import 'package:movemate_staff/onboarding_screen.dart';

// model
// import 'package:movemate_staff/features/promotion/data/models/promotion_model.dart';

// utils
import 'package:movemate_staff/utils/enums/enums_export.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Route')
class AppRouter extends _$AppRouter {
  final Ref _ref;
  AppRouter({
    required Ref ref,
  }) : _ref = ref;

  @override
  List<AutoRoute> get routes => [
        // auth
        AutoRoute(
          page: SignInScreenRoute.page,
        ),
        AutoRoute(page: SignUpScreenRoute.page),
        AutoRoute(page: OTPVerificationScreenRoute.page),

        //test
        AutoRoute(page: TestScreenRoute.page),

        // Màn hình Onboarding
        // AutoRoute(page: OnboardingScreenRoute.page),

        // Màn hình chính
        AutoRoute(
          page: TabViewScreenRoute.page,
          initial: true,
          guards: [
            // OnboardingGuard(ref: _ref),
            AuthGuard(ref: _ref),
          ],
          // guards: [AuthGuard(ref: _ref)],
          children: [
            AutoRoute(page: HomeScreenRoute.page),
            AutoRoute(page: JobScreenRoute.page),
            AutoRoute(
              page: ProfileScreenRoute.page,
              guards: [
                RoleGuard(_ref, [UserRole.reviewer, UserRole.poster])
              ],
            ),

            // AutoRoute(page: OrderScreenRoute.page),
            // AutoRoute(page: PromotionScreenRoute.page),
            // AutoRoute(page: ProfileScreenRoute.page),
          ],
        ),

        AutoRoute(
          page: ProfileScreenRoute.page,
          guards: [
            RoleGuard(_ref, [UserRole.reviewer, UserRole.poster])
          ],
        ),
        AutoRoute(
          page: ProfileDetailScreenRoute.page,
          guards: [
            RoleGuard(_ref, [UserRole.reviewer, UserRole.poster])
          ],
        ),
        AutoRoute(
          page: InfoScreenRoute.page,
        ),
        //hoàng
        AutoRoute(
          page: JobScreenRoute.page,
        ),
        AutoRoute(
          page: WalletScreenRoute.page,
        ),
        AutoRoute(
          page: ContactScreenRoute.page,
        ),
        AutoRoute(
          page: OrderScreenRoute.page,
        ),
        AutoRoute(
          page: DriverScreenRoute.page,
        ),
        AutoRoute(
          page: GenerateNewJobScreenRoute.page,
        ),
        AutoRoute(
          page: AvailableVehiclesScreenRoute.page,
        ),
        AutoRoute(
          page: ProfileScreenRoute.page,
          guards: [
            RoleGuard(_ref, [UserRole.reviewer, UserRole.poster])
          ],
        ),
      ];
}

final appRouterProvider = Provider((ref) => AppRouter(ref: ref));
