import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';


class SignInButton extends ConsumerWidget {
  final bool isFromLogin;

  const SignInButton({super.key, this.isFromLogin = true});

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    return ElevatedButton.icon(
      onPressed: () => signInWithGoogle(context, ref),
      icon: Image.asset(
        Constants.googlePath,
        width: 35,
      ),
      label: Text(
        'Continue with Google',
        style: TextStyle(
          fontSize: 18, 
          color: currentTheme.colorScheme.onSurface,
        ),
      ),
       style: ElevatedButton.styleFrom(
          backgroundColor: currentTheme.colorScheme.secondary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
    );
  }
}
