<%-- 
    Document   : admin_check
    Created on : Nov 5, 2025, 9:03:01 AM
    Author     : admin
--%>
<%@ page import="model.User" %>
<%
    User u = (User) session.getAttribute("user");
    if (u == null || !"admin".equalsIgnoreCase(u.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
