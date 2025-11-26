// Simple User Model
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String district;
  final String address;
  final bool isStaff;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.district,
    required this.address,
    required this.isStaff,
  });

  // Convert JSON to User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      isStaff: json['is_staff'] ?? false,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'district': district,
      'address': address,
      'is_staff': isStaff,
    };
  }
}
