package model;

/**
 * Represents a single product in the shop. Products belong to a category
 * và có thêm các thuộc tính nâng cao cho admin: promoPrice, status, quantity, soldQuantity, manufacturer.
 */
public class Product {
    private int id;
    private int categoryId;
    private String name;
    private String description;
    private double price;

    // NEW: giá khuyến mãi (nullable)
    private Double promoPrice;

    // NEW: trạng thái sản phẩm
    // active | inactive | out_of_stock
    private String status;

    private String imagePath;
    private String categoryName;

    private int soldQuantity;
    private String manufacturer;
    private int quantity;

    public Product() {}

    public Product(int id, int categoryId, String name, String description, double price, String imagePath) {
        this.id = id;
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.imagePath = imagePath;
        this.soldQuantity = 0;
        this.manufacturer = null;
        this.quantity = 0;
        this.status = "active";
    }

    public Product(int categoryId, String name, String description, double price, String imagePath) {
        this(0, categoryId, name, description, price, imagePath);
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public Double getPromoPrice() { return promoPrice; }
    public void setPromoPrice(Double promoPrice) { this.promoPrice = promoPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public int getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(int soldQuantity) { this.soldQuantity = soldQuantity; }
    public String getManufacturer() { return manufacturer; }
    public void setManufacturer(String manufacturer) { this.manufacturer = manufacturer; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}