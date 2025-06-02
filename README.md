# Flutter-android-app

🎯 Chức năng chính của ứng dụng:

Nhật ký trồng trọt (DiaryPage):
Giao diện nhập thông tin liên quan đến việc chăm sóc cây trồng:
Giống cây
Thời gian thực hiện
Địa điểm
Nhân viên thực hiện
Thời gian phun thuốc
Ngày thu hoạch
Thông tin bảo quản
Cho phép chọn ảnh từ thư viện để lưu cùng nhật ký.
Tạo một QR code chứa toàn bộ thông tin đã nhập.
Lưu trữ thông tin dạng DiaryEntry và hiển thị thông báo khi lưu thành công.
Truy xuất nguồn gốc (TraceabilityPage):
Cho phép quét mã QR (sử dụng thư viện barcode_scan2) để hiển thị lại thông tin đã lưu tương ứng với mã QR đó.
Hiển thị kết quả quét lên màn hình.
Danh sách nhật ký (DiaryListPage):
Hiển thị danh sách các nhật ký đã lưu.
Cho phép nhấn vào từng mục để xem chi tiết ở DetailPage.
Chuyển đổi qua lại giữa các tab bằng BottomNavigationBar:
Tab 1: 📘 Nhật ký
Tab 2: 📷 Truy xuất
Tab 3: 📋 Danh sách
