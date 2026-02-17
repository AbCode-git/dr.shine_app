import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/customer/repositories/customer_repository_interface.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';

class CustomerProvider extends ChangeNotifier {
  final ICustomerRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _searchResults = [];
  List<BookingModel> get searchResults => _searchResults;

  CustomerProvider(this._repository);

  // Search for customers by plate number
  Future<List<BookingModel>> searchCustomers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchByPlate(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _searchResults;
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
