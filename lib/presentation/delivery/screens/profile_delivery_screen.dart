import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/main.dart';
import 'package:maktub/presentation/blocs/auth/auth_bloc.dart';
import 'package:maktub/presentation/blocs/auth/auth_event.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDeliverScreen extends StatelessWidget {
  const ProfileDeliverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateCubit>().state;
    final isGuest = appState == null || appState.role == UserRole.guest.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'профиль',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        children: [
          // const SizedBox(height: 8),

          // --- Block: Guest or User ---
          if (isGuest)
            _GuestHeader()
          else
            _UserHeader(fullName: appState.fullName),

          // const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          Text( AppLocalizations.of(context)!.info,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),


          _InfoTile(
            title:AppLocalizations.of(context)!.languageSettings ,
            onTap: () {
              showLanguageDialog(
                context: context,

                onKazakhPressed: () {
                  setLocale(context, Locale('kk'));
                  context.pop();
                },
                onRussianPressed: () {
                  setLocale(context, Locale('ru'));
                  context.pop();
                },
              );
            },
          ),
          if(!isGuest)
          _InfoTile(
            title: AppLocalizations.of(context)!.deleteAccount,
            onTap: () {
              showMaktubDialog(
                context: context,
                title: AppLocalizations.of(context)!.accountDeletion,
                content:
                    AppLocalizations.of(context)!.accountDeleteInstruction,
                onPressed: () {
                  context.pop();
                },
              );
            },
          ),
          if(!isGuest)
          _InfoTile(
            title: AppLocalizations.of(context)!.logoutFromAccount,
            onTap: () {
              showMaktubLogoutDialog(
                context: context,
                title: AppLocalizations.of(context)!.logoutFromAccount,
                content: AppLocalizations.of(context)!.logoutConfirmation,

                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  context.go(RouteNames.splash);
                },
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> showLanguageDialog({
    required BuildContext context,
    required VoidCallback onKazakhPressed,
    required VoidCallback onRussianPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.25),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Colors.blueGrey.withOpacity(0.9),
                    width: 0.3,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _LanguageButton(
                          label: 'қазақша',

                          onTap: onKazakhPressed,
                        ),
                        const SizedBox(width: 12),
                        _LanguageButton(
                          label: 'русский',

                          onTap: onRussianPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void setLocale(BuildContext context, Locale newLocale) {
    MaktubApp.setLocale(context, newLocale);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString('locale', newLocale.languageCode),
    );
  }

  Future<void> showMaktubLogoutDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onPressed,

    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3), // Затемнение фона
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.25),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Colors.blueGrey.withOpacity(0.9),
                    width: 0.3,
                  ),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: Text(
                  content,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.redAccent,
                        ),
                        minimumSize: WidgetStateProperty.all(
                          const Size(double.infinity, 50),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showMaktubDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onPressed,

    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3), // Затемнение фона
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.25),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Colors.blueGrey.withOpacity(0.9),
                    width: 0.3,
                  ),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: Text(
                  content,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          Gradients.primary,
                        ),
                        minimumSize: WidgetStateProperty.all(
                          const Size(double.infinity, 50),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;

  final VoidCallback onTap;

  const _LanguageButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Gradients.primary),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.welcome,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.welcomeDesc,
          textAlign: TextAlign.center,

          style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.push(RouteNames.login);
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            enableFeedback: false,
            overlayColor: Colors.transparent,
            shadowColor: Colors.transparent,
            backgroundColor: Gradients.primary,
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.loginToProfile,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String fullName;

  const _UserHeader({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Gradients.primary, width: 0.5),
        ),
        child: CircleAvatar(
          backgroundColor: Gradients.primary.withOpacity(0.1),
          child: Icon(Icons.person, color: Gradients.primary),
        ),
      ),
      title: Text(
        fullName,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
    
      // trailing: const Icon(Icons.chevron_right),

    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _InfoTile({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          color: Gradients.mainTextColor,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
      onTap: onTap,
    );
  }
}
