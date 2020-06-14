class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final bool isAnonymous;

  UserModel({this.uid, this.displayName, this.email, this.isAnonymous});

  @override
  String toString() => 'User(uid=$uid, dipslayName=$displayName, '
      'email=$email, isAnonymous=$isAnonymous)';
}
