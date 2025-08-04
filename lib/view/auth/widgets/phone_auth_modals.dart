import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/country_model.dart';
import 'package:tailorapp/core/constants/countries_data.dart';
import 'package:tailorapp/view/auth/widgets/country_picker_widget.dart';
import 'package:tailorapp/view/auth/widgets/user_creation_modal.dart';
import 'package:tailorapp/view/auth/view/pin_verification_page.dart';

class PhoneAuthModals {
  static void showPhoneNumberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PhoneNumberInputModal(),
    );
  }

  static void showPinVerificationModal(
    BuildContext context,
    String phoneNumber,
    String verificationId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PinVerificationModal(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
      ),
    );
  }
}

class PhoneNumberInputModal extends StatefulWidget {
  const PhoneNumberInputModal({super.key});

  @override
  State<PhoneNumberInputModal> createState() => _PhoneNumberInputModalState();
}

class _PhoneNumberInputModalState extends State<PhoneNumberInputModal> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  CountryModel _selectedCountry = CountriesData.defaultCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Enter Phone Number',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'We\'ll send you a verification code to confirm your phone number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Phone number form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone number input with country code
                    Row(
                      children: [
                        // Country code selector
                        GestureDetector(
                          onTap: _showCountryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedCountry.flag,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry.code,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Phone number input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.blue[600]!),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length < 10) {
                                return 'Phone number must be at least 10 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Continue button
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() async {
    final selectedCountry = await CountryPickerWidget.show(
      context: context,
      selectedCountry: _selectedCountry,
      title: 'Select Country',
      searchHint: 'Search countries...',
    );

    if (selectedCountry != null) {
      setState(() {
        _selectedCountry = selectedCountry;
      });
    }
  }

  void _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      final fullPhoneNumber =
          _selectedCountry.code + _phoneController.text.trim();

      try {
        // Check if user exists with this phone number
        final userProfile =
            await context.read<AuthCubit>().getUserByPhone(fullPhoneNumber);

        // Check if widget is still mounted before using context
        if (!mounted) return;

        // Close current modal
        Navigator.of(context).pop();

        if (userProfile != null) {
          // User exists, navigate to PIN verification page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PinVerificationPage(
                phoneNumber: fullPhoneNumber,
                userProfile: userProfile,
              ),
            ),
          );
        } else {
          // User doesn't exist, show user creation modal
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => UserCreationModal(
              phoneNumber: fullPhoneNumber,
            ),
          );
        }
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class PinVerificationModal extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const PinVerificationModal({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<PinVerificationModal> createState() => _PinVerificationModalState();
}

class _PinVerificationModalState extends State<PinVerificationModal> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final List<TextEditingController> _pinControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _pinFocusNodes =
      List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    _pinController.dispose();
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      PhoneAuthModals.showPhoneNumberModal(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Enter your 6-digit PIN for '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // PIN input
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter PIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PIN input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _pinControllers[index],
                            focusNode: _pinFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blue[600]!,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _pinFocusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _pinFocusNodes[index - 1].requestFocus();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Forgot PIN
              Center(
                child: TextButton(
                  onPressed: _handleForgotPin,
                  child: Text(
                    'Forgot PIN?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Verify button
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state is AuthAuthenticated) {
                    // Close modal and navigate to home
                    Navigator.of(context).pop();
                    // Navigation to home is handled by AuthWrapper
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleVerify() {
    final pin = _pinControllers.map((controller) => controller.text).join();

    if (pin.length == 6) {
      // Sign in directly with phone number and PIN
      context.read<AuthCubit>().signInWithPhoneAndPin(widget.phoneNumber, pin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 6-digit PIN'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleForgotPin() {
    // Clear current PIN
    for (final controller in _pinControllers) {
      controller.clear();
    }

    // Focus first field
    _pinFocusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please contact support to reset your PIN'),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
