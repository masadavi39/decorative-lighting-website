package util;

import com.itextpdf.io.font.FontProgram;
import com.itextpdf.io.font.FontProgramFactory;
import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.font.PdfFontFactory.EmbeddingStrategy;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import jakarta.servlet.ServletContext;
import model.Order;
import model.OrderDetail;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * PdfGenerator dùng font Unicode nhúng TTF để không lỗi tiếng Việt.
 * Đặt file font tại WAR: /WEB-INF/fonts/Roboto-Regular.ttf, /WEB-INF/fonts/Roboto-Bold.ttf
 * (có thể đổi Roboto thành NotoSans… nhưng phải sửa tên file bên dưới cho khớp).
 */
public class PdfGenerator {

    private static final String WAR_REGULAR = "/WEB-INF/fonts/Roboto-Regular.ttf";
    private static final String WAR_BOLD    = "/WEB-INF/fonts/Roboto-Bold.ttf";

    // (Tùy chọn) fallback qua classpath nếu bạn cũng đặt font ở src/main/resources/fonts/...
    private static final String CP_REGULAR  = "/fonts/Roboto-Regular.ttf";
    private static final String CP_BOLD     = "/fonts/Roboto-Bold.ttf";

    private static String formatVnd(double value) {
        NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
        return nf.format(value) + "₫";
    }

    // Backward-compat
    public static void generateOrderPdf(Order order, OutputStream os) throws Exception {
        generateOrderPdf(order, os, null);
    }

    public static void generateOrderPdf(Order order, OutputStream os, ServletContext ctx) throws Exception {
        PdfWriter writer = new PdfWriter(os);
        PdfDocument pdf = new PdfDocument(writer);
        Document document = new Document(pdf);

        // Nạp font Unicode (Regular/Bold) – NHÚNG trực tiếp
        PdfFont fontRegular = loadUnicodeFont(ctx, WAR_REGULAR, CP_REGULAR, "Regular");
        PdfFont fontBold    = loadUnicodeFont(ctx, WAR_BOLD,    CP_BOLD,    "Bold");

        // Header
        document.add(new Paragraph("BÁO GIÁ").setFont(fontBold).setFontSize(18));

        // Thông tin khách hàng/đơn
        document.add(new Paragraph("Khách hàng: " + safe(order.getReceiverName())).setFont(fontRegular));
        document.add(new Paragraph("Điện thoại: " + safe(order.getPhone())).setFont(fontRegular));
        document.add(new Paragraph("Địa chỉ: " + safe(order.getAddress())).setFont(fontRegular));
        if (order.getCouponCode() != null && !order.getCouponCode().isEmpty()) {
            document.add(new Paragraph("Mã giảm giá: " + order.getCouponCode()).setFont(fontRegular));
        }
        if (order.getNote() != null && !order.getNote().isEmpty()) {
            document.add(new Paragraph("Ghi chú: " + order.getNote()).setFont(fontRegular));
        }
        document.add(new Paragraph("\n").setFont(fontRegular));

        // Bảng chi tiết
        float[] columnWidths = {240, 70, 100, 120};
        Table table = new Table(columnWidths);

        table.addHeaderCell(new Cell().add(new Paragraph("Sản phẩm").setFont(fontBold)));
        table.addHeaderCell(new Cell().add(new Paragraph("SL").setFont(fontBold)));
        table.addHeaderCell(new Cell().add(new Paragraph("Đơn giá").setFont(fontBold)));
        table.addHeaderCell(new Cell().add(new Paragraph("Thành tiền").setFont(fontBold)));

        double subtotal = 0.0;
        if (order.getOrderDetails() != null) {
            for (OrderDetail d : order.getOrderDetails()) {
                String productName = (d.getProduct() != null && d.getProduct().getName() != null && !d.getProduct().getName().isEmpty())
                        ? d.getProduct().getName()
                        : ("Sản phẩm #" + d.getProductId());

                double lineTotal = d.getSubtotal();
                subtotal += lineTotal;

                table.addCell(new Paragraph(safe(productName)).setFont(fontRegular));
                table.addCell(new Paragraph(String.valueOf(d.getQuantity())).setFont(fontRegular));
                table.addCell(new Paragraph(formatVnd(d.getPrice())).setFont(fontRegular));
                table.addCell(new Paragraph(formatVnd(lineTotal)).setFont(fontRegular));
            }
        }

        // Tổng phụ
        table.addCell(new Cell(1, 3).add(new Paragraph("Tạm tính").setFont(fontBold)));
        table.addCell(new Cell().add(new Paragraph(formatVnd(subtotal)).setFont(fontBold)));

        // Phí ship
        double shipping = order.getShippingFee() != 0 ? order.getShippingFee() : 0;
        table.addCell(new Cell(1, 3).add(new Paragraph("Phí vận chuyển").setFont(fontRegular)));
        table.addCell(new Cell().add(new Paragraph(formatVnd(shipping)).setFont(fontRegular)));

        // Thuế
        double tax = order.getTax() != 0 ? order.getTax() : 0;
        table.addCell(new Cell(1, 3).add(new Paragraph("Thuế").setFont(fontRegular)));
        table.addCell(new Cell().add(new Paragraph(formatVnd(tax)).setFont(fontRegular)));

        // Giảm giá
        double discount = order.getDiscountAmount() != 0 ? order.getDiscountAmount() : 0;
        if (discount > 0) {
            table.addCell(new Cell(1, 3).add(new Paragraph("Giảm giá").setFont(fontRegular)));
            table.addCell(new Cell().add(new Paragraph("-" + formatVnd(discount)).setFont(fontRegular)));
        }

        // Tổng cộng
        double computedTotal = subtotal + shipping + tax - discount;
        double total = order.getTotalPrice() > 0 ? order.getTotalPrice() : computedTotal;

        table.addCell(new Cell(1, 3).add(new Paragraph("Tổng cộng").setFont(fontBold)));
        table.addCell(new Cell().add(new Paragraph(formatVnd(total)).setFont(fontBold)));

        document.add(table);
        document.close();
    }

    /**
     * Nạp font theo thứ tự:
     * 1) WAR: ServletContext.getResourceAsStream("/WEB-INF/fonts/Roboto-*.ttf")
     * 2) Classpath: /fonts/Roboto-*.ttf
     * Nếu không tìm thấy → ném IOException rõ ràng (KHÔNG fallback Times/Helvetica).
     */
    private static PdfFont loadUnicodeFont(ServletContext ctx, String warPath, String cpPath, String tag) throws IOException {
        // 1) WAR (không phụ thuộc realPath)
        if (ctx != null) {
            try (InputStream is = ctx.getResourceAsStream(warPath)) {
                if (is != null) {
                    byte[] bytes = is.readAllBytes();
                    FontProgram fp = FontProgramFactory.createFont(bytes);
                    System.out.println("[PDF FONT] Loaded " + tag + " from WAR: " + warPath + " (" + bytes.length + " bytes)");
                    return PdfFontFactory.createFont(fp, PdfEncodings.IDENTITY_H, EmbeddingStrategy.PREFER_EMBEDDED);
                } else {
                    System.out.println("[PDF FONT] Not found in WAR: " + warPath);
                }
            } catch (Exception e) {
                System.out.println("[PDF FONT] Error reading WAR font " + warPath + ": " + e.getMessage());
            }
        }

        // 2) Classpath
        try (InputStream is = PdfGenerator.class.getResourceAsStream(cpPath)) {
            if (is != null) {
                byte[] bytes = is.readAllBytes();
                FontProgram fp = FontProgramFactory.createFont(bytes);
                System.out.println("[PDF FONT] Loaded " + tag + " from CLASSPATH: " + cpPath + " (" + bytes.length + " bytes)");
                return PdfFontFactory.createFont(fp, PdfEncodings.IDENTITY_H, EmbeddingStrategy.PREFER_EMBEDDED);
            } else {
                System.out.println("[PDF FONT] Not found in CLASSPATH: " + cpPath);
            }
        } catch (Exception e) {
            System.out.println("[PDF FONT] Error reading CLASSPATH font " + cpPath + ": " + e.getMessage());
        }

        throw new IOException("Font not found. Expected in WAR " + warPath + " or classpath " + cpPath + ".");
    }

    private static String safe(String s) { return s == null ? "" : s; }
}