import 'package:flutter/foundation.dart';
import 'package:dr_shine_app/features/admin/models/package_model.dart';
import 'package:dr_shine_app/features/admin/repositories/package_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class PackageProvider extends ChangeNotifier {
  final IPackageRepository _repository;

  List<PackageModel> _packages = [];
  bool _isLoading = false;
  String? _error;

  PackageProvider(this._repository) {
    fetchPackages();
  }

  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await _repository.getPackages();
    } catch (e) {
      _error = 'Failed to load packages';
      LoggerService.error('PackageProvider fetchPackages error', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPackage(PackageModel package) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.addPackage(package);
      await fetchPackages();
    } catch (e) {
      _error = 'Failed to add package';
      LoggerService.error('PackageProvider addPackage error', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePackage(PackageModel package) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updatePackage(package);
      await fetchPackages();
    } catch (e) {
      _error = 'Failed to update package';
      LoggerService.error('PackageProvider updatePackage error', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePackage(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deletePackage(id);
      await fetchPackages();
    } catch (e) {
      _error = 'Failed to delete package';
      LoggerService.error('PackageProvider deletePackage error', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
