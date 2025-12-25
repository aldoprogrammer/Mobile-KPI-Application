import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/evaluation_create_result.dart';
import '../../domain/entities/evaluation_detail.dart';
import '../../domain/entities/evaluation_submit_result.dart';
import '../../domain/usecases/create_evaluation_usecase.dart';
import '../../domain/usecases/get_evaluation_usecase.dart';
import '../../domain/usecases/submit_evaluation_usecase.dart';

class EvaluationsProvider extends ChangeNotifier {
  EvaluationsProvider({
    required CreateEvaluationUseCase createEvaluation,
    required GetEvaluationUseCase getEvaluation,
    required SubmitEvaluationUseCase submitEvaluation,
  })  : _createEvaluation = createEvaluation,
        _getEvaluation = getEvaluation,
        _submitEvaluation = submitEvaluation;

  final CreateEvaluationUseCase _createEvaluation;
  final GetEvaluationUseCase _getEvaluation;
  final SubmitEvaluationUseCase _submitEvaluation;

  EvaluationDetail? _detail;
  bool _loading = false;
  String? _error;

  EvaluationDetail? get detail => _detail;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load(String evaluationId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _detail = await _getEvaluation(evaluationId);
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load evaluation';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<EvaluationCreateResult?> create({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> items,
  }) async {
    _error = null;
    notifyListeners();

    try {
      return await _createEvaluation(
        employeeId: employeeId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        items: items,
      );
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to create evaluation';
      notifyListeners();
      return null;
    }
  }

  Future<EvaluationSubmitResult?> submit(String evaluationId) async {
    _error = null;
    notifyListeners();

    try {
      return await _submitEvaluation(evaluationId);
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to submit evaluation';
      notifyListeners();
      return null;
    }
  }
}
