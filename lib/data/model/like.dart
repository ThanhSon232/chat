class Likes {
  String? fullName;
  String? avatarURL;
  String? id;

  Likes({this.fullName, this.avatarURL, this.id});

  Likes.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatarURL = json['avatarURL'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['avatarURL'] = this.avatarURL;
    data['id'] = this.id;
    return data;
  }
}