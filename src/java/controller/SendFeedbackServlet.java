package controller;

import dao.FeedbackDAO;
import model.Feedback;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;


@WebServlet(name = "SendFeedbackServlet", urlPatterns = "/SendFeedbackServlet")
public class SendFeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String message = req.getParameter("message");

        Feedback f = new Feedback(name, email, message);

        boolean ok = feedbackDAO.insert(f);
        if (ok) {
            resp.sendRedirect("contact.jsp?success=1");
        } else {
            resp.sendRedirect("contact.jsp?error=1");
        }
    }
}
