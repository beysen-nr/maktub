import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/core/utils/formatter.dart';
import 'package:maktub/presentation/blocs/auth/auth_bloc.dart';
import 'package:maktub/presentation/blocs/auth/auth_event.dart';
import 'package:maktub/presentation/blocs/auth/auth_state.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController(
    text: '+7 7',
  );

  String oldString = "";

  bool isButtonEnabled = false;
  bool isLoading = false;

  List<String> phoneCodes = [
    '7700',
    '7701',
    '7702',
    '7705',
    '7706',
    '7707',
    '7708',
    '7747',
    '7771',
    '7775',
    '7776',
    '7777',
    '7778',
  ];
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (digits == '77777777777') {
      context.read<AuthBloc>().add(IsDevMode(digits));
      return;
    }
    if (oldString == digits) return;
    setState(() {
      if (oldString != digits) {
        isButtonEnabled = false;
      }
      oldString = digits;
      if (digits.length == 11 && !isValidPhoneCode(digits, phoneCodes)) {
        showTopSnackbar(
          context: context,
          vsync: this,
          message: AppLocalizations.of(context)!.enterTheNumberCorrectly,
          isError: true,
          withLove: false,
        );
      }
      if (digits.length == 11 && isValidPhoneCode(digits, phoneCodes)) {
        context.read<AuthBloc>().add(AuthCheckPhoneExists(digits));
      }
    });
  }

  bool isValidPhoneCode(String digits, List<String> phoneCodes) {
    return phoneCodes.any((code) => digits.startsWith(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is DevMode) {
          context.read<AuthBloc>().add(AuthLogin('77779477797'));
          showTopSnackbar(
            context: context,
            vsync: this,
            message: 'devmode is turned on. welcome to the app.',
            isError: false,
            withLove: true,
          );
        }
        if (state is AuthPhoneNotFound) {
          showTopSnackbar(
            context: context,
            vsync: this,
            message: AppLocalizations.of(context)!.phoneNotRegistered,
            isError: true,
            withLove: false,
          );
          setState(() {
            isButtonEnabled = false;
          });
        } else if (state is AuthSuccess) {
          // context.read<AppStateCubit>().setFromAuthSuccess(state);

          Future.delayed(Duration.zero, () {
            context.go(RouteNames.splash);
          });
        } else if (state is AuthPhoneExists) {
          showTopSnackbar(
            context: context,
            vsync: this,
            message: '${AppLocalizations.of(context)!.loginWelcome} ${state.name}',
            isError: false,
            withLove: true,
          );
          setState(() {
            isButtonEnabled = true;
          });
        } else if (state is AuthOtpSending) {
        } else if (state is AuthOtpSent) {
          showOtpBottomSheet(state.otp);
        } else if (state is AuthOtpSending) {
        } else if (state is AuthFailure) {
          if (state.isBlocked == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
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
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            );
         
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.errorTryLater,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            );
          }
        }
        setState(() {
          isLoading = state is AuthLoading || state is AuthOtpSending;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(height: 24),

                Text(AppLocalizations.of(context)!.entryNumber, style: title),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    AppLocalizations.of(context)!.phoneNumberExplanation
                    ,
                    textAlign: TextAlign.center,
                    style: subtitle,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: 'XXX XXX XX XX',
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFe5e5e5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.primary),
                    ),
                  ),
                  inputFormatters: [PhoneInputFormatter()],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          
                          context.read<AuthBloc>().add(
                            AuthSendOtp(
                              _phoneController.text.replaceAll(
                                RegExp(r'\D'),
                                '',
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      isButtonEnabled
                          ? Gradients.primary
                          : const Color(0xFFd4f2d6),
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
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 25,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.continueB,
                          style: GoogleFonts.montserrat(
                            color: isButtonEnabled
                                ? Colors.white
                                : const Color(0xFFa9e4ac),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push(RouteNames.register),
                  child: Text(
                    AppLocalizations.of(context)!.dontHaveMaktub,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Gradients.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      decorationColor: Gradients.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showOtpBottomSheet(String otp) {
    final TextEditingController _otpController = TextEditingController();
    bool isOtpButtonEnabled = false;
    bool isOtpIncorrect = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _otpController.addListener(() {
              final cleaned = _otpController.text.replaceAll(
                RegExp(r'\s+'),
                '',
              );
              if (cleaned != _otpController.text) {
                _otpController.text = cleaned;
                _otpController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _otpController.text.length),
                );
              }

              setState(() {
                if (_otpController.text.length == 4 &&
                    _otpController.text != otp) {
                  isOtpIncorrect = true;
                }
                isOtpButtonEnabled =
                    _otpController.text.length == 4 &&
                    _otpController.text == otp;
                isOtpIncorrect = false; // сбрасываем ошибку при новом вводе
              });
            });

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.codeViaWhatsapp,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,

                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'код',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                            counterText: '',

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isOtpIncorrect
                                    ? Gradients.error
                                    : const Color(0xFFe5e5e5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isOtpIncorrect
                                    ? Gradients.error
                                    : Gradients.primary,
                              ),
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isOtpButtonEnabled
                              ? () {
                                  FocusScope.of(context).unfocus();
                                  if (_otpController.text == otp) {
                                    context.read<AuthBloc>().add(
                                      AuthLogin(
                                        _phoneController.text.replaceAll(
                                          RegExp(r'\D'),
                                          '',
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isOtpIncorrect = false;
                                    });
                                  }
                                }
                              : null,
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(0),
                            backgroundColor: WidgetStateProperty.all(
                              isOtpButtonEnabled
                                  ? Gradients.primary
                                  : const Color(0xFFd4f2d6),
                            ),
                            minimumSize: WidgetStateProperty.all(
                              const Size(double.infinity, 50),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.apply,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: isOtpButtonEnabled
                                  ? Colors.white
                                  : const Color(0xFFa9e4ac),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                 
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}

Route slideFromRight(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // справа
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
