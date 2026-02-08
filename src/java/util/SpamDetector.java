package util;

import java.util.*;
import java.util.regex.Pattern;

public class SpamDetector {

    public static class Result {
        public final boolean spam;
        public final double score;
        public final List<String> reasons;

        public Result(boolean spam, double score, List<String> reasons) {
            this.spam = spam;
            this.score = score;
            this.reasons = reasons;
        }
    }

    // Một số từ khóa/tên miền thường gặp trong spam, có thể mở rộng
    private static final String[] BANNED_KEYWORDS = new String[]{
            "viagra", "casino", "bet", "cờ bạc", "sex", "loan",
            "http://", "https://", "www.", ".com", ".ru", ".xyz",
            "hotline", "vay", "kiếm tiền", "thu nhập thụ động"
    };

    private static final Pattern REPEATED_CHAR = Pattern.compile("(.)\\1{5,}"); // >6 ký tự lặp
    private static final Pattern MULTI_LINK = Pattern.compile("(https?://|www\\.)", Pattern.CASE_INSENSITIVE);

    // Ngưỡng đơn giản, có thể tinh chỉnh
    private static final int MIN_CONTENT_LEN = 10;
    private static final int MAX_LINKS = 1;
    private static final double MAX_NON_ALPHA_RATIO = 0.6;
    private static final double SPAM_SCORE_THRESHOLD = 2.0;

    public static Result evaluate(String title, String content) {
        List<String> reasons = new ArrayList<>();
        double score = 0.0;

        String t = safe(title);
        String c = safe(content);
        String text = (t + " " + c).trim();

        // 1) Độ dài nội dung
        if (c.length() < MIN_CONTENT_LEN) {
            score += 1.0;
            reasons.add("Nội dung quá ngắn");
        }

        // 2) Link quá nhiều
        int links = countLinks(text);
        if (links > MAX_LINKS) {
            score += 1.0 + Math.min(links - MAX_LINKS, 3) * 0.5;
            reasons.add("Quá nhiều liên kết (" + links + ")");
        }

        // 3) Từ khóa cấm
        int kwHits = countBanned(text);
        if (kwHits > 0) {
            score += 0.7 * kwHits;
            reasons.add("Chứa từ khóa khả nghi (" + kwHits + ")");
        }

        // 4) Lặp ký tự bất thường
        if (REPEATED_CHAR.matcher(text).find()) {
            score += 0.8;
            reasons.add("Lặp ký tự bất thường");
        }

        // 5) Tỷ lệ ký tự không phải chữ
        double nonAlphaRatio = nonAlphaRatio(text);
        if (nonAlphaRatio > MAX_NON_ALPHA_RATIO) {
            score += 0.7;
            reasons.add("Tỷ lệ ký tự không phải chữ cao");
        }

        // 6) Tiêu đề chỉ toàn ký tự đặc biệt
        if (!t.isEmpty() && nonAlphaRatio(t) > 0.9) {
            score += 0.4;
            reasons.add("Tiêu đề không hợp lệ");
        }

        boolean spam = score >= SPAM_SCORE_THRESHOLD;
        return new Result(spam, score, reasons);
    }

    private static String safe(String s) {
        return s == null ? "" : s.trim();
    }

    private static int countLinks(String s) {
        int count = 0;
        var m = MULTI_LINK.matcher(s);
        while (m.find()) count++;
        // thêm heuristic: domain phổ biến không có schema
        count += countOccurrences(s.toLowerCase(Locale.ROOT), ".com");
        return count;
    }

    private static int countBanned(String s) {
        String low = s.toLowerCase(Locale.ROOT);
        int hits = 0;
        for (String k : BANNED_KEYWORDS) {
            if (low.contains(k)) hits++;
        }
        return hits;
    }

    private static int countOccurrences(String s, String sub) {
        int idx = 0, c = 0;
        while ((idx = s.indexOf(sub, idx)) != -1) {
            c++; idx += sub.length();
        }
        return c;
    }

    private static double nonAlphaRatio(String s) {
        if (s.isEmpty()) return 0.0;
        int non = 0;
        for (char ch : s.toCharArray()) {
            if (Character.isLetter(ch) || Character.isDigit(ch) || Character.isWhitespace(ch)) {
                // ok
            } else {
                non++;
            }
        }
        return non / (double) s.length();
    }
}