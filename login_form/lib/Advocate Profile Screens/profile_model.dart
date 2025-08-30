class ProfileModel {
  final String fullName;
  final String contactNumber;
  final int age;
  final String gender;
  final String city;
  final String postcode;
  final String address;
  final String email;
  final String officeAddress;
  final String licenseNumber;
  final String barAssociation;
  final String specialization;
  final String yearsOfExperience;  // This could be a String or an int if you prefer
  final String education;
  final String languagesSpoken;
  final String courtAffiliations;
  final String notableCases;
  final String workHours;
  final String consultationFee;
  final String location;
  final String bio;
  final List<String> practiceAreas;

  ProfileModel({
    required this.fullName,
    required this.contactNumber,
    required this.age,
    required this.gender,
    required this.city,
    required this.postcode,
    required this.address,
    required this.email,
    required this.officeAddress,
    required this.licenseNumber,
    required this.barAssociation,
    required this.specialization,
    required this.yearsOfExperience,
    required this.education,
    required this.languagesSpoken,
    required this.courtAffiliations,
    required this.notableCases,
    required this.workHours,
    required this.consultationFee,
    required this.location,
    required this.bio,
    required this.practiceAreas,
  });
}
