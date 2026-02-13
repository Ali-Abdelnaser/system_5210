import 'package:system_5210/features/specialists/domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.specialtyEn,
    required super.specialtyAr,
    required super.aboutEn,
    required super.aboutAr,
    required super.imageUrl,
    required super.clinicLocation,
    required super.allowsOnlineConsultation,
    required super.contactNumber,
    required super.whatsappNumber,
    required super.experienceYears,
    required super.workingDaysEn,
    required super.workingDaysAr,
    required super.workingHoursEn,
    required super.workingHoursAr,
    required super.certificates,
  });

  factory DoctorModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return DoctorModel(
      id: documentId,
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'] ?? '',
      specialtyEn: json['specialtyEn'] ?? '',
      specialtyAr: json['specialtyAr'] ?? '',
      aboutEn: json['aboutEn'] ?? '',
      aboutAr: json['aboutAr'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      clinicLocation: json['clinicLocation'] ?? '',
      allowsOnlineConsultation: json['allowsOnlineConsultation'] ?? false,
      contactNumber: json['contactNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      workingDaysEn: List<String>.from(json['workingDaysEn'] ?? []),
      workingDaysAr: List<String>.from(json['workingDaysAr'] ?? []),
      workingHoursEn: json['workingHoursEn'] ?? '',
      workingHoursAr: json['workingHoursAr'] ?? '',
      certificates: List<String>.from(json['certificates'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nameEn': nameEn,
      'nameAr': nameAr,
      'specialtyEn': specialtyEn,
      'specialtyAr': specialtyAr,
      'aboutEn': aboutEn,
      'aboutAr': aboutAr,
      'imageUrl': imageUrl,
      'clinicLocation': clinicLocation,
      'allowsOnlineConsultation': allowsOnlineConsultation,
      'contactNumber': contactNumber,
      'whatsappNumber': whatsappNumber,
      'experienceYears': experienceYears,
      'workingDaysEn': workingDaysEn,
      'workingDaysAr': workingDaysAr,
      'workingHoursEn': workingHoursEn,
      'workingHoursAr': workingHoursAr,
      'certificates': certificates,
    };
  }
}
