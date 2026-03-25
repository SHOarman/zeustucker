import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

Widget buildDropdownCustom({
  required String hint,
  required RxString value,
  required List<String> items,
}) {
  return Obx(() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFDDDDDD)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        dropdownColor: const Color(0xFFF9F9F9),
        hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        value: value.value == "" ? null : value.value,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),

        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((String item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(color: Color(0xff111928), fontSize: 14),
              ),
            );
          }).toList();
        },

        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff111928),
              ),
            ),
          );
        }).toList(),

        onChanged: (newValue) {
          value.value = newValue!;
        },
      ),
    ),
  ));
}