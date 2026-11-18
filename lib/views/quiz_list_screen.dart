import 'package:flutter/material.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_model.dart';

class QuizListScreen extends StatefulWidget {
  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final QuizController _quizController = QuizController();
  
  // Các biến lưu trạng thái bộ lọc
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All'; // Bạn có thể lấy danh sách category thực tế từ Firestore

  final List<String> _difficulties = ['All', 'Dễ', 'Trung bình', 'Khó'];
  final List<String> _categories = ['All', 'Toán', 'Lập trình', 'Anh văn']; // Thay bằng category của bạn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm & Lọc Đề Thi')),
      body: Column(
        children: [
          // 1. THANH SEARCH BAR (Mục 1 trên Trello)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập tên đề thi cần tìm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Gõ đến đâu, tự động cập nhật đến đó
                });
              },
            ),
          ),

          // 2. CÁC NÚT FILTER CHIP (Mục 2 trên Trello)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text('Độ khó: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._difficulties.map((diff) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(diff),
                    selected: _selectedDifficulty == diff,
                    onSelected: (selected) {
                      setState(() => _selectedDifficulty = diff);
                    },
                  ),
                )).toList(),
              ],
            ),
          ),
          
          SizedBox(height: 10),

          // 3. HIỂN THỊ KẾT QUẢ VỚI STREAMBUILDER
          Expanded(
            child: StreamBuilder<List<QuizModel>>(
              stream: _quizController.getFilteredQuizzes(
                searchQuery: _searchQuery,
                categoryId: _selectedCategory == 'All' ? null : _selectedCategory,
                difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không tìm thấy bộ đề nào phù hợp.'));
                }

                final quizzes = snapshot.data!;
                return ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(quiz.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Môn: ${quiz.categoryId} - Độ khó: ${quiz.difficulty}'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Chuyển sang trang chi tiết đề thi
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}