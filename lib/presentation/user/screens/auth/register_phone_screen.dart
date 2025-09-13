// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

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
import 'package:maktub/presentation/blocs/register/register_bloc.dart';
import 'package:maktub/presentation/blocs/register/register_event.dart';
import 'package:maktub/presentation/blocs/register/register_state.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class RegisterPhoneScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RegisterPhoneScreen({super.key, required this.data});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen>
    with TickerProviderStateMixin {
  bool hasAlreadyChecked = false;
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

  late final String fullName;
  late final String workplaceId;
  late final String workplaceName;

  @override
  void initState() {
    super.initState();

    fullName = widget.data['fullName'];
    workplaceId = widget.data['workplaceId'].replaceAll(RegExp(r'\D'), '');
    workplaceName = widget.data['workplaceName'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showTopSnackbar(
          context: context,
          vsync: this,
          message: "бұл нөмір жүйеде тіркелген. басқа нөмір еңгізіңіз",
          isError: true,
          withLove: false,
        );
      }
    });

    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');

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
          message: "нөмірді дұрыс еңгізіңіз",
          isError: true,
          withLove: false,
        );
      }
      if (digits.length == 11 && isValidPhoneCode(digits, phoneCodes)) {
        context.read<RegisterBloc>().add(
          RegisterCheckPhoneExists(digits, fromManualPhoneScreen: true),
        );
      }
    });
  }

  bool isValidPhoneCode(String digits, List<String> phoneCodes) {
    return phoneCodes.any((code) => digits.startsWith(code));
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.data['fullName'];
    final ownerName=  widget.data['ownerName'];
    final workplaceId = widget.data['workplaceId'].replaceAll(
      RegExp(r'\D'),
      '',
    );
    final workplaceName = widget.data['workplaceName'];

    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) async {
            if (state is RegisterPhoneNotFound) {
              if (!mounted) return;
              setState(() {
                isButtonEnabled = true;
              });
            } else if (state is RegisterPhoneExists) {
              if (!mounted) return;
             
            } else if (state is RegisterOtpSent) {
          
              showOtpBottomSheet(state.otp);
            } else if (state is RegisterLoading) {
            } else if (state is RegisterUserSuccess) {
              context.read<AuthBloc>().add(AuthLogin(state.phone));
            } else if (state is RegisterPhoneVerified) {

              context.read<RegisterBloc>().add(
                RegisterOrganization(
                  ownerName: ownerName,
                  organizationId: workplaceId,
                  name: workplaceName,
                  phoneNumber: _phoneController.text.replaceAll(
                    RegExp(r'\D'),
                    '',
                  ),
                  fromManualPhoneScreen: true,
                ),
              );
            } else if (state is OrganizationRegisterSuccess) {
     
              context.read<RegisterBloc>().add(
                RegisterUser(
                  phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
                  workplaceId: state.organizationId,
                  roleId: 1,
                  fullName: fullName,
                  fromManualPhoneScreen: true,
                  regionId: 1
                ),
              );
            } else if (state is RegisterFailure) {
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
            }else if(state is AuthSuccess){
                        context.pop();
                                      Future.delayed(Duration.zero, () {
                           context.go(RouteNames.home); 
                                      });
            }
            if (!mounted) return;
            setState(() {
              isLoading = state is RegisterLoading;
            });
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go(RouteNames.home);
            }
            if (!mounted) return;
            setState(() {
              isLoading = state is AuthLoading;
            });
          },
        ),
      ],
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
                    AppLocalizations.of(context)!.phoneNumberExplanation,
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
                  onPressed:
                      isButtonEnabled
                          ? () {
                            context.read<RegisterBloc>().add(
                              RegisterSendOtp(
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
                  child:
                      isLoading
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
                              color:
                                  isButtonEnabled
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
                                color:
                                    isOtpIncorrect
                                        ? Gradients.error
                                        : const Color(0xFFe5e5e5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color:
                                    isOtpIncorrect
                                        ? Gradients.error
                                        : Gradients.primary,
                              ),
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              isOtpButtonEnabled
                                  ? () {
                                    if (_otpController.text == otp) {
                                      context.read<RegisterBloc>().add(
                                        RegisterPhoneWasVerified(),
                                      );
                                      if (mounted && context.canPop()) {
                                        context.pop();
                                      }
                                    } else {
                                      setState(() {
                                        isOtpIncorrect =
                                            true; // только если ошибка!
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
                            AppLocalizations.of(context)!.continueB,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color:
                                  isOtpButtonEnabled
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
