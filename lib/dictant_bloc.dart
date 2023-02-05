import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';

class DictantBloc extends Cubit<DictantItem> {
  // NOTE: can use placeholder video or tutorial
  DictantBloc() : super(DictantItem(-1, 'filePath', 0, [0], [''], ''));

  void nextItem(DictantItem item) => emit(item);
}
