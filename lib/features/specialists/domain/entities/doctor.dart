import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final String specialtyEn;
  final String specialtyAr;
  final String aboutEn;
  final String aboutAr;
  final String imageUrl;
  final String clinicLocation;
  final bool allowsOnlineConsultation;
  final String contactNumber;
  final String whatsappNumber;
  final int experienceYears;
  final List<String> workingDaysEn;
  final List<String> workingDaysAr;
  final String workingHoursEn;
  final String workingHoursAr;
  final List<String> certificates;

  const Doctor({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.aboutEn,
    required this.aboutAr,
    required this.imageUrl,
    required this.clinicLocation,
    required this.allowsOnlineConsultation,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.experienceYears,
    required this.workingDaysEn,
    required this.workingDaysAr,
    required this.workingHoursEn,
    required this.workingHoursAr,
    required this.certificates,
  });

  String getName(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  String getSpecialty(String languageCode) =>
      languageCode == 'ar' ? specialtyAr : specialtyEn;
  String getAbout(String languageCode) =>
      languageCode == 'ar' ? aboutAr : aboutEn;
  List<String> getWorkingDays(String languageCode) =>
      languageCode == 'ar' ? workingDaysAr : workingDaysEn;
  String getWorkingHours(String languageCode) =>
      languageCode == 'ar' ? workingHoursAr : workingHoursEn;

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameAr,
    specialtyEn,
    specialtyAr,
    aboutEn,
    aboutAr,
    imageUrl,
    clinicLocation,
    allowsOnlineConsultation,
    contactNumber,
    whatsappNumber,
    experienceYears,
    workingDaysEn,
    workingDaysAr,
    workingHoursEn,
    workingHoursAr,
    certificates,
  ];
}
