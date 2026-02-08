package dao;

import model.Product;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ProductDAO chuẩn hoá cho schema 'products'. Bao gồm: CRUD, phân trang + sort,
 * lọc theo danh mục cha/con, tìm kiếm nâng cao, tồn kho, bán chạy.
 * BỔ SUNG: promo_price, status, searchProductsAdmin + countProductsAdmin, insert/update full.
 */
public class ProductDAO {

    /* ========== CRUD cơ bản ========== */
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id = p.category_id ORDER BY p.product_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = extractProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id = p.category_id WHERE p.product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Version chuẩn cũ (giữ để tương thích)
    public boolean insertProduct(Product p) {
        String sql = """
            INSERT INTO products (category_id, name, description, price, quantity, sold_quantity, manufacturer, image_path)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setInt(5, p.getQuantity());
            ps.setInt(6, p.getSoldQuantity());
            ps.setString(7, p.getManufacturer());
            ps.setString(8, p.getImagePath());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Thêm mới FULL: có promo_price và status
    public boolean insertProductFull(Product p) {
        String sql = """
            INSERT INTO products (category_id, name, description, price, promo_price, status, quantity, sold_quantity, manufacturer, image_path)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            if (p.getPromoPrice() == null) ps.setNull(5, Types.DECIMAL); else ps.setDouble(5, p.getPromoPrice());
            ps.setString(6, p.getStatus() != null ? p.getStatus() : "active");
            ps.setInt(7, p.getQuantity());
            ps.setInt(8, p.getSoldQuantity());
            ps.setString(9, p.getManufacturer());
            ps.setString(10, p.getImagePath());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật chuẩn cũ (giữ để tương thích)
    public boolean updateProduct(Product p) {
        String sql = """
            UPDATE products
            SET category_id=?, name=?, description=?, price=?,
                quantity=?, sold_quantity=?, manufacturer=?, image_path=?
            WHERE product_id=?
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setInt(5, p.getQuantity());
            ps.setInt(6, p.getSoldQuantity());
            ps.setString(7, p.getManufacturer());
            ps.setString(8, p.getImagePath());
            ps.setInt(9, p.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật FULL: promo_price + status
    public boolean updateProductFull(Product p) {
        String sql = """
            UPDATE products
               SET category_id=?, name=?, description=?, price=?,
                   promo_price=?, status=?,
                   quantity=?, sold_quantity=?, manufacturer=?, image_path=?
             WHERE product_id=?
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            if (p.getPromoPrice() == null) ps.setNull(5, Types.DECIMAL); else ps.setDouble(5, p.getPromoPrice());
            ps.setString(6, p.getStatus() != null ? p.getStatus() : "active");
            ps.setInt(7, p.getQuantity());
            ps.setInt(8, p.getSoldQuantity());
            ps.setString(9, p.getManufacturer());
            ps.setString(10, p.getImagePath());
            ps.setInt(11, p.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ========== Phân trang + sắp xếp ========== */
    private String buildOrderClause(String sortBy) {
        if ("price_asc".equalsIgnoreCase(sortBy)) {
            return "ORDER BY p.price ASC";
        }
        if ("price_desc".equalsIgnoreCase(sortBy)) {
            return "ORDER BY p.price DESC";
        }
        if ("name_asc".equalsIgnoreCase(sortBy)) {
            return "ORDER BY p.name ASC";
        }
        if ("name_desc".equalsIgnoreCase(sortBy)) {
            return "ORDER BY p.name DESC";
        }
        return "ORDER BY p.product_id DESC";
    }

    public List<Product> getProductsByPageSorted(int page, int pageSize, String sortBy) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id "
                   + buildOrderClause(sortBy) + " LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ========== Theo danh mục con (category) ========== */
    public List<Product> getProductsByCategory(int categoryId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE p.category_id = ? ORDER BY p.product_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getProductsByCategoryPagedSorted(int categoryId, int page, int pageSize, String sortBy) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE p.category_id = ? "
                   + buildOrderClause(sortBy) + " LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductsByCategory(int categoryId) {
        String sql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ========== Theo danh mục cha (parent category) ========== */
    public List<Product> getProductsByParentCategory(int parentId) {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.*, c.name AS category_name
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE c.parent_id = ? OR p.category_id = ?
            ORDER BY p.product_id DESC
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getProductsByParentCategoryPagedSorted(int parentId, int page, int pageSize, String sortBy) {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.*, c.name AS category_name
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE c.parent_id = ? OR p.category_id = ?
        """ + buildOrderClause(sortBy) + " LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, parentId);
            ps.setInt(3, pageSize);
            ps.setInt(4, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductsByParentCategory(int parentId) {
        String sql = """
            SELECT COUNT(*)
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE c.parent_id = ? OR p.category_id = ?
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ========== Tìm kiếm nâng cao (front) ========== */
    public List<Product> searchProductsAdvanced(String keyword, Double minPrice, Double maxPrice,
                                                Integer categoryId, int page, int pageSize, String sortBy) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        sql.append(" ").append(buildOrderClause(sortBy)).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductsAdvanced(String keyword, Double minPrice, Double maxPrice, Integer categoryId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(p.product_id) FROM products p WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ========== Admin search + count (BỔ SUNG) ========== */
    public List<Product> searchProductsAdmin(String keyword, Integer categoryId,
                                             Double minPrice, Double maxPrice,
                                             String status, String sortBy,
                                             int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT p.*, c.name AS category_name
            FROM products p
            JOIN categories c ON c.category_id = p.category_id
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(p.manufacturer) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (status != null && !status.isBlank() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND p.status = ?");
            params.add(status);
        }

        sql.append(" ").append(buildOrderClause(sortBy)).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductsAdmin(String keyword, Integer categoryId,
                                  Double minPrice, Double maxPrice,
                                  String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(p.manufacturer) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (status != null && !status.isBlank() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND p.status = ?");
            params.add(status);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ========== Doanh thu & bán chạy ========== */
    public List<String[]> getRevenueByProduct() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT name, price * sold_quantity AS revenue FROM products";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{rs.getString("name"), String.valueOf(rs.getDouble("revenue"))});
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getBestSellingProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id ORDER BY p.sold_quantity DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product p = extractProduct(rs);
                        p.setCategoryName(rs.getString("category_name"));
                        list.add(p);
                    }
                }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ========== Tồn kho ========== */
    public List<Product> getLowStockProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE p.quantity <= 20 ORDER BY p.quantity ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = extractProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getInStockProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE p.quantity > 20 ORDER BY p.quantity ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = extractProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateQuantity(int productId, int quantityToAdd) {
        String sql = "UPDATE products SET quantity = quantity + ? WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityToAdd);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean decreaseQuantity(int productId, int amount) {
        String sql = "UPDATE products SET quantity = quantity - ? WHERE product_id = ? AND quantity >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, amount);
            ps.setInt(2, productId);
            ps.setInt(3, amount);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int productId, String status) {
        String sql = "UPDATE products SET status = ? WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /* ========== Lấy theo list ID (giữ thứ tự) ========== */
    public List<Product> getProductsByIdsPreserveOrder(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }
        StringBuilder sql = new StringBuilder("SELECT p.*, c.name AS category_name FROM products p JOIN categories c ON c.category_id=p.category_id WHERE p.product_id IN (");
        for (int i = 0; i < ids.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(")");

        Map<Integer, Product> map = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = extractProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    map.put(p.getId(), p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<Product> result = new ArrayList<>();
        for (Integer id : ids) {
            Product p = map.get(id);
            if (p != null) {
                result.add(p);
            }
        }
        return result;
    }

    /* ========== Helper ========== */
    private Product extractProduct(ResultSet rs) {
        Product p = new Product();
        try {
            p.setId(rs.getInt("product_id"));
            p.setCategoryId(rs.getInt("category_id"));
            p.setName(rs.getString("name"));
            p.setDescription(rs.getString("description"));
            p.setPrice(rs.getDouble("price"));
            p.setPromoPrice(getNullableDouble(rs, "promo_price"));
            p.setStatus(rs.getString("status"));
            p.setImagePath(rs.getString("image_path"));
            try { p.setSoldQuantity(rs.getInt("sold_quantity")); } catch (Exception ignore) {}
            try { p.setManufacturer(rs.getString("manufacturer")); } catch (Exception ignore) {}
            try { p.setQuantity(rs.getInt("quantity")); } catch (Exception ignore) {}
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }

    private Double getNullableDouble(ResultSet rs, String col) {
        try {
            double v = rs.getDouble(col);
            return rs.wasNull() ? null : v;
        } catch (SQLException e) {
            return null;
        }
    }
}