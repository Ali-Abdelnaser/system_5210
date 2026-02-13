import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_5210/features/specialists/data/models/doctor_model.dart';
import 'specialists_remote_data_source.dart';

class SpecialistsRemoteDataSourceImpl implements SpecialistsRemoteDataSource {
  final FirebaseFirestore firestore;

  SpecialistsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DoctorModel>> getSpecialists() async {
    try {
      final snapshot = await firestore.collection('specialists').get();
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch specialists from Firebase');
    }
  }
}
