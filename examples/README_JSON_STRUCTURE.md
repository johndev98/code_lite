# Hướng dẫn cấu trúc JSON cho bài học Dart

## Các block type được hỗ trợ:

### 1. **heading** - Tiêu đề bài học
```json
{
  "type": "heading",
  "value": "Tiêu đề bài học"
}
```

### 2. **text** - Đoạn văn bản
```json
{
  "type": "text",
  "value": "Nội dung văn bản..."
}
```

### 3. **key_concepts** - Khái niệm quan trọng (MỚI)
```json
{
  "type": "key_concepts",
  "concepts": [
    {
      "title": "Tên khái niệm",
      "description": "Mô tả chi tiết"
    }
  ]
}
```

### 4. **step_by_step** - Hướng dẫn từng bước (MỚI)
```json
{
  "type": "step_by_step",
  "title": "Tiêu đề (optional)",
  "steps": [
    "Bước 1",
    "Bước 2",
    "Bước 3"
  ]
}
```

### 5. **code** - Code block
```json
{
  "type": "code",
  "value": "void main() {\n  print('Hello');\n}",
  "language": "dart",
  "keywords": ["void", "main", "print"]
}
```

### 6. **practice** - Bài tập thực hành (MỚI)
```json
{
  "type": "practice",
  "title": "Tiêu đề bài tập",
  "description": "Mô tả bài tập",
  "code_template": "void main() {\n  // TODO\n}",
  "solution": "void main() {\n  // Đáp án\n}",
  "hint": "Gợi ý (optional)"
}
```

### 7. **checkpoint** - Điểm kiểm tra (MỚI)
```json
{
  "type": "checkpoint",
  "question": "Câu hỏi?",
  "options": ["A", "B", "C", "D"],
  "correct_answer": 0,
  "explanation": "Giải thích (optional)"
}
```

### 8. **summary** - Tóm tắt (MỚI)
```json
{
  "type": "summary",
  "value": "Nội dung tóm tắt...",
  "key_points": [
    "Điểm 1",
    "Điểm 2"
  ]
}
```

### 9. **analogy** - Liên tưởng thực tế
```json
{
  "type": "analogy",
  "concept": "Khái niệm",
  "value": "Ví dụ thực tế..."
}
```

### 10. **comparison** - So sánh đúng/sai
```json
{
  "type": "comparison",
  "wrong": "Code sai",
  "right": "Code đúng",
  "reason": "Lý do"
}
```

### 11. **callout** - Callout box
```json
{
  "type": "callout",
  "style": "info|warning|tip",
  "value": "Nội dung..."
}
```

### 12. **list** - Danh sách
```json
{
  "type": "list",
  "items": [
    "Item 1",
    "Item 2"
  ]
}
```

### 13. **quiz** - Câu hỏi trắc nghiệm
```json
{
  "type": "quiz",
  "question": "Câu hỏi?",
  "options": ["A", "B", "C"],
  "answer": 0
}
```

### 14. **image** - Hình ảnh
```json
{
  "type": "image",
  "value": "URL hình ảnh",
  "caption": "Chú thích (optional)"
}
```

### 15. **video** - Video
```json
{
  "type": "video",
  "value": "URL video/image",
  "caption": "Chú thích (optional)"
}
```

### 16. **divider** - Phân cách
```json
{
  "type": "divider"
}
```

## Cấu trúc file JSON hoàn chỉnh:

```json
{
  "dictionary_path": "content/dictionary/languages/dart",
  "blocks": [
    {
      "type": "heading",
      "value": "Tiêu đề"
    },
    {
      "type": "text",
      "value": "Nội dung..."
    }
  ]
}
```

## Tips để tối ưu bài học:

1. **Bắt đầu với heading** - Giúp người học biết họ đang học gì
2. **Dùng key_concepts** - Highlight những điểm quan trọng ngay đầu bài
3. **Thêm step_by_step** - Hướng dẫn từng bước cho người mới
4. **Practice blocks** - Cho người học thực hành ngay
5. **Checkpoint** - Đảm bảo họ hiểu trước khi tiếp tục
6. **Summary** - Tóm tắt lại ở cuối bài
7. **Dùng analogy** - Giúp người mới hiểu bằng ví dụ thực tế
8. **Comparison** - So sánh đúng/sai để tránh lỗi phổ biến

## Ví dụ bài học tối ưu:

Xem các file:
- `dart_basic_lesson_1.json` - Giới thiệu về Dart
- `dart_basic_lesson_2.json` - Biến và Kiểu dữ liệu
- `dart_basic_lesson_3.json` - Hàm (Functions)
- `dart_basic_lesson_4.json` - Điều kiện (if/else) và Switch
- `dart_basic_lesson_5.json` - Vòng lặp (Loops)
- `dart_basic_lesson_6.json` - List (Danh sách)
- `dart_basic_lesson_7.json` - Map (Bản đồ dữ liệu)
- `dart_basic_lesson_8.json` - Class và Object
- `dart_basic_lesson_9.json` - Null Safety
- `dart_basic_lesson_10.json` - Async/Await (Cơ bản)

## Cấu trúc khóa học Dart Basic:

1. **Bài 1-3**: Cơ bản (Giới thiệu, Biến, Hàm)
2. **Bài 4-5**: Điều khiển luồng (Điều kiện, Vòng lặp)
3. **Bài 6-7**: Cấu trúc dữ liệu (List, Map)
4. **Bài 8**: Hướng đối tượng (Class, Object)
5. **Bài 9**: Null Safety
6. **Bài 10**: Bất đồng bộ (Async/Await)
