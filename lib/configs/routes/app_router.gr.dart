// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    HomeScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    OTPVerificationScreenRoute.name: (routeData) {
      final args = routeData.argsAs<OTPVerificationScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OTPVerificationScreen(
          key: args.key,
          phoneNumber: args.phoneNumber,
          verifyType: args.verifyType,
        ),
      );
    },
    PrivacyPolicyScreenRoute.name: (routeData) {
      final args = routeData.argsAs<PrivacyPolicyScreenRouteArgs>(
          orElse: () => const PrivacyPolicyScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PrivacyPolicyScreen(key: args.key),
      );
    },
    SignInScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SignInScreenRouteArgs>(
          orElse: () => const SignInScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignInScreen(key: args.key),
      );
    },
    SignUpScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SignUpScreenRouteArgs>(
          orElse: () => const SignUpScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignUpScreen(key: args.key),
      );
    },
    SplashScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TabViewScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabViewScreen(),
      );
    },
    TermOfUseScreenRoute.name: (routeData) {
      final args = routeData.argsAs<TermOfUseScreenRouteArgs>(
          orElse: () => const TermOfUseScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TermOfUseScreen(key: args.key),
      );
    },
    TestScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TestScreen(),
      );
    },
  };
}

/// generated route for
/// [HomeScreen]
class HomeScreenRoute extends PageRouteInfo<void> {
  const HomeScreenRoute({List<PageRouteInfo>? children})
      : super(
          HomeScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OTPVerificationScreen]
class OTPVerificationScreenRoute
    extends PageRouteInfo<OTPVerificationScreenRouteArgs> {
  OTPVerificationScreenRoute({
    Key? key,
    required String phoneNumber,
    required VerificationOTPType verifyType,
    List<PageRouteInfo>? children,
  }) : super(
          OTPVerificationScreenRoute.name,
          args: OTPVerificationScreenRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
            verifyType: verifyType,
          ),
          initialChildren: children,
        );

  static const String name = 'OTPVerificationScreenRoute';

  static const PageInfo<OTPVerificationScreenRouteArgs> page =
      PageInfo<OTPVerificationScreenRouteArgs>(name);
}

class OTPVerificationScreenRouteArgs {
  const OTPVerificationScreenRouteArgs({
    this.key,
    required this.phoneNumber,
    required this.verifyType,
  });

  final Key? key;

  final String phoneNumber;

  final VerificationOTPType verifyType;

  @override
  String toString() {
    return 'OTPVerificationScreenRouteArgs{key: $key, phoneNumber: $phoneNumber, verifyType: $verifyType}';
  }
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyScreenRoute
    extends PageRouteInfo<PrivacyPolicyScreenRouteArgs> {
  PrivacyPolicyScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          PrivacyPolicyScreenRoute.name,
          args: PrivacyPolicyScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'PrivacyPolicyScreenRoute';

  static const PageInfo<PrivacyPolicyScreenRouteArgs> page =
      PageInfo<PrivacyPolicyScreenRouteArgs>(name);
}

class PrivacyPolicyScreenRouteArgs {
  const PrivacyPolicyScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'PrivacyPolicyScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SignInScreen]
class SignInScreenRoute extends PageRouteInfo<SignInScreenRouteArgs> {
  SignInScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignInScreenRoute.name,
          args: SignInScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignInScreenRoute';

  static const PageInfo<SignInScreenRouteArgs> page =
      PageInfo<SignInScreenRouteArgs>(name);
}

class SignInScreenRouteArgs {
  const SignInScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignInScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SignUpScreen]
class SignUpScreenRoute extends PageRouteInfo<SignUpScreenRouteArgs> {
  SignUpScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignUpScreenRoute.name,
          args: SignUpScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignUpScreenRoute';

  static const PageInfo<SignUpScreenRouteArgs> page =
      PageInfo<SignUpScreenRouteArgs>(name);
}

class SignUpScreenRouteArgs {
  const SignUpScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignUpScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashScreenRoute extends PageRouteInfo<void> {
  const SplashScreenRoute({List<PageRouteInfo>? children})
      : super(
          SplashScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TabViewScreen]
class TabViewScreenRoute extends PageRouteInfo<void> {
  const TabViewScreenRoute({List<PageRouteInfo>? children})
      : super(
          TabViewScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'TabViewScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TermOfUseScreen]
class TermOfUseScreenRoute extends PageRouteInfo<TermOfUseScreenRouteArgs> {
  TermOfUseScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          TermOfUseScreenRoute.name,
          args: TermOfUseScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'TermOfUseScreenRoute';

  static const PageInfo<TermOfUseScreenRouteArgs> page =
      PageInfo<TermOfUseScreenRouteArgs>(name);
}

class TermOfUseScreenRouteArgs {
  const TermOfUseScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'TermOfUseScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [TestScreen]
class TestScreenRoute extends PageRouteInfo<void> {
  const TestScreenRoute({List<PageRouteInfo>? children})
      : super(
          TestScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
