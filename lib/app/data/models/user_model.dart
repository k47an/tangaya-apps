class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String gender;
  final String phone;
  final String address;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.gender,
    required this.phone,
    required this.address,
    required this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] ?? map['uid'] ?? '', // <<=== PERBAIKAN DI SINI
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'gender': gender,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
    };
  }
}
