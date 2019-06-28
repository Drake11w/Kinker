class _User{

  String uid;
  String name;
  int age;
  String bio;

  _User(this.name, this.age, this.bio, this.uid);

  String getUid(){
    return uid;
  }

  void setUid(String _uid){
    uid = _uid;
  }

  String getName(){
    return name;
  }

  void setName(String _name){
    name = name;
  }

  int getAge(){
    return age;
  }

  void setAge(int _age){
    age = _age;
  }

  String getBio(){
    return bio;
  }

  void setBio(String _bio){
    bio = _bio;
  }



}