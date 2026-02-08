package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Đảm bảo mọi request dùng UTF-8 nếu chưa có.
 * Không ghi đè Content-Type của tài nguyên binary / PDF.
 */
public class CharacterEncodingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        // Chỉ set nếu chưa có để tránh cảnh báo trùng lặp
        if (request.getCharacterEncoding() == null) {
            request.setCharacterEncoding("UTF-8");
        }
        response.setCharacterEncoding("UTF-8");

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;
        String uri = httpReq.getRequestURI();

        if (!isBinaryOrPdf(uri) && httpResp.getContentType() == null) {
            // Chỉ set nếu chưa có contentType và không phải endpoint binary
            httpResp.setContentType("text/html; charset=UTF-8");
        }

        chain.doFilter(request, response);
    }

    private boolean isBinaryOrPdf(String uri) {
        if (uri == null) return false;
        String lower = uri.toLowerCase();
        // PDF hoặc tài nguyên tĩnh
        return lower.contains("/quote") // servlet PDF
                || lower.endsWith(".pdf")
                || lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".gif")
                || lower.endsWith(".webp")
                || lower.endsWith(".svg")
                || lower.endsWith(".js")
                || lower.endsWith(".css")
                || lower.endsWith(".ico")
                || lower.endsWith(".json");
    }
}