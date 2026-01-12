# Hướng dẫn mapping file JSON

## Mapping giữa file JSON mẫu và file thực tế

Khi upload lên GitHub repository, bạn cần đổi tên các file JSON mẫu thành tên phù hợp với index.json:

### File JSON mẫu → File thực tế:

1. `dart_basic_lesson_1.json` → `intro_dart.json`
2. `dart_basic_lesson_2.json` → `variables.json`
3. `dart_basic_lesson_3.json` → `functions.json`
4. `dart_basic_lesson_4.json` → `conditions.json`
5. `dart_basic_lesson_5.json` → `loops.json`
6. `dart_basic_lesson_6.json` → `lists.json`
7. `dart_basic_lesson_7.json` → `maps.json`
8. `dart_basic_lesson_8.json` → `classes.json`
9. `dart_basic_lesson_9.json` → `null_safety.json`
10. `dart_basic_lesson_10.json` → `async_await.json`

## Cấu trúc thư mục trên GitHub:

```
assets/
└── content/
    └── courses/
        └── programming/
            └── dart/
                └── dart_basic/
                    ├── index.json (file này)
                    ├── intro_dart.json
                    ├── variables.json
                    ├── functions.json
                    ├── conditions.json
                    ├── loops.json
                    ├── lists.json
                    ├── maps.json
                    ├── classes.json
                    ├── null_safety.json
                    └── async_await.json
```

## Các bước thực hiện:

1. **Đổi tên các file JSON mẫu** theo mapping ở trên
2. **Upload lên GitHub** vào đúng thư mục
3. **Upload file index.json** vào cùng thư mục
4. **Kiểm tra đường dẫn** trong index.json có đúng không
5. **Thêm hình ảnh** (nếu có) hoặc để image URL mặc định

## Lưu ý:

- Đảm bảo đường dẫn `path` trong index.json khớp với vị trí file trên GitHub
- Image URL có thể để placeholder hoặc thêm hình ảnh thực tế
- Tất cả file JSON phải có cấu trúc đúng với `dictionary_path` và `blocks`
