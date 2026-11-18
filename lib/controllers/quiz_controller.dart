import 'package:cloud_firestore/cloud_firestore.dart';
// Thay dòng import model dưới đây theo đúng đường dẫn của bạn
import '../models/quiz_model.dart'; 

class QuizController {
  final CollectionReference quizCollection = FirebaseFirestore.instance.collection('quizzes');

  // Hàm Lấy danh sách đề thi kèm theo Bộ lọc và Tìm kiếm
  Stream<List<QuizModel>> getFilteredQuizzes({
    String searchQuery = '',
    String? categoryId,
    String? difficulty,
  }) {
    // 1. Tạo Query gốc (Mục 4 Trello: Query kết hợp)
    Query query = quizCollection;

    if (categoryId != null && categoryId != 'All') {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    
    if (difficulty != null && difficulty != 'All') {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    // 2. Lắng nghe dữ liệu và lọc chuỗi (Mục 3 Trello: Text Search)
    return query.snapshots().map((snapshot) {
      List<QuizModel> quizzes = snapshot.docs.map((doc) {
        return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Lọc chuỗi (Text Search) trực tiếp trên thiết bị (Xử lý chữ hoa/thường)
      if (searchQuery.isNotEmpty) {
        quizzes = quizzes.where((quiz) {
          return quiz.title.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      return quizzes;
    });
  }
}