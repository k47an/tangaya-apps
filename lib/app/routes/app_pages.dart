import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/admin/views/components/orderView.dart';
import 'package:tangaya_apps/app/modules/payment/bindings/payment_binding.dart';
import 'package:tangaya_apps/app/modules/payment/views/payment_view.dart';
import 'package:tangaya_apps/app/modules/admin/bindings/admin_binding.dart';
import 'package:tangaya_apps/app/modules/admin/views/admin_view.dart';
import 'package:tangaya_apps/app/modules/auth/bindings/auth_binding.dart';
import 'package:tangaya_apps/app/modules/auth/views/signIn_view.dart';
import 'package:tangaya_apps/app/modules/details/bindings/detail_binding.dart';
import 'package:tangaya_apps/app/modules/details/views/detail_view.dart';
import 'package:tangaya_apps/app/modules/home/bindings/home_binding.dart';
import 'package:tangaya_apps/app/modules/home/views/home_view.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/bindings/manage_tour_event_binding.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/manage_tour_event_view.dart';
import 'package:tangaya_apps/app/modules/notification/bindings/notification_binding.dart';
import 'package:tangaya_apps/app/modules/notification/views/notification_view.dart';
import 'package:tangaya_apps/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:tangaya_apps/app/modules/onboarding/views/onboarding_view.dart';
import 'package:tangaya_apps/app/modules/onboarding/views/welcome_view.dart';
import 'package:tangaya_apps/app/modules/profile/bindings/profile_binding.dart';
import 'package:tangaya_apps/app/modules/profile/views/profile_view.dart';
import 'package:tangaya_apps/app/modules/splash/bindings/splash_binding.dart';
import 'package:tangaya_apps/app/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SIGNIN,
      page: () => const SignInView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.ORDERVIEW,
      page: () => const OrderView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_EVENT_TOUR,
      page: () => const ManageTourEventView(),
      binding: ManageTourEventBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL,
      page: () => const DetailView(),
      binding: DetailPackBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
  ];
}
