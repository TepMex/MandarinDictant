import 'package:flutter_bloc/flutter_bloc.dart';

class DictantBloc extends Cubit<String> {
  // NOTE: can use placeholder video or tutorial
  DictantBloc() : super('Vws4DE7UvtM/dummy.mp4');

  void nextVideo(assetUri) => emit(assetUri);
}
