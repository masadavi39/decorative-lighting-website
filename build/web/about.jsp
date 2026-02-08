<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giới thiệu</title>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --gold: var(--gold, #d4af37);
            --gold-soft: var(--gold-soft, #e6c763);
            --text-dark: var(--text-dark, #1a1a1a);
            --text-muted: var(--text-muted, #666);
            --bg-white: var(--bg-white, #fff);
            --bg-soft: var(--bg-soft, #fafafa);
            --border: var(--border, #e6e6e6);
            --radius-sm: var(--radius-sm, 8px);
            --radius-md: var(--radius-md, 12px);
            --shadow: var(--shadow, 0 8px 24px rgba(0,0,0,0.06));
            --focus-ring: var(--focus-ring, 0 0 0 3px rgba(212,175,55,0.35));
            --font-main: var(--font-main, 'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif);
            --transition: var(--transition, .25s ease);
        }

        body.about-page {
            font-family: var(--font-main);
            background-color: var(--bg-soft);
            color: var(--text-dark);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        .about-wrapper {
            max-width: 1200px;
            margin: 34px auto 70px;
            padding: 0 20px;
        }

        .about-wrapper h2 {
            text-align: center;
            color: var(--text-dark);
            font-size: 2.2rem;
            margin-bottom: 28px;
            letter-spacing: .3px;
        }

        .about-wrapper .intro-text {
            text-align: center;
            color: var(--text-muted);
            font-size: 1.05rem;
            max-width: 820px;
            margin: 0 auto 44px;
        }

        .about-wrapper .category-container {
            display: flex;
            gap: 28px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .about-wrapper .category-card {
            background: var(--bg-white);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 24px;
            width: 450px;
            text-align: center;
            box-shadow: var(--shadow);
            transition: transform var(--transition), box-shadow var(--transition);
        }

        .about-wrapper .category-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 14px 40px rgba(0,0,0,0.08);
        }

        .about-wrapper .category-card img {
            width: 100%;
            height: 250px;
            object-fit: cover;
            border-radius: calc(var(--radius-md) - 4px);
            margin-bottom: 16px;
            border: 1px solid var(--border);
        }

        .about-wrapper .category-card h3 {
            color: var(--text-dark);
            font-size: 1.3rem;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .about-wrapper .category-card p {
            color: var(--text-muted);
            margin-bottom: 18px;
            font-size: 0.98rem;
        }

        .about-wrapper .button {
            background-color: var(--gold);
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 999px;
            text-decoration: none;
            display: inline-block;
            font-weight: 600;
            letter-spacing: .3px;
            transition: filter var(--transition), background-color var(--transition), transform .15s ease;
        }
        .about-wrapper .button:hover {
            background-color: var(--gold-soft);
            filter: brightness(1.02);
            transform: translateY(-1px);
        }
        .about-wrapper .button:active {
            transform: translateY(0);
        }

        @media (max-width: 992px) {
            .about-wrapper .category-card {
                width: 100%;
                max-width: 520px;
            }
            .about-wrapper h2 { font-size: 2rem; }
        }
        @media (max-width: 640px) {
            .about-wrapper { padding: 0 16px; margin-top: 26px; }
            .about-wrapper .category-card img { height: 210px; }
            .about-wrapper .intro-text { font-size: 1rem; }
        }
    </style>
</head>
<body class="about-page">
<%@ include file="partials/header.jsp" %>

<main class="about-wrapper" role="main">
    <h2>Giới thiệu về Web Bán Đèn Trang Trí</h2>
    <p class="intro-text">
        Chào mừng bạn đến với <strong>Web Bán Đèn Trang Trí</strong> – nơi cung cấp các sản phẩm chiếu sáng hiện đại và phong cách.
        Chúng tôi phân chia sản phẩm theo 2 dòng chính để giúp bạn dễ dàng lựa chọn phù hợp với không gian sống.
    </p>

    <div class="category-container">
        <div class="category-card">
            <img src="${pageContext.request.contextPath}/images/indoor.jpg" alt="Chiếu sáng trong nhà">
            <h3>💡 Chiếu sáng trong nhà</h3>
            <p>
                Mang lại ánh sáng ấm áp, sang trọng cho không gian sống của bạn với các mẫu
                <strong>đèn chùm, đèn bàn, đèn tường, đèn ốp trần</strong> đa dạng phong cách.
            </p>
            <a href="${pageContext.request.contextPath}/products?category=trongnha" class="button">
                Xem sản phẩm
            </a>
        </div>

        <div class="category-card">
            <img src="${pageContext.request.contextPath}/images/outdoor.jpg" alt="Chiếu sáng ngoài trời">
            <h3>🌟 Chiếu sáng ngoài trời</h3>
            <p>
                Tô điểm cho không gian sân vườn, cổng và lối đi với các mẫu
                <strong>đèn trụ cổng, đèn pha, đèn sân vườn</strong> bền đẹp, tiết kiệm năng lượng.
            </p>
            <a href="${pageContext.request.contextPath}/products?category=ngoaitroi" class="button">
                Xem sản phẩm
            </a>
        </div>
    </div>
</main>

<%@ include file="partials/footer.jsp" %>
</body>
</html>