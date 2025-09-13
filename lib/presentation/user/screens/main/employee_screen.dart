import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/utils/formatter.dart';
import 'package:maktub/data/models/employee.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_bloc.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_event.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_state.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class RegisterEmployeeScreen extends StatefulWidget {
  const RegisterEmployeeScreen({super.key});

  @override
  State<RegisterEmployeeScreen> createState() => _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen>
    with TickerProviderStateMixin {
  bool isPhoneFree = false;

  final TextEditingController _phoneController = TextEditingController(
    text: '+7 7',
  );
  final TextEditingController _nameController = TextEditingController();
  String? selectedRole;
  bool isLoading = false;
  bool isButtonEnabled = false;

  String oldString = "";

  final List<String> phoneCodes = [
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

  

late Map<String, int> roles;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final loc = AppLocalizations.of(context)!;

  roles = {
    'админ': 2,
    loc.receiver: 3,
  };

  final isAdmin = context.read<AppStateCubit>().state!.role == UserRole.admin.name;
  if (isAdmin && selectedRole == null) {
    selectedRole = loc.receiver;
  }
}

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(_onPhoneChanged);
    _nameController.addListener(_updateButtonState);
     final isAdmin = context.read<AppStateCubit>().state!.role == UserRole.admin.name;

  if (isAdmin) {
    selectedRole = 'қабылдаушы';
  }
  }
void _onPhoneChanged() {
  final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
  if (oldString == digits) return;
  oldString = digits;

  final isFull = digits.length == 11 && isValidPhoneCode(digits, phoneCodes);

  if (!isFull) {
    setState(() {
      isPhoneFree = false;
      isButtonEnabled = false;
    });
    return;
  }

  Future.delayed(const Duration(milliseconds: 300), () {
    // если пользователь не вводил новые символы
    if (_phoneController.text.replaceAll(RegExp(r'\D'), '') == digits) {
      context.read<EmployeeBloc>().add(RegisterCheckPhoneExists(digits));
    }
  });
}

  bool isValidPhoneCode(String digits, List<String> phoneCodes) {
    return phoneCodes.any((code) => digits.startsWith(code));
  }

void _updateButtonState() {
  
  final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
  final validPhone =
      phone.length == 11 && phoneCodes.any((code) => phone.startsWith(code));
  final valid =
      validPhone &&
      _nameController.text.isNotEmpty &&
      selectedRole != null &&
      isPhoneFree;

  setState(() {
    isButtonEnabled = valid;
  });
}

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.read<AppStateCubit>().state!.role == UserRole.owner.name;

return BlocListener<EmployeeBloc, EmployeeState>(
listener: (context, state) {
  if(state is EmployeeAddedSuccess){
    context.pop(true);
  }
  if (state is RegisterPhoneExists) {
    showTopSnackbar(
      context: context,
      vsync: this,
      message: "Бұл нөмір тіркелген",
      isError: true,
      withLove: false,
    );
    setState(() {
      isPhoneFree = false;
      isButtonEnabled = false;
    });
  } else if (state is RegisterPhoneNotFound) {
    setState(() {
      isPhoneFree = true;
    });
    _updateButtonState();
  }else if(state is EmployeeAddedSuccess){
        showTopSnackbar(
      context: context,
      vsync: this,
      message: "Қызметкер сәтті тіркелді",
      isError: false,
      withLove: false,
    );
  }else if(state is EmployeeFailure){

    showTopSnackbar(
      context: context,
      vsync: this,
      message: state.message,
      isError: true,
      withLove: false,
    );
  }
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(AppLocalizations.of(context)!.enterPhoneNumber, style: title),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    AppLocalizations.of(context)!.weUseEmployeePhone,
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
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.fullName,
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
                ),
                         if(isOwner)
                const SizedBox(height: 16),
              if(isOwner)
                Row(
                  children: roles.keys.map((role) {
                    final isSelected = selectedRole == role;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRole = role;
                              _updateButtonState();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE4F7E9)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Gradients.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                role,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        
                const SizedBox(height:16),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          final appState = context.read<AppStateCubit>().state!;
                          final regionId = appState.regionId;
                          final workplaceId = appState.workplaceId;
                          final fullName = _nameController.text.trim();
                          final phone = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                           int roleId = roles[selectedRole]!;
                        
                          
                    

                          final employee = Employee(
                            phone: phone,
                            fullName: fullName,
                            regionId: regionId,
                            roleId: roleId,
                            workplaceId: workplaceId,
                          );

                          context.read<EmployeeBloc>().add(
                            AddEmployee(employee: employee, phone: phone),
                          );

                          setState(() => isLoading = true);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
