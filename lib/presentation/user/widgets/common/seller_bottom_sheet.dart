import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/utils/formatter.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/widgets/common/time_slot_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showSupplierBottomSheet(
  BuildContext context, {
  String? bin,
  String? name,
}) {
  final TextEditingController binController = TextEditingController(
    text: bin ?? '',
  );
  final TextEditingController nameController = TextEditingController(
    text: name ?? '',
  );

  final TextEditingController contactsController = TextEditingController();
  final TextEditingController productsController = TextEditingController();

  String selectedSlot = '09:00-11:00'; // начальное значение

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        maxChildSize: 0.94,
        minChildSize: 0.7,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool isButtonEnabled =
                  nameController.text.isNotEmpty &&
                  binController.text.isNotEmpty &&
                  contactsController.text.isNotEmpty &&
                  productsController.text.isNotEmpty;

              void validate() {
                setState(() {
                  isButtonEnabled =
                      nameController.text.isNotEmpty &&
                      binController.text.isNotEmpty &&
                      contactsController.text.isNotEmpty &&
                      productsController.text.isNotEmpty;
                });
              }

              binController.addListener(validate);
              contactsController.addListener(validate);
              productsController.addListener(validate);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context)!.registerOrganization, style: title),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.weWillContact,
                            textAlign: TextAlign.center,
                            style: subtitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [IinInputFormatter()],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.organizationIinBin,
                          hintStyle: hint,

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: binController,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.organizationName,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contactsController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [PhoneInputFormatter()],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contactPhoneNumber,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: productsController,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.productType,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TimeSlotSelector(
                        onSlotSelected: (slot) {
                          selectedSlot = slot;
                        },
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () async {
                                final data = {
                                  'name': binController.text.trim(),
                                  'bin': nameController.text.trim(),
                                  'contact_phone': contactsController.text
                                      .trim(),
                                  'product_type': productsController.text
                                      .trim(),
                                  'time_slot': selectedSlot,
                                };

                                await Supabase.instance.client
                                    .from('supplier_regs')
                                    .insert(data);

                                                     ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                //  AppLocalizations.of(context)!.thanksForReview,
                               AppLocalizations.of(context)!.weWillOnContact,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Gradients.primary,
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

                                context.pop();
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
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.send,
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
              );
            },
          );
        },
      );
    },
  );
}

void showRegisterSupplierBottomSheet(
  BuildContext context, {
  String? bin,
  String? name,
}) {
  final TextEditingController binController = TextEditingController(
    text: bin ?? '',
  );


  final TextEditingController contactsController = TextEditingController();


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        maxChildSize: 0.94,
        minChildSize: 0.7,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool isButtonEnabled =
 
                  binController.text.isNotEmpty &&
                  contactsController.text.isNotEmpty;

              void validate() {
                setState(() {
                  isButtonEnabled =
                
                      binController.text.isNotEmpty &&
                      contactsController.text.isNotEmpty;
                });
              }

              binController.addListener(validate);
              contactsController.addListener(validate);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(textAlign: TextAlign.center, AppLocalizations.of(context)!.registerSupplier, style: title),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Center(
                          child: Text(
                    AppLocalizations.of(context)!.regSupplierDesc,
                            textAlign: TextAlign.center,
                            style: subtitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
               TextField(
                        controller: binController,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.organizationName,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contactsController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [PhoneInputFormatter()],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contactPhoneNumber,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
        

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () async {
                              int? orgId = context.read<AppStateCubit>().state?.workplaceId;
                                final data = {
                                  'name': binController.text.trim(),
                                  
                                  'contact_phone': contactsController.text
                                      .trim(),
                                 
                            
                                  'workplace_id':orgId
                                };

                                await Supabase.instance.client
                                    .from('supplier_regs')
                                    .insert(data);

                                                     ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                            AppLocalizations.of(context)!.weWillOnContact,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Gradients.primary,
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

                                context.pop();
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
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.send,
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
              );
            },
          );
        },
      );
    },
  );
}

void showOrganizationBottomSheet(
  BuildContext context, {
  String? bin,
  String? name,
}) {
  final TextEditingController binController = TextEditingController(
    text: bin ?? '',
  );
  final TextEditingController nameController = TextEditingController(
    text: name ?? '',
  );

  final TextEditingController contactsController = TextEditingController();
  String selectedSlot = '09:00-11:00'; //

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        maxChildSize: 0.94,
        minChildSize: 0.7,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool isButtonEnabled =
                  nameController.text.isNotEmpty &&
                  binController.text.isNotEmpty &&
                  contactsController.text.isNotEmpty;
              void validate() {
                setState(() {
                  isButtonEnabled =
                      nameController.text.isNotEmpty &&
                      binController.text.isNotEmpty &&
                      contactsController.text.isNotEmpty;
                });
              }

              binController.addListener(validate);
              contactsController.addListener(validate);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context)!.registerOrganization, style: title),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.weWillContactCustomer,
                            textAlign: TextAlign.center,
                            style: subtitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [IinInputFormatter()],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.organizationIinBin,
                          hintStyle: hint,

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: binController,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.organizationName,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contactsController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [PhoneInputFormatter()],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contactPhoneNumber,
                          hintStyle: hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Gradients.primary,
                            ),
                          ),
                        ),
                      ),
               const SizedBox(height: 16),
                      TimeSlotSelector(
                        onSlotSelected: (slot) {
                          selectedSlot = slot;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () async {
                                       final data = {
                                  'name': binController.text.trim(),
                                  'bin': cleanName(nameController.text.trim()),
                                  'contact_phone': contactsController.text
                                      .trim(),
                          
                                  'time_slot': selectedSlot,
                                };
                  
                                await Supabase.instance.client
                                    .from('org_regs')
                                    .insert(data);

                                context.pop();
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
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.send,
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
              );
            },
          );
        },
      );
    },
  );
}



String cleanName(String name) {
  const unwanted = 'ЖАУАПКЕРШІЛІГІ ШЕКТЕУЛІ СЕРІКТЕСТІГІ';
  String cleaned = name.toUpperCase().replaceAll(unwanted, '').trim();

  if (!cleaned.startsWith('ТОО')) {
    cleaned = 'ТОО $cleaned';
  }

  return cleaned;
}
