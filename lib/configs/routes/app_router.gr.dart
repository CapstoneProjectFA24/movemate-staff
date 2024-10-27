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
    AddJobScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AddJobScreen(),
      );
    },
    AvailableVehiclesScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AvailableVehiclesScreen(),
      );
    },
    BookingScreenServiceRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BookingScreenService(),
      );
    },
    ContactScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContactScreen(),
      );
    },
    DriverScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DriverScreen(),
      );
    },
    GenerateNewJobScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const GenerateNewJobScreen(),
      );
    },
    HistoryScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HistoryScreen(),
      );
    },
    HomeScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    InfoScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InfoScreen(),
      );
    },
    JobDetailsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<JobDetailsScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: JobDetailsScreen(
          key: args.key,
          job: args.job,
        ),
      );
    },
    JobScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const JobScreen(),
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
    OrderScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OrderScreen(),
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
    ProfileDetailScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileDetailScreen(),
      );
    },
    ProfileScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileScreen(),
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
    WalletScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WalletScreen(),
      );
    },
  };
}

/// generated route for
/// [AddJobScreen]
class AddJobScreenRoute extends PageRouteInfo<void> {
  const AddJobScreenRoute({List<PageRouteInfo>? children})
      : super(
          AddJobScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddJobScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AvailableVehiclesScreen]
class AvailableVehiclesScreenRoute extends PageRouteInfo<void> {
  const AvailableVehiclesScreenRoute({List<PageRouteInfo>? children})
      : super(
          AvailableVehiclesScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'AvailableVehiclesScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BookingScreenService]
class BookingScreenServiceRoute extends PageRouteInfo<void> {
  const BookingScreenServiceRoute({List<PageRouteInfo>? children})
      : super(
          BookingScreenServiceRoute.name,
          initialChildren: children,
        );

  static const String name = 'BookingScreenServiceRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContactScreen]
class ContactScreenRoute extends PageRouteInfo<void> {
  const ContactScreenRoute({List<PageRouteInfo>? children})
      : super(
          ContactScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DriverScreen]
class DriverScreenRoute extends PageRouteInfo<void> {
  const DriverScreenRoute({List<PageRouteInfo>? children})
      : super(
          DriverScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'DriverScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [GenerateNewJobScreen]
class GenerateNewJobScreenRoute extends PageRouteInfo<void> {
  const GenerateNewJobScreenRoute({List<PageRouteInfo>? children})
      : super(
          GenerateNewJobScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'GenerateNewJobScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HistoryScreen]
class HistoryScreenRoute extends PageRouteInfo<void> {
  const HistoryScreenRoute({List<PageRouteInfo>? children})
      : super(
          HistoryScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'HistoryScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [InfoScreen]
class InfoScreenRoute extends PageRouteInfo<void> {
  const InfoScreenRoute({List<PageRouteInfo>? children})
      : super(
          InfoScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [JobDetailsScreen]
class JobDetailsScreenRoute extends PageRouteInfo<JobDetailsScreenRouteArgs> {
  JobDetailsScreenRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          JobDetailsScreenRoute.name,
          args: JobDetailsScreenRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'JobDetailsScreenRoute';

  static const PageInfo<JobDetailsScreenRouteArgs> page =
      PageInfo<JobDetailsScreenRouteArgs>(name);
}

class JobDetailsScreenRouteArgs {
  const JobDetailsScreenRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'JobDetailsScreenRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [JobScreen]
class JobScreenRoute extends PageRouteInfo<void> {
  const JobScreenRoute({List<PageRouteInfo>? children})
      : super(
          JobScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'JobScreenRoute';

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
/// [OrderScreen]
class OrderScreenRoute extends PageRouteInfo<void> {
  const OrderScreenRoute({List<PageRouteInfo>? children})
      : super(
          OrderScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'OrderScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [ProfileDetailScreen]
class ProfileDetailScreenRoute extends PageRouteInfo<void> {
  const ProfileDetailScreenRoute({List<PageRouteInfo>? children})
      : super(
          ProfileDetailScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileDetailScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileScreen]
class ProfileScreenRoute extends PageRouteInfo<void> {
  const ProfileScreenRoute({List<PageRouteInfo>? children})
      : super(
          ProfileScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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

/// generated route for
/// [WalletScreen]
class WalletScreenRoute extends PageRouteInfo<void> {
  const WalletScreenRoute({List<PageRouteInfo>? children})
      : super(
          WalletScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'WalletScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
