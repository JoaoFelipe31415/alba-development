import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:flutter/material.dart';

class ProgressViewModel extends ChangeNotifier {
  bool isLoading = true;
  String currentFilter = 'Semana';
  ProgressDataModel? data;

  ProgressViewModel() {
    loadData();
  }

  void changeFilter(String newFilter) {
    if (currentFilter != newFilter) {
      currentFilter = newFilter;
      loadData();
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    Map<String, dynamic> mockFirebaseJson = {}; 
    data = ProgressDTO.fromFirestore(mockFirebaseJson);

    isLoading = false;
    notifyListeners();
  }
}