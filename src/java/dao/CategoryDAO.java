package dao;

import model.Category;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for accessing categories from the database (supports parent-child hierarchy).
 */
public class CategoryDAO {

    /**
     * Lấy tất cả danh mục, bao gồm cả danh mục cha và con.
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY parent_id, name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setName(rs.getString("name"));
                Object parentObj = rs.getObject("parent_id");
                c.setParentId(parentObj != null ? rs.getInt("parent_id") : null);
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả danh mục cha (những danh mục không có parent_id).
     */
    public List<Category> getParentCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE parent_id IS NULL ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setName(rs.getString("name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh mục con theo ID danh mục cha.
     */
    public List<Category> getSubCategories(int parentId) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE parent_id = ? ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setCategoryId(rs.getInt("category_id"));
                    c.setName(rs.getString("name"));
                    c.setParentId(rs.getInt("parent_id"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm danh mục mới (có thể có hoặc không có parent_id).
     */
    public boolean insert(Category category) {
        String sql = "INSERT INTO categories (name, parent_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            if (category.getParentId() != null)
                ps.setInt(2, category.getParentId());
            else
                ps.setNull(2, java.sql.Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
