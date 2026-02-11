package filter;

import dao.CategoryDAO;
import model.Category;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;
import java.util.List;

@WebFilter("/*")
public class CategoryFilter implements Filter {

    private CategoryDAO categoryDAO;

    @Override
    public void init(FilterConfig filterConfig) {
        categoryDAO = new CategoryDAO();
        System.out.println("[CategoryFilter] Initialized successfully");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        String uri = req.getRequestURI();

        // Bỏ qua static files
        if (uri.endsWith(".css") || uri.endsWith(".js") || uri.endsWith(".png") || 
            uri.endsWith(".jpg") || uri.endsWith(".jpeg") || uri.endsWith(".gif") || 
            uri.endsWith(".ico") || uri.endsWith(".woff") || uri.endsWith(".woff2")) {
            chain.doFilter(request, response);
            return;
        }

        // Set categories nếu chưa có
        if (req.getAttribute("categories") == null) {
            List<Category> categories = categoryDAO.getAllCategories();
            req.setAttribute("categories", categories);
            System.out.println("[CategoryFilter] Set " + categories.size() + " categories for: " + uri);
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}