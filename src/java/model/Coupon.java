package model;

import java.util.Date;

public class Coupon {
    private int id;
    private String code;
    private String description;

    // ENUM: percent / fixed
    private String discountType;

    // Giá trị giảm: 
    // - Nếu percent → value = 10, 20, 50...
    // - Nếu fixed   → value = 30000, 50000...
    private Double value;

    private boolean active;
    private Date startDate;
    private Date endDate;

    private Double minSubtotal;   // điều kiện áp dụng
    private Double maxDiscount;   // giảm tối đa (cho percent)
    
    private Integer usageLimit;   // giới hạn sử dụng
    private Integer usedCount;    // đã dùng bao nhiêu

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public Double getValue() { return value; }
    public void setValue(Double value) { this.value = value; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public Double getMinSubtotal() { return minSubtotal; }
    public void setMinSubtotal(Double minSubtotal) { this.minSubtotal = minSubtotal; }

    public Double getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(Double maxDiscount) { this.maxDiscount = maxDiscount; }

    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

    public Integer getUsedCount() { return usedCount; }
    public void setUsedCount(Integer usedCount) { this.usedCount = usedCount; }
}
