import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController myController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmittedValue;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final Image? prefixIcon;
  final VoidCallback? onSuffixIconPress;
  final Function(String)? onChanged;
  final TextInputType keyBoardType;
  final String hint;
  final String? errorText; // ✅ added for in-field validation errors
  final bool obscureText;
  final bool enable;
  final bool autoFocus;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final bool enableRealTimeValidation;
  final String? Function(String?)? realTimeValidator;

  const InputTextField({
    super.key,
    required this.myController,
    this.focusNode,
    this.onFieldSubmittedValue,
    required this.keyBoardType,
    required this.obscureText,
    this.suffixIcon,
    this.onSuffixIconPress,
    this.onChanged,
    required this.hint,
    this.errorText, // ✅ initialize here
    this.enable = true,
    this.validator,
    this.autoFocus = false,
    this.prefixIcon,
    this.autofillHints,
    this.textInputAction,
    this.enableRealTimeValidation = false,
    this.realTimeValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: TextFormField(
        controller: myController,
        focusNode: focusNode,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmittedValue,
        validator: enableRealTimeValidation ? realTimeValidator : validator,
        keyboardType: keyBoardType,
        enabled: enable,
        onChanged: enableRealTimeValidation
            ? (value) {
                if (onChanged != null) onChanged!(value);
                // Trigger validation on change
                if (realTimeValidator != null) {
                  realTimeValidator!(value);
                }
              }
            : onChanged,
        cursorColor: AppColors.blueColor,
        style: TextStyles.regularwhite,
        autofocus: autoFocus,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          errorText: errorText,
          errorStyle: TextStyle(
            color: Colors.redAccent,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
          hintText: hint,
          contentPadding: const EdgeInsets.all(20),
          hintStyle: TextStyles.regularhint,
          fillColor: AppColors.signinoptioncolor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon != null
              ? GestureDetector(onTap: onSuffixIconPress, child: suffixIcon)
              : null,
        ),
      ),
    );
  }
}
