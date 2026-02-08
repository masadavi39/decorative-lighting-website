package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ReviewDAO;
import model.Category;
import model.Product;
import model.ProductReview;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.text.Normalizer;
import java.util.LinkedList;
import java.util.List;

/**
 * Bổ sung nạp review: avgRating, reviewCount, reviews (approved).
 */
@WebServlet(name = "ProductServlet", urlPatterns = "/products")
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        String action = req.getParameter("action");

        if (action == null || action.equals("list")) {
            handleListAction(req, resp);
        } else if ("search".equals(action)) {
            handleSearchAction(req, resp);
        } else if ("detail".equals(action)) {
            handleDetailAction(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/products?action=list");
        }
    }

    private void handleListAction(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // giữ nguyên nội dung như bạn đã có
        String categoryParam = req.getParameter("category");
        String parentParam = req.getParameter("parent");
        String sortBy = req.getParameter("sortBy");

        int page = 1;
        int pageSize = 8;

        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }

        List<Product> products;
        int totalProducts;

        if (parentParam != null && !parentParam.isEmpty()) {
            try {
                int parentId = Integer.parseInt(parentParam);
                products = productDAO.getProductsByParentCategoryPagedSorted(parentId, page, pageSize, sortBy);
                totalProducts = productDAO.countProductsByParentCategory(parentId);
                req.setAttribute("selectedParent", parentId);
            } catch (NumberFormatException e) {
                products = productDAO.getProductsByPageSorted(page, pageSize, sortBy);
                totalProducts = productDAO.countProducts();
            }
        } else if (categoryParam != null && !categoryParam.isEmpty()) {
            switch (categoryParam.toLowerCase()) {
                case "trongnha" -> {
                    products = productDAO.getProductsByParentCategoryPagedSorted(1, page, pageSize, sortBy);
                    totalProducts = productDAO.countProductsByParentCategory(1);
                    req.setAttribute("selectedParentAlias", "trongnha");
                }
                case "ngoaitroi" -> {
                    products = productDAO.getProductsByParentCategoryPagedSorted(2, page, pageSize, sortBy);
                    totalProducts = productDAO.countProductsByParentCategory(2);
                    req.setAttribute("selectedParentAlias", "ngoaitroi");
                }
                default -> {
                    try {
                        int catId = Integer.parseInt(categoryParam);
                        products = productDAO.getProductsByCategoryPagedSorted(catId, page, pageSize, sortBy);
                        totalProducts = productDAO.countProductsByCategory(catId);
                        req.setAttribute("selectedCategory", catId);
                    } catch (NumberFormatException e) {
                        products = productDAO.getProductsByPageSorted(page, pageSize, sortBy);
                        totalProducts = productDAO.countProducts();
                    }
                }
            }
        } else {
            products = productDAO.getProductsByPageSorted(page, pageSize, sortBy);
            totalProducts = productDAO.countProducts();
        }

        List<Product> bestSellers = productDAO.getBestSellingProducts(5);
        List<Category> categories = categoryDAO.getAllCategories();

        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        req.setAttribute("products", products);
        req.setAttribute("bestSellers", bestSellers);
        req.setAttribute("categories", categories);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("selectedCategory", categoryParam);
        req.setAttribute("sortBy", sortBy);

        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    private void handleSearchAction(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // giữ nguyên như cũ
        String keyword = req.getParameter("keyword");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");
        String categoryStr = req.getParameter("category");
        String sortBy = req.getParameter("sortBy");

        int page = 1;
        int pageSize = 8;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }

        Double minPrice = (minPriceStr != null && !minPriceStr.isEmpty()) ? Double.valueOf(minPriceStr) : null;
        Double maxPrice = (maxPriceStr != null && !maxPriceStr.isEmpty()) ? Double.valueOf(maxPriceStr) : null;
        Integer categoryId = (categoryStr != null && !categoryStr.isEmpty()) ? Integer.valueOf(categoryStr) : null;

        if (keyword != null && !keyword.isEmpty()) {
            keyword = normalizeVietnameseText(keyword);
            System.out.println("=== Processed search keyword: [" + keyword + "] ===");
        }

        List<Product> products = productDAO.searchProductsAdvanced(keyword, minPrice, maxPrice, categoryId, page, pageSize, sortBy);
        int totalProducts = productDAO.countProductsAdvanced(keyword, minPrice, maxPrice, categoryId);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        List<Category> categories = categoryDAO.getAllCategories();

        req.setAttribute("products", products);
        req.setAttribute("categories", categories);
        req.setAttribute("searchKeyword", keyword != null ? keyword : "");
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("minPrice", minPriceStr);
        req.setAttribute("maxPrice", maxPriceStr);
        req.setAttribute("selectedCategory", categoryStr);
        req.setAttribute("sortBy", sortBy);

        req.getRequestDispatcher("search.jsp").forward(req, resp);
    }

    private void handleDetailAction(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                Product product = productDAO.getProductById(id);
                if (product != null) {
                    List<Product> relatedProducts = productDAO.getProductsByCategory(product.getCategoryId());
                    relatedProducts.removeIf(p -> p.getId() == product.getId());
                    if (relatedProducts.size() > 6)
                        relatedProducts = relatedProducts.subList(0, 6);

                    // Recent products (Session) như đã gửi trước
                    HttpSession session = req.getSession();
                    @SuppressWarnings("unchecked")
                    LinkedList<Integer> recentIds = (LinkedList<Integer>) session.getAttribute("recentProductIds");
                    if (recentIds == null) recentIds = new LinkedList<>();
                    recentIds.removeIf(pid -> pid == id);
                    recentIds.addFirst(id);
                    while (recentIds.size() > 12) recentIds.removeLast();
                    session.setAttribute("recentProductIds", recentIds);
                    List<Integer> idsToShow = recentIds.stream().filter(pid -> pid != id).toList();
                    List<Product> recentProducts = productDAO.getProductsByIdsPreserveOrder(idsToShow);

                    // Load reviews
                    List<ProductReview> reviews = reviewDAO.getApprovedByProduct(id);
                    Double avgRating = reviewDAO.getAverageRating(id);
                    Integer reviewCount = reviewDAO.countApproved(id);

                    req.setAttribute("product", product);
                    req.setAttribute("relatedProducts", relatedProducts);
                    req.setAttribute("recentProducts", recentProducts);
                    req.setAttribute("reviews", reviews);
                    req.setAttribute("avgRating", avgRating);
                    req.setAttribute("reviewCount", reviewCount);

                    req.getRequestDispatcher("product_detail.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException ignored) {}
        }
        resp.sendRedirect(req.getContextPath() + "/products?action=list");
    }

    private String normalizeVietnameseText(String text) {
        if (text == null || text.isEmpty()) return text;
        text = text.trim();
        text = Normalizer.normalize(text, Normalizer.Form.NFC);
        text = text.replaceAll("[^\\p{L}\\p{N}\\s\\-_.]", "");
        text = text.replaceAll("\\s+", " ").trim();
        return text;
    }
}