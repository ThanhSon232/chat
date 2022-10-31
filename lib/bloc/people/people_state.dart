part of 'people_cubit.dart';

@immutable
abstract class PeopleState extends Equatable{
  @override
  List<Object> get props => [];
}

class PeopleInitial extends PeopleState {

}

class PeopleLoading extends PeopleState{
  
}

class PeopleLoaded extends PeopleState{
  List<UserModel> userModelList;

  PeopleLoaded({required this.userModelList});

  @override
  List<Object> get props => [
    userModelList
  ];
}
