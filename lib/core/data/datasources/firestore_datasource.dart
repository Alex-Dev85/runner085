import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:runner085/core/domain/failures/app_failure.dart';
import 'package:runner085/core/utils/constants.dart';
import 'package:runner085/core/utils/result.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Users
  CollectionReference<Map<String, dynamic>> get usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  // Training Plans
  CollectionReference<Map<String, dynamic>> get plansRef =>
      _firestore.collection(AppConstants.plansCollection);

  // User Progress
  CollectionReference<Map<String, dynamic>> get progressRef =>
      _firestore.collection(AppConstants.progressCollection);

  Future<Result<Map<String, dynamic>>> getDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
  ) async {
    try {
      final doc = await collection.doc(docId).get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure(
          const AppFailure.server(message: 'Documento não encontrado'),
        );
      }
      return Result.success(doc.data()!);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure.server(message: e.message ?? 'Erro no Firestore'),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )? queryBuilder,
  }) async {
    try {
      final Query<Map<String, dynamic>> query =
          queryBuilder?.call(collection) ?? collection;
      final snapshot = await query.get();
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      return Result.success(docs);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure.server(message: e.message ?? 'Erro no Firestore'),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Future<Result<void>> setDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await collection.doc(docId).set(data, SetOptions(merge: true));
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure.server(message: e.message ?? 'Erro ao salvar'),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Future<Result<void>> updateDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await collection.doc(docId).update(data);
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure.server(message: e.message ?? 'Erro ao atualizar'),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
  ) {
    return collection.doc(docId).snapshots();
  }
}
