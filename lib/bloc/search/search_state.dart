part of 'search_cubit.dart';

@immutable
abstract class SearchState extends Equatable{
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState{}

class SearchSuggestion extends SearchState{
  final List<UserModel> userList;

  SearchSuggestion({required this.userList});

  @override
  List<Object> get props => [
    userList
  ];
}

class SearchLoaded extends SearchState{
  final List<UserModel> userList;

  SearchLoaded({required this.userList});

  @override
  List<Object> get props => [
    userList
  ];
}
