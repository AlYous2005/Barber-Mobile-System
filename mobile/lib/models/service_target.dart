enum ServiceTarget { personal, child, elderly }

extension ServiceTargetX on ServiceTarget {
  String get databaseValue {
    switch (this) {
      case ServiceTarget.personal:
        return 'personal';
      case ServiceTarget.child:
        return 'child';
      case ServiceTarget.elderly:
        return 'elderly';
    }
  }

  String get arabicLabel {
    switch (this) {
      case ServiceTarget.personal:
        return 'لك';
      case ServiceTarget.child:
        return 'للطفل';
      case ServiceTarget.elderly:
        return 'لكبير السن';
    }
  }

  String get sectionTitle {
    switch (this) {
      case ServiceTarget.personal:
        return 'خدمات شخصية';
      case ServiceTarget.child:
        return 'الخدمات الخاصة بالأطفال';
      case ServiceTarget.elderly:
        return 'الخدمات الخاصة بكبار السن';
    }
  }
}
