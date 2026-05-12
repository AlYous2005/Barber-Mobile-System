import 'package:flutter/material.dart';

/// Shared validation for barber service add/edit forms (mock UI; no backend).
class ServiceFieldValidation {
  ServiceFieldValidation._();

  static String? nameError(String raw) {
    if (raw.trim().isEmpty) {
      return 'الرجاء إدخال اسم الخدمة';
    }
    return null;
  }

  static String? durationError(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) {
      return 'الرجاء إدخال مدة الخدمة';
    }
    final int? v = int.tryParse(t);
    if (v == null) {
      return 'مدة الخدمة يجب أن تكون رقمًا يقبل القسمة على 5';
    }
    if (v < 0) {
      return 'مدة الخدمة لا يمكن أن تكون أقل من صفر';
    }
    if (v % 5 != 0) {
      return 'مدة الخدمة يجب أن تكون رقمًا يقبل القسمة على 5';
    }
    return null;
  }

  static String? priceError(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) {
      return 'الرجاء إدخال سعر الخدمة';
    }
    final int? v = int.tryParse(t);
    if (v == null) {
      return 'سعر الخدمة يجب أن يكون رقمًا يقبل القسمة على 5';
    }
    if (v <= 0) {
      return 'سعر الخدمة يجب أن يكون أكبر من صفر';
    }
    if (v % 5 != 0) {
      return 'سعر الخدمة يجب أن يكون رقمًا يقبل القسمة على 5';
    }
    return null;
  }
}

/// Step duration/price by 5; duration may be 0; digits-only fields.
class ServiceStepperHelper {
  ServiceStepperHelper._();

  static void increaseMultipleOf5(TextEditingController c) {
    final String t = c.text.trim();
    int v = int.tryParse(t) ?? 0;
    if (t.isEmpty || v < 5) {
      c.text = '5';
      return;
    }
    if (v % 5 != 0) {
      v = ((v + 4) ~/ 5) * 5;
    } else {
      v += 5;
    }
    c.text = v.toString();
  }

  static void decreaseMultipleOf5(TextEditingController c) {
    int v = int.tryParse(c.text.trim()) ?? 0;

    if (v <= 0) {
      c.text = '0';
      return;
    }

    if (v % 5 != 0) {
      v = (v ~/ 5) * 5;
    } else {
      v -= 5;
    }

    if (v < 0) {
      v = 0;
    }

    c.text = v.toString();
  }
}
