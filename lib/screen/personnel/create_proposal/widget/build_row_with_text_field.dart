import 'package:flutter/material.dart';

class BuildRowWithTextField extends StatelessWidget {
  final String label;
  final String hint;

  const BuildRowWithTextField({
    key,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              suffixIcon: InkWell(
                onTap: () {},
                child: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
