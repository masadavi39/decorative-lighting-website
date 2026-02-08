package controller;

import com.google.gson.Gson;
import dao.ChatDAO;
import dao.UserDAO;
import model.ChatMessage;
import model.User; // Class User của bạn
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Set;

@WebServlet(name = "ChatServlet", urlPatterns = {"/chat-api"})
public class ChatServlet extends HttpServlet {

    private final ChatDAO chatDAO = new ChatDAO();
    private final Gson gson = new Gson();

    // Xử lý gửi tin nhắn (POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String content = request.getParameter("content");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user"); // Lấy đúng tên "user"

        // Xác định ID người gửi
        String senderId;
        if (currentUser != null) {
            senderId = String.valueOf(currentUser.getId());
        } else {
            senderId = session.getId(); // Khách vãng lai
        }

        PrintWriter out = response.getWriter();

        if ("send".equals(action) && content != null && !content.trim().isEmpty()) {
            // Logic cho KHÁCH HÀNG gửi
            ChatMessage msg = new ChatMessage(senderId, "USER", content);
            chatDAO.saveMessage(msg);
            out.print("{\"status\":\"success\"}");

        } else if ("admin_send".equals(action)) {
            // Logic cho ADMIN gửi (Admin phải truyền lên ID người nhận)
            String targetUserId = request.getParameter("targetId");
            if (targetUserId != null) {
                ChatMessage msg = new ChatMessage(targetUserId, "ADMIN", content);
                chatDAO.saveMessage(msg);
                out.print("{\"status\":\"success\"}");
            }
        }
        out.flush();
    }

    // Xử lý tải dữ liệu (GET)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        // Trong ChatServlet.java
        if ("admin_load_users".equals(action)) {
            // 1. Lấy danh sách ID từ ChatDAO
            Set<String> userIds = chatDAO.getUsersWhoChatted();
            UserDAO userDAO = new UserDAO();

            StringBuilder json = new StringBuilder("[");
            int i = 0;

            for (String uid : userIds) {
                String displayName = "Khách (" + uid + ")"; // Tên mặc định

                // 2. Kiểm tra xem uid có phải là số không (User đã đăng ký)
                try {
                    // Cố gắng ép kiểu sang số nguyên
                    int idInt = Integer.parseInt(uid);

                    // Nếu ép kiểu thành công, tìm trong bảng Users
                    User u = userDAO.getUserById(idInt);
                    if (u != null && u.getFullName() != null) {
                        displayName = u.getFullName(); // Lấy tên thật: "Nguyễn Văn A"
                    } else {
                        displayName = "User #" + uid; // Có ID số nhưng không tìm thấy trong bảng User
                    }
                } catch (NumberFormatException e) {
                    // Nếu uid không phải là số (ví dụ: session ID dài ngoằng), giữ nguyên là "Khách"
                    // displayName = "Khách vãng lai"; 
                }

                // 3. Tạo JSON an toàn (Xử lý ký tự đặc biệt nếu có)
                // cleanName giúp tránh lỗi JSON nếu tên có dấu ngoặc kép "
                String cleanName = displayName.replace("\"", "\\\"");

                json.append("{")
                        .append("\"id\":\"").append(uid).append("\",")
                        .append("\"name\":\"").append(cleanName).append("\"")
                        .append("}");

                if (i < userIds.size() - 1) {
                    json.append(",");
                }
                i++;
            }
            json.append("]");

            // 4. Debug: In ra log server để kiểm tra xem có lấy được tên không
            System.out.println("DEBUG User List JSON: " + json.toString());

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());
        } else if ("admin_load_chat".equals(action)) {
            // --- API CHO ADMIN: Lấy lịch sử chat với 1 khách cụ thể ---
            String targetId = request.getParameter("targetId");
            List<ChatMessage> history = chatDAO.getHistory(targetId);
            out.print(gson.toJson(history));

        } else {

            User currentUser = (User) session.getAttribute("user");
            String myId = (currentUser != null) ? String.valueOf(currentUser.getId()) : session.getId();

            List<ChatMessage> history = chatDAO.getHistory(myId);
            out.print(gson.toJson(history));
        }
        out.flush();
    }
}
