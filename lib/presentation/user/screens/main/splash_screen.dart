import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/presentation/blocs/auth/auth_bloc.dart';
import 'package:maktub/presentation/blocs/auth/auth_event.dart';
import 'package:maktub/presentation/blocs/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _readyToNavigate = false;
  AuthState? _latestState;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AppStarted());

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _readyToNavigate = true);
      _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (!_readyToNavigate || _latestState == null) return;

    if (_latestState is AuthAuthenticated) {
      final auth = _latestState as AuthAuthenticated;
      context.read<AppStateCubit>().setFromAuth(auth);
      final role = (_latestState as AuthAuthenticated).role;
      if (((_latestState as AuthAuthenticated).isActive) == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountWasBeenBlocked,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.redAccent,
            elevation: 0,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );

        context.read<AuthBloc>().add(AuthLogoutRequested());

        context.go(RouteNames.splash);
        return;
      }
      switch (role) {
        case UserRole.owner:
          context.go(RouteNames.home);
          break;
        case UserRole.admin:
          context.go(RouteNames.home);
          break;
        case UserRole.receiver:
          context.go(RouteNames.receiverOrder);
          break;
        case UserRole.guest:
          context.go(RouteNames.home);
          break;
        case UserRole.supplier:
        case UserRole.delivery:
      context.go(RouteNames.deliveryOrder);
          break;
              }
    } else if (_latestState is AuthGuest) {
      context.read<AppStateCubit>().emit(
        AppState(
          ownerName: '',
          organizationName: '',
          isActive: true,
          regionId: 1,
          phone: '',
          workplaceId: 0,
          fullName: '',
          role: UserRole.guest.name,
          cityName: 'астана',
        ),
      );
      context.go(RouteNames.home);
    } else if (_latestState is AuthFailure) {
      context.read<AuthBloc>().add(AppStarted());
    }
  }

  Color lighten(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighter.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _latestState = state;
        _maybeNavigate();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Shimmer.fromColors(
              baseColor: Gradients.primary,
              highlightColor: lighten(Gradients.primary, 0.5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'maktub',
                  style: TextStyle(fontFamily: 'AudreyScript', fontSize: 96),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
