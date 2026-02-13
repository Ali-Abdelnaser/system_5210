import 'package:system_5210/features/specialists/data/models/doctor_model.dart';

abstract class SpecialistsRemoteDataSource {
  Future<List<DoctorModel>> getSpecialists();
}
