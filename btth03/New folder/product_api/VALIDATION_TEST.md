# Hướng dẫn Test Validation với Postman

## Thiết lập
- Server đang chạy tại: `http://127.0.0.1:8000`
- API Endpoint: `http://127.0.0.1:8000/api/products`

## Các quy tắc validation đã thiết lập:

### Cho hàm Store (POST /api/products):
- `name`: bắt buộc, chuỗi, tối đa 255 ký tự, phải duy nhất trong bảng products
- `description`: không bắt buộc, chuỗi, tối đa 500 ký tự
- `price`: bắt buộc, số, phải >= 0

### Cho hàm Update (PUT/PATCH /api/products/{id}):
- `name`: bắt buộc (nếu có), chuỗi, tối đa 255 ký tự, phải duy nhất (trừ record hiện tại)
- `description`: không bắt buộc, chuỗi, tối đa 500 ký tự  
- `price`: bắt buộc (nếu có), số, phải >= 0

## Test Cases với Postman:

### 1. Test POST - Tạo sản phẩm hợp lệ
**Method:** POST
**URL:** `http://127.0.0.1:8000/api/products`
**Headers:** 
```
Content-Type: application/json
Accept: application/json
```
**Body (JSON):**
```json
{
    "name": "iPhone 15",
    "description": "Smartphone cao cấp từ Apple",
    "price": 25000000
}
```
**Kết quả mong đợi:** HTTP 201 Created

### 2. Test POST - Thiếu trường bắt buộc (name)
**Body (JSON):**
```json
{
    "description": "Smartphone cao cấp từ Apple",
    "price": 25000000
}
```
**Kết quả mong đợi:** HTTP 422 Unprocessable Entity
```json
{
    "message": "The name field is required.",
    "errors": {
        "name": [
            "Trường tên sản phẩm là bắt buộc."
        ]
    }
}
```

### 3. Test POST - Giá âm
**Body (JSON):**
```json
{
    "name": "Samsung Galaxy S24",
    "description": "Smartphone Android cao cấp",
    "price": -1000
}
```
**Kết quả mong đợi:** HTTP 422 Unprocessable Entity
```json
{
    "message": "The price field must be at least 0.",
    "errors": {
        "price": [
            "Trường giá sản phẩm phải có ít nhất 0."
        ]
    }
}
```

### 4. Test POST - Tên quá dài (>255 ký tự)
**Body (JSON):**
```json
{
    "name": "Tên sản phẩm rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài",
    "description": "Mô tả sản phẩm",
    "price": 1000000
}
```
**Kết quả mong đợi:** HTTP 422 Unprocessable Entity

### 5. Test POST - Mô tả quá dài (>500 ký tự)
**Body (JSON):**
```json
{
    "name": "iPad Pro",
    "description": "Mô tả rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài rất dài",
    "price": 30000000
}
```

### 6. Test POST - Tên trùng lặp (unique validation)
Đầu tiên tạo 1 sản phẩm, sau đó thử tạo sản phẩm khác với cùng tên:
**Body (JSON):**
```json
{
    "name": "iPhone 15",
    "description": "Sản phẩm trùng tên",
    "price": 26000000
}
```
**Kết quả mong đợi:** HTTP 422 Unprocessable Entity
```json
{
    "message": "The name has already been taken.",
    "errors": {
        "name": [
            "Trường tên sản phẩm đã được sử dụng."
        ]
    }
}
```

### 7. Test PUT - Cập nhật sản phẩm hợp lệ
**Method:** PUT
**URL:** `http://127.0.0.1:8000/api/products/1`
**Body (JSON):**
```json
{
    "name": "iPhone 15 Pro Max",
    "description": "Phiên bản cao cấp nhất",
    "price": 35000000
}
```

### 8. Test PUT - Cập nhật với validation lỗi
**Method:** PUT  
**URL:** `http://127.0.0.1:8000/api/products/1`
**Body (JSON):**
```json
{
    "price": -5000
}
```

## Lưu ý:
- Tất cả các request đều cần header `Accept: application/json` để nhận response dạng JSON
- Khi validation thất bại, Laravel tự động trả về HTTP 422 với chi tiết lỗi
- Thông báo lỗi sẽ hiển thị bằng tiếng Việt do đã cấu hình locale = 'vi'