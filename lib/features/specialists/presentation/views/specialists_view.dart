import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/features/specialists/domain/usecases/get_specialists.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:system_5210/features/specialists/presentation/views/doctor_details_view.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';

class SpecialistsView extends StatefulWidget {
  const SpecialistsView({super.key});

  @override
  State<SpecialistsView> createState() => _SpecialistsViewState();
}

class _SpecialistsViewState extends State<SpecialistsView> {
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  Future<void> _loadSpecialists() async {
    setState(() => isLoading = true);
    final result = await sl<GetSpecialists>().call();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (doctors) {
          setState(() {
            allDoctors = doctors;
            filteredDoctors = doctors;
            isLoading = false;
          });
        },
      );
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      final lang = Localizations.localeOf(context).languageCode;
      filteredDoctors = allDoctors
          .where(
            (doctor) =>
                doctor
                    .getName(lang)
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                doctor
                    .getSpecialty(lang)
                    .toLowerCase()
                    .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.specialistsTitle,
          style:
              (Localizations.localeOf(context).languageCode == 'ar'
              ? GoogleFonts.cairo
              : GoogleFonts.poppins)(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142),
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 50,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterDoctors,
                decoration: InputDecoration(
                  hintText: l10n.specialistsSearchHint,
                  hintStyle:
                      (Localizations.localeOf(context).languageCode == 'ar'
                      ? GoogleFonts.cairo
                      : GoogleFonts.poppins)(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.appBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                style:
                    (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSpecialists,
                color: AppTheme.appBlue,
                child: isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 8,
                        itemBuilder: (context, index) => AppShimmer.listTile(),
                      )
                    : filteredDoctors.isEmpty
                    ? Center(child: Text(l10n.noSpecialistsFound))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return _buildDoctorListItem(doctor, l10n);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorListItem(Doctor doctor, AppLocalizations l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetailsView(doctor: doctor),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D3142).withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Hero(
                  tag: 'doctor_image_${doctor.id}',
                  child: Image.network(
                    doctor.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFFCBD5E1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: isAr
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.getName(lang),
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                      ),
                      if (doctor.allowsOnlineConsultation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.appGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.onlineConsultation,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 10,
                                  color: AppTheme.appGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.getSpecialty(lang),
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 14,
                      color: AppTheme.appBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: isAr
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.clinicLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.appBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.appBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
