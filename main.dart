import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'detail_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký Trồng trọt & Truy xuất Nguồn gốc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFedf2f4),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: Color(0xFFedf2f4),
      ),
      home: HomePage(),
    );
  }
}

List<DiaryEntry> savedDiaryEntries = [];

class DiaryEntry {
  final String? plantVariety;
  final String? careTime;
  final String? careLocation;
  final String? careEmployee;
  final String? sprayTime;
  final DateTime? harvestDate;
  final String? storageInfo;
  final File? imageFile;
  final Uint8List? webImage;
  String? qrCodeData;

  DiaryEntry({
    this.plantVariety,
    this.careTime,
    this.careLocation,
    this.careEmployee,
    this.sprayTime,
    this.harvestDate,
    this.storageInfo,
    this.imageFile,
    this.webImage,
    this.qrCodeData,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    DiaryPage(),
    TraceabilityPage(),
    DiaryListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFFFEC5BB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Nhật ký"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Truy xuất"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Danh sách"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final _formKey = GlobalKey<FormState>();// cac bien nguoi dung co the nhap vao
  String? plantVariety;
  String? careTime;
  String? careLocation;
  String? careEmployee;
  String? sprayTime;
  DateTime? harvestDate;
  String? storageInfo;
  File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  DateTime? careTimeDate;

  Future<void> _pickImage() async {// lay anh tu thu vien 
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {//ham chon ngay
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: harvestDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != harvestDate) {
      setState(() {
        harvestDate = picked;
      });
    }
  }

  Future<void> _selectCareTimeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: careTimeDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != careTimeDate) {
      setState(() {
        careTimeDate = picked;
      });
    }
  }

  String _generateQRCodeData(DiaryEntry entry) {
    return "Giống cây: ${entry.plantVariety ?? ''}\n"
        "Thời gian thực hiện: ${entry.careTime ?? ''}\n"
        "Địa điểm: ${entry.careLocation ?? ''}\n"
        "Nhân viên thực hiện: ${entry.careEmployee ?? ''}\n"
        "Thời gian phun thuốc: ${entry.sprayTime ?? ''}\n"
        "Ngày thu hoạch: ${entry.harvestDate != null ? DateFormat.yMd().format(entry.harvestDate!) : ''}\n"
        "Thông tin bảo quản: ${entry.storageInfo ?? ''}";
  }

  void _saveDiary() {
    _formKey.currentState?.save(); // save các thông tin đã nhập
    final entry = DiaryEntry( //  đưa các thông tin đã nhập vào trong thuộc tính của class
      plantVariety: plantVariety, // các giá trị màu tím này là các giá trị đã điền trong form
      careTime: careTimeDate != null ? DateFormat.yMd().format(careTimeDate!) : null,
      careLocation: careLocation,
      careEmployee: careEmployee,
      sprayTime: sprayTime,
      harvestDate: harvestDate,
      storageInfo: storageInfo,
      imageFile: _imageFile,
      webImage: _webImage,
    );
    final qrCodeData = _generateQRCodeData(entry); // taạo một qr code từ các thuộc tính trong đối tượng entry
    entry.qrCodeData = qrCodeData; // lưu qr code vào thuộc tính trong class entry
    savedDiaryEntries.add(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nhật ký đã được lưu!")),
    );
    _formKey.currentState?.reset();
    setState(() {
      _imageFile = null;
      _webImage = null;
      harvestDate = null;
      careTimeDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (kIsWeb) {
      if (_webImage != null) {
        imageWidget = Image.memory(_webImage!, height: 200, fit: BoxFit.cover); // ảnh có thẻ sẽ bị cắt đẻ vừa với khung hình
      } else {
        imageWidget = Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(child: Text("Chưa chọn hình ảnh")),
        );
      }
    } else {
      if (_imageFile != null) {
        imageWidget = Image.file(_imageFile!, height: 200, fit: BoxFit.cover);
      } else {
        imageWidget = Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(child: Text("Chưa chọn hình ảnh")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // set title ở giữa appbar
          children: [
            SizedBox(width: 8),
            Text("Trần Đình Đệ & Nguyễn Hải Đăng" "\n"
                "      Nhật Ký Trồng Trọt",
              style: TextStyle(color: Color(0xFFF28482)),)


          ],
        ),
      ),
      body: SingleChildScrollView( // Sử dụng cái na cho phép cuộn khi nội dung quá dài
        padding: const EdgeInsets.all(0.0),
        child: Form(
          key: _formKey,
          child: Column(

            children: [
              _buildInputField(
                labelText: "Giống cây",
                onSaved: (val) => plantVariety = val,
                color: Color(0xFFF7EDE2),
                icon: Icons.grass,
              ),
              _buildInputField(
                labelText: "Thời gian thực hiện", // Đã thêm dấu ngoặc kép
                onSaved: (val) => careTime = val, // val là giá trị người dùng nhập vào và sẽ được lưu vào care time
                color: Color(0xFFF7EDE2),
                icon: Icons.calendar_today,
                context: context,
              ),
              _buildInputField(
                labelText: "Địa điểm",
                onSaved: (val) => careLocation = val,
                color: Color(0xFFF7EDE2),
                icon: Icons.location_on,
              ),
              _buildInputField(
                labelText: "Nhân viên thực hiện",
                onSaved: (val) => careEmployee = val,
                color: Color(0xFFF7EDE2),
                icon: Icons.person,
              ),
              _buildInputField(
                labelText: "Thời gian phun thuốc",
                onSaved: (val) => sprayTime = val,
                color: Color(0xFFF7EDE2),
                icon: Icons.healing,
              ),
              _buildDateField(
                context: context,
                labelText: "Chọn ngày thu hoạch",
                color: Color(0xFFF7EDE2),
                icon: Icons.calendar_month,
              ),
              _buildInputField(
                labelText: "Thông tin bảo quản",
                onSaved: (val) => storageInfo = val,
                color: Color(0xFFF7EDE2),
                icon: Icons.inventory,
              ),
              SizedBox(height: 10), // Thêm khoảng cách giữa các trường nhập liệu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                children: [
                  // Phần chứa 2 nút ở giữa phần bên trái
                  Flexible(
                    flex: 1, // Chia tỷ lệ không gian hợp lý
                    child: Align(
                      alignment: Alignment.center, // Căn giữa theo chiều dọc
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Thu gọn chiều cao
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            label: Text("Duyệt Ảnh"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFCD5CE),
                              foregroundColor: Color(0xFF03071e),
                            ),
                          ),
                          SizedBox(height: 10), // Khoảng cách giữa hai nút
                          ElevatedButton.icon(
                            onPressed: _saveDiary,
                            icon: Icon(Icons.save),
                            label: Text("Lưu"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFCD5CE),
                              foregroundColor: Color(0xFF03071e),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Khung ảnh (chiếm phần còn lại của không gian)
                  Expanded(
                    flex: 2, // Chia tỷ lệ phần lớn không gian cho ảnh
                    child: Container(
                      width: double.infinity, // Đảm bảo không bị co lại
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: imageWidget,

                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required Color? color,
    IconData? icon,
    BuildContext? context,
  }) {
    if (labelText == "Thời gian thực hiện") {
      return Container(
        color: color,
        padding: EdgeInsets.all(8.0),
        child: ListTile(
          leading: Icon(icon),// hiển thị icon  bên trái
          title: Text(careTimeDate == null
              ? labelText // nếu là null thì hiển thị label text
              : '$labelText: ${DateFormat.yMd().format(careTimeDate!)}'),
          onTap: () => _selectCareTimeDate(context!), // nhấn vào thì hàm select này dược gọi
          subtitle: Divider(color: Colors.grey), // Thêm gạch dưới
        ),
      );
    }
    else {
      return Container(
        color: color,
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon),
          ),
          onSaved: onSaved,
        ),
      );
    }
  }

  Widget _buildDateField({
    required BuildContext context,
    required String labelText,
    required Color? color,
    IconData? icon,
  }) {
    return Container(
      color: color,
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(harvestDate == null
            ? labelText
            : '$labelText: ${DateFormat.yMd().format(harvestDate!)}'),
        onTap: () => _selectDate(context),
        subtitle: Divider(color: Colors.grey), // Thêm gạch dưới
      ),
    );
  }
}

class TraceabilityPage extends StatefulWidget {
  @override
  _TraceabilityPageState createState() => _TraceabilityPageState();
}

class _TraceabilityPageState extends State<TraceabilityPage> {
  String barcode = "Chưa quét";

  Future<void> scanBarcode() async {
    try {
      ScanResult result = await BarcodeScanner.scan();
      setState(() {
        barcode = result.rawContent;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Thông tin Truy xuất Nguồn gốc"),
            content: Text(barcode),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Đóng"),
              ),
            ],
          ),
        );
      });
    } catch (e) {
      setState(() {
        barcode = 'Lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Text("Truy xuất nguồn gốc", style: TextStyle(color: Color(0xFFF28482)),),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Kết quả quét: $barcode',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanBarcode,
              child: Text('Quét mã vạch/QR'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Text("Danh sách cây trồng",style: TextStyle(color: Color(0xFFF28482)),),
          ],
        ),
      ),
      body: ListView.separated(
        itemCount: savedDiaryEntries.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) { // index = itemCount - 1
          final entry = savedDiaryEntries[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: _buildLeadingImage(entry), // để ảnh bên trái
              title: Text(entry.plantVariety ?? "Chưa có tên"),
              subtitle: Text(
                "Ngày thu hoạch: ${entry.harvestDate != null ? DateFormat.yMd().format(entry.harvestDate!) : 'Chưa xác định'}",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryDetailPage(entry: entry),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeadingImage(DiaryEntry entry) {
    if (entry.webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          entry.webImage!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else if (entry.imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          entry.imageFile!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image, color: Colors.white),
      );
    }
  }
}
