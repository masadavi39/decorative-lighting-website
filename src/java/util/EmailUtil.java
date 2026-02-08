package util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.UnsupportedEncodingException;

public class EmailUtil {

    // ✅ Email người gửi (phải trùng với tài khoản đã bật App Password)
    private static final String FROM_EMAIL = "ttanh.dhti16a2hn@sv.uneti.edu.vn";
    private static final String APP_PASSWORD = "larmmpkuwvdc zvyt".replace(" ", ""); // Xóa khoảng trắng cho chắc

    public static void sendEmail(String toEmail, String subject, String messageText, boolean isOtp)
            throws MessagingException, UnsupportedEncodingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL, "UNETI Shop"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);

        // ✅ Nội dung khác nhau theo OTP hoặc reset password
        String htmlContent;
        if (isOtp) {
            htmlContent = """
            <html>
              <body style='font-family:Arial, sans-serif;'>
                <h3>Mã xác thực OTP của bạn:</h3>
                <p style='font-size:18px;color:#2c3e50;'><b>%s</b></p>
                <p>Mã này có hiệu lực trong 5 phút.</p>
                <p>Trân trọng,<br>UNETI Shop</p>
              </body>
            </html>
            """.formatted(messageText);
        } else { // reset password
            htmlContent = """
            <html>
              <body style='font-family:Arial, sans-serif;'>
                <p>Nhấn vào link sau để đặt lại mật khẩu (hết hạn 1 giờ):</p>
                <p><a href='%s'>%s</a></p>
                <p>Trân trọng,<br>UNETI Shop</p>
              </body>
            </html>
            """.formatted(messageText, messageText);
        }

        message.setContent(htmlContent, "text/html; charset=UTF-8");
        try {
            Transport.send(message);
            System.out.println("✅ Email đã gửi thành công tới: " + toEmail);
        } catch (MessagingException e) {
            e.printStackTrace(); // in chi tiết lỗi ra console
            throw e; // vẫn ném lên để servlet xử lý, ví dụ show "Gửi email thất bại!"
        }
    }

}
