class User
{
  String displayName;
  String email;
  String expiresIn;
  String idToken;
  String kind;
  String localId;
  String refreshToken;
  bool registered;

  static User _user = null;

  User(Map<String, dynamic> map)
  {
    this.displayName = map['displayName'];
    this.email = map['email'];
    this.expiresIn = map['expiresIn'];
    this.idToken = map['idToken'];
    this.kind = map['kind'];
    this.localId = map['localId'];
    this.refreshToken = map['refreshToken'];
    this.registered = map['registered'];
  }

  static User getInstance([Map map])
  {
    if (_user == null)
      _user = new User(map);

    return _user;
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'email': email,
    'expiresIn': expiresIn,
    'idToken': idToken,
    'kind': kind,
    'localId': localId,
    'refreshToken': refreshToken,
    'registered': registered
  };
}