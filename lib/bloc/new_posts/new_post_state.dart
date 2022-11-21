part of 'new_post_cubit.dart';

@immutable
abstract class NewPostState extends Equatable{
  @override
  List<Object> get props => [

  ];
}

class NewPostInitial extends NewPostState {

}

class NewPostLoading extends NewPostState{

}

class NewPostAdded extends NewPostState{
  XFile xFile;
  String type;
  NewPostAdded({required this.xFile, required this.type});

  @override
  List<Object> get props => [
    xFile,
    type
  ];
}

class NewPostRemove extends NewPostState{
}
