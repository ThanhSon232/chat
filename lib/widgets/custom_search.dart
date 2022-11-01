import 'package:flutter/material.dart';

import '../theme/color.dart';

class CustomSearch extends StatefulWidget {
  final void Function()? onTap;
  final bool? readOnly;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const CustomSearch(
      {Key? key,
      this.onTap,
      this.readOnly,
      this.controller,
      this.onChanged,
      this.onFieldSubmitted})
      : super(key: key);

  @override
  State<CustomSearch> createState() => _CustomSearchState();
}

class _CustomSearchState extends State<CustomSearch> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      readOnly: widget.readOnly ?? false,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: grey,
        ),
        hintText: "Search",
        contentPadding: EdgeInsets.zero,
        fillColor: grey_100,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }
}
