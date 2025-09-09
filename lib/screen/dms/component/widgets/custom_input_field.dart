import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../themes/colors.dart';

class CustomInputField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final bool isRequired;
  final bool isMultiline;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomInputField({
    Key? key,
    this.title,
    this.hintText,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.isEnabled = true,
    this.isRequired = false,
    this.isMultiline = false,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) _buildTitle(),
          const SizedBox(height: 5),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: keyboardType ?? _getKeyboardType(),
        enabled: isEnabled,
        maxLength: maxLength,
        maxLines: isMultiline ? (maxLines ?? null) : 1,
        minLines: isMultiline ? (minLines ?? 1) : null,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 13,
          color: black,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: grey, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: red, width: 1),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          isDense: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: grey,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          errorStyle: const TextStyle(
            fontSize: 10,
            color: red,
          ),
        ),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    
    if (title?.toLowerCase().contains('phone') == true ||
        title?.toLowerCase().contains('sđt') == true) {
      return TextInputType.phone;
    }
    
    if (title?.toLowerCase().contains('email') == true) {
      return TextInputType.emailAddress;
    }
    
    if (isMultiline) {
      return TextInputType.multiline;
    }
    
    return TextInputType.text;
  }
}

class CustomInputFieldV2 extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final bool isRequired;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Widget? suffixIcon;

  const CustomInputFieldV2({
    Key? key,
    this.title,
    this.hintText,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.isEnabled = true,
    this.isRequired = false,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) _buildTitle(),
          const SizedBox(height: 5),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: keyboardType ?? _getKeyboardType(),
        enabled: isEnabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          fontSize: 13,
          color: black,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: grey, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          isDense: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: grey,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    
    if (title?.toLowerCase().contains('phone') == true ||
        title?.toLowerCase().contains('sđt') == true) {
      return TextInputType.phone;
    }
    
    if (title?.toLowerCase().contains('email') == true) {
      return TextInputType.emailAddress;
    }
    
    return TextInputType.text;
  }
}

