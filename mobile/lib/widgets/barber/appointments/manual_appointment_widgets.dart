import 'package:flutter/material.dart';

import '../../../models/mock_service.dart';

class ManualAppointmentTextField extends StatelessWidget {
  const ManualAppointmentTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5C4030),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FBFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ManualServiceDropdown extends StatelessWidget {
  const ManualServiceDropdown({
    super.key,
    required this.selectedServiceName,
    required this.onChanged,
  });

  final String? selectedServiceName;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'نوع الخدمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4ECE7),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedServiceName,
              isExpanded: true,
              hint: const Text('اختر الخدمة'),
              items: mockBarberServices.map((service) {
                return DropdownMenuItem<String>(
                  value: service.name,
                  child: Text(
                    '${service.name} - ${service.durationMinutes} دقيقة',
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class PickerBox extends StatelessWidget {
  const PickerBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        Material(
          color: const Color(0xFFF9FBFA),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4ECE7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF5C4030),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ManualPrimaryButton extends StatelessWidget {
  const ManualPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}