import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryController {
  late final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đọc dữ liệu Realtime (Stream)
  Stream<List<CategoryModel>> getCategories() {
    return _db
        .collection('Categories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Thêm môn học kèm icon
  Future<void> addCategory(String name, String iconUrl) async {
    if (name.trim().isEmpty) return;
    await _db.collection('Categories').add({
      'name': name.trim(),
      'iconUrl': iconUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sửa môn học (cập nhật cả tên và icon)
  Future<void> updateCategory(String id, String newName, String newIconUrl) async {
    if (newName.trim().isEmpty) return;
    await _db.collection('Categories').doc(id).update({
      'name': newName.trim(),
      'iconUrl': newIconUrl,
    });
  }

  // Xóa môn học (kèm check ràng buộc an toàn)
  Future<void> deleteCategory(String id) async {
    final questionsQuery = await _db
        .collection('Questions')
        .where('categoryId', isEqualTo: id)
        .limit(1)
        .get();

    if (questionsQuery.docs.isNotEmpty) {
      throw Exception('Không thể xóa! Đang có câu hỏi thuộc môn học này.');
    }
    await _db.collection('Categories').doc(id).delete();
  }
}