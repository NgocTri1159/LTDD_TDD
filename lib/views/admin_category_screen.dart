import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../controllers/category_controller.dart';

class AdminCategoryScreen extends StatelessWidget {
  AdminCategoryScreen({super.key});

  final CategoryController _controller = CategoryController();

  // Danh sách các icon có sẵn để chọn
  static const Map<String, IconData> _availableIcons = {
    'code': Icons.code,               // Lập trình
    'science': Icons.science,         // Khoa học
    'language': Icons.language,       // Tiếng Anh
    'calculate': Icons.calculate,     // Toán học
    'history': Icons.history_edu,     // Lịch sử / Xã hội
    'default_icon': Icons.book,       // Mặc định
  };

  // Hàm chuyển đổi chuỗi lưu trên Firebase thành IconData hiển thị
  IconData _getIconData(String iconName) {
    return _availableIcons[iconName] ?? Icons.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Môn học')),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _controller.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('Chưa có môn học nào.'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(_getIconData(cat.iconUrl)),
                  ),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(context, category: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirm(context, cat),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Popup Thêm / Sửa có kèm chọn Icon
  void _showFormDialog(BuildContext context, {CategoryModel? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: isEdit ? category.name : '');
    
    // Lưu trạng thái icon đang được chọn (mặc định là 'default_icon' nếu tạo mới)
    String selectedIcon = (isEdit && _availableIcons.containsKey(category.iconUrl))
        ? category.iconUrl
        : 'default_icon';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? 'Sửa môn học' : 'Thêm môn học'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên môn học'),
                ),
                const SizedBox(height: 16),
                const Text('Chọn biểu tượng:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableIcons.entries.map((entry) {
                    final isSelected = selectedIcon == entry.key;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIcon = entry.key;
                        });
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected ? Colors.blue : Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;

                  if (isEdit) {
                    await _controller.updateCategory(category.id, nameController.text, selectedIcon);
                  } else {
                    await _controller.addCategory(nameController.text, selectedIcon);
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Popup Xóa
  void _showDeleteConfirm(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa môn "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _controller.deleteCategory(category.id);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              } catch (e) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}