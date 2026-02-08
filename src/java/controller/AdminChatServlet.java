package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name="AdminChatServlet", urlPatterns={"/admin/chat"})
public class AdminChatServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    // Kiểm tra quyền admin
    HttpSession session = req.getSession(false);
    model.User user = (session != null) ? (model.User) session.getAttribute("user") : null;
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      resp.sendRedirect(req.getContextPath() + "/auth?action=login");
      return;
    }

    req.getRequestDispatcher("/admin/admin_chat.jsp").forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    // Có thể chặn POST tương tự (nếu cần)
    HttpSession session = request.getSession(false);
    model.User user = (session != null) ? (model.User) session.getAttribute("user") : null;
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/auth?action=login");
      return;
    }
    // Nếu dùng processRequest trước đây, bạn có thể thay bằng forward về chat JSP hoặc xử lý theo API riêng
    request.getRequestDispatcher("/admin/admin_chat.jsp").forward(request, response);
  }

  @Override
  public String getServletInfo() {
    return "Admin Chat (protected)";
  }
}