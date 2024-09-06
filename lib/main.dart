import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/firebase_options.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/router.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final userModelProvider = StateProvider<UserModel?>((ref) => null);
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    final userData = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userModelProvider.notifier).state = userData;
    ref.read(userProvider.notifier).update((state) => userData);
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);

    return ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              getData(ref, data);

              if (userModel != null) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Reddit',
                  theme: ref.watch(themeNotifierProvider),
                  routerDelegate:
                      RoutemasterDelegate(routesBuilder: (_) => loggedInRoute),
                  routeInformationParser: const RoutemasterParser(),
                );
              }
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Reddit',
              theme: Pallete.darkModeAppTheme,
              routerDelegate:
                  RoutemasterDelegate(routesBuilder: (_) => loggedOutRoute),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),

        );
  }
}
