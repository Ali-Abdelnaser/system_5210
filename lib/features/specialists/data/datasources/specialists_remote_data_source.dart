import 'package:five2ten/features/specialists/data/models/doctor_model.dart';

abstract class SpecialistsRemoteDataSource {
  Future<List<DoctorModel>> getSpecialists();
}
