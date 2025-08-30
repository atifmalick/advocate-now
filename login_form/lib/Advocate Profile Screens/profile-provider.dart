import 'package:flutter/material.dart';

class Profile {
  String fullName;
  String contactNumber;
  String yearsOfExperience;
  String location;
  String bio;
  int age;
  String gender;
  String city;
  String postcode;
  String address;
  String email;
  String officeAddress;
  String licenseNumber;
  String barAssociation;
  String specialization;
  String education;
  String languagesSpoken;
  String courtAffiliations;
  String notableCases;
  String awards;
  String workHours;
  double consultationFee;

  Profile({
    required this.fullName,
    required this.contactNumber,
    required this.yearsOfExperience,
    required this.location,
    required this.bio,
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
    required this.education,
    required this.languagesSpoken,
    required this.courtAffiliations,
    required this.notableCases,
    required this.awards,
    required this.workHours,
    required this.consultationFee,
  });

  // Add a method for default profile initialization
  static Profile get defaultProfile => Profile(
    fullName: 'Unknown',
    contactNumber: 'Unknown',
    yearsOfExperience: '0',
    location: 'Unknown',
    bio: 'No bio available',
    age: 0,
    gender: 'Unknown',
    city: 'Unknown',
    postcode: '0000',
    address: 'Unknown',
    email: 'Unknown',
    officeAddress: 'Unknown',
    licenseNumber: 'Unknown',
    barAssociation: 'Unknown',
    specialization: 'Unknown',
    education: 'Unknown',
    languagesSpoken: 'Unknown',
    courtAffiliations: 'Unknown',
    notableCases: 'None',
    awards: 'None',
    workHours: 'Unknown',
    consultationFee: 0.0,
  );
}

class ProfileProvider with ChangeNotifier {
  Profile _profile;
  String? _profilePicture; // Nullable profile picture

  ProfileProvider(this._profile);

  Profile get profile => _profile;
  String? get profilePicture => _profilePicture;

  void updateProfile(Profile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  void updateProfilePicture(String path) {
    _profilePicture = path;
    notifyListeners();
  }

  void resetProfile() {
    _profile = Profile.defaultProfile; // Use default profile initialization
    _profilePicture = null; // Reset profile picture to null
    notifyListeners();
  }
}
