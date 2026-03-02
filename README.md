# decorative-lighting-website
### Requirement environtment
**Server:** Sử dụng glassfish 7 server ver 7.0.25 (tải theo đường dẫn [https://www.eclipse.org/downloads/download.php?file=/ee4j/glassfish/glassfish-7.0.25.zip](https://www.eclipse.org/downloads/download.php?file=/ee4j/glassfish/glassfish-7.0.25.zip)).  
**Java Development Kit:** jdk 21.  
**IDE:** Netbeans.  
**Database:** Truy cập folder có đường dẫn "decorative-lighting-website\src\java\Database\light_db.sql". Dùng XAMPP hoặc mysql server.  
### Setup and run
**Clone project:**
```bash
git clone https://github.com/masadavi39/decorative-lighting-website.git```
**Libary Configuration:**
Giải nén tệp 7z trong thư mục **lib** để lấy tệp .jar  
Vào Netbeans chuột phải vào project chọn mục properties -> categories -> libaries -> add jar/folder bạn vừa giải nén, add tất cả.  
### Server & Database Configuration
Mở NetBeans, vào tab Services -> Servers.  
Thêm GlassFish Server 7.0.25 (đảm bảo chọn đúng JDK 21).  
Import file cơ sở dữ liệu (thường nằm trong thư mục /database hoặc /sql) vào hệ quản trị CSDL của bạn.  
Kiểm tra lại chuỗi kết nối (Connection String) trong code để khớp với User/Pass database của bạn.  
### Run project
Chuột phải vào Project -> chọn Clean and Build.  
Chuột phải vào Project -> chọn Run.  
Trình duyệt sẽ tự động mở tại địa chỉ: http://localhost:8080/decorative-lighting-website/  