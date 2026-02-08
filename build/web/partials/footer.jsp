<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Professional Footer -->
<footer class="site-footer" role="contentinfo" aria-label="Thông tin trang">
  <div class="footer-container">
    <!-- Brand / Intro -->
    <div class="footer-col">
      <a class="footer-logo" href="${pageContext.request.contextPath}/products?action=list" aria-label="Trang chủ">
        <i class="fas fa-lightbulb" aria-hidden="true"></i>
        <span>Web Bán Đèn Trang Trí</span>
      </a>
      <p class="footer-desc">
        Cung cấp giải pháp chiếu sáng trang trí cho không gian sống và làm việc của bạn. Uy tín – chất lượng – bảo hành rõ ràng.
      </p>
      <div class="footer-social" aria-label="Mạng xã hội">
        <a href="#" aria-label="Facebook" title="Facebook"><i class="fab fa-facebook-f"></i></a>
        <a href="#" aria-label="Instagram" title="Instagram"><i class="fab fa-instagram"></i></a>
        <a href="#" aria-label="YouTube" title="YouTube"><i class="fab fa-youtube"></i></a>
        <a href="#" aria-label="TikTok" title="TikTok"><i class="fab fa-tiktok"></i></a>
      </div>
    </div>

    <!-- Quick links -->
    <div class="footer-col">
      <h4>Liên kết nhanh</h4>
      <ul class="footer-links">
        <li><a href="${pageContext.request.contextPath}/products?action=list">Trang chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/about.jsp">Giới thiệu</a></li>
        <li><a href="${pageContext.request.contextPath}/contact.jsp">Liên hệ</a></li>
        <li><a href="${pageContext.request.contextPath}/orders?action=list">Đơn hàng của tôi</a></li>
      </ul>
    </div>

    <!-- Customer care -->
    <div class="footer-col">
      <h4>Chăm sóc khách hàng</h4>
      <ul class="footer-links">
        <li><a href="#">Chính sách bảo hành</a></li>
        <li><a href="#">Đổi trả và hoàn tiền</a></li>
        <li><a href="#">Vận chuyển và giao hàng</a></li>
        <li><a href="#">Hướng dẫn thanh toán</a></li>
      </ul>
    </div>

    <!-- Contact info -->
    <div class="footer-col">
      <h4>Thông tin liên hệ</h4>
      <ul class="footer-contact">
        <li><i class="fas fa-phone"></i><a href="tel:0123456789" aria-label="Gọi số 0123456789">0123 456 789</a></li>
        <li><i class="fas fa-envelope"></i><a href="mailto:support@example.com" aria-label="Email hỗ trợ">support@example.com</a></li>
        <li><i class="fas fa-location-dot"></i><span>123 Đường ABC, Quận XYZ, TP. HCM</span></li>
        <li><i class="fas fa-clock"></i><span>8:30 – 21:00 (T2–CN)</span></li>
      </ul>
      <form class="footer-newsletter" action="#" method="post" aria-label="Đăng ký nhận tin" onsubmit="return false;">
        <label class="sr-only" for="nl-email">Email</label>
        <input id="nl-email" type="email" placeholder="Nhập email của bạn" aria-label="Email nhận tin">
        <button type="button" onclick="alert('Đăng ký nhận tin thành công!')">Đăng ký</button>
      </form>
    </div>
  </div>

  <div class="footer-bottom">
    <div class="footer-copy">
      <span>© <script>document.write(new Date().getFullYear())</script> Web Bán Đèn Trang Trí. All rights reserved.</span>
      <span class="sep">•</span>
      <span>Thực hiện bởi nhóm 6</span>
    </div>
    <div class="footer-team">
      <span>Nguyễn Đức Biên (06/03/2004)</span>
      <span class="sep">•</span>
      <span>Hoàng Ngọc Duy (23/07/2004)</span>
      <span class="sep">•</span>
      <span>Nguyễn Văn Giáp (04/07/2004)</span>
      <span class="sep">•</span>
      <span>Trần Trung Anh (05/01/2004)</span>
    </div>
  </div>
</footer>

<style>
  :root{
    --footer-bg:#0f172a;          /* nền tối chuyên nghiệp */
    --footer-text:#e5e7eb;        /* text chính */
    --footer-muted:#94a3b8;       /* text phụ */
    --footer-border:#1f2937;      /* viền */
    --footer-link:#cbd5e1;        /* link */
    --footer-link-hover:#fff;     /* link hover */
    --footer-accent:#d4af37;      /* nhấn (gold đồng bộ) */
  }

  .site-footer{
    background:var(--footer-bg);
    color:var(--footer-text);
    padding:32px 20px 22px;
    border-top:1px solid var(--footer-border);
    font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  }
  .footer-container{
    max-width: 1320px;
    margin: 0 auto;
    display:grid;
    grid-template-columns: 2fr 1fr 1fr 1.4fr;
    gap: 28px;
    align-items: start;
  }

  .footer-col h4{
    margin: 0 0 12px;
    font-size: 1rem;
    font-weight: 700;
    color: #fff;
    letter-spacing: .2px;
  }
  .footer-desc{
    color: var(--footer-muted);
    font-size: .95rem;
    margin: 8px 0 14px;
    line-height: 1.6;
  }

  .footer-logo{
    display:flex; align-items:center; gap:8px;
    color:#fff; text-decoration:none; font-weight:800; letter-spacing:.3px;
  }
  .footer-logo i{
    color: var(--footer-accent);
    font-size: 22px;
    filter: drop-shadow(0 0 4px rgba(212,175,55,.35));
  }

  .footer-social{
    display:flex; gap:10px; margin-top:10px;
  }
  .footer-social a{
    width:36px; height:36px; border-radius:8px;
    display:inline-flex; align-items:center; justify-content:center;
    background:#111827; color:#cbd5e1; text-decoration:none;
    border:1px solid #1f2937;
    transition: background .15s ease, color .15s ease, transform .15s ease;
  }
  .footer-social a:hover{
    background:#1f2937; color:#fff; transform: translateY(-2px);
  }

  .footer-links,
  .footer-contact{
    list-style:none; padding:0; margin:0;
    display:flex; flex-direction:column; gap:8px;
  }
  .footer-links a{
    color: var(--footer-link);
    text-decoration: none;
    font-size: .95rem;
    transition: color .15s ease;
  }
  .footer-links a:hover{ color: var(--footer-link-hover); }

  .footer-contact li{
    display:flex; align-items:center; gap:10px;
    color: var(--footer-muted);
    font-size: .95rem;
  }
  .footer-contact i{ color:#cbd5e1; font-size: 16px; }
  .footer-contact a{
    color: var(--footer-link);
    text-decoration:none;
  }
  .footer-contact a:hover{ color:#fff; }

  .footer-newsletter{
    display:flex; gap:8px; margin-top:12px;
  }
  .footer-newsletter input{
    flex: 1;
    padding: 10px 12px;
    border-radius: 10px;
    border: 1px solid #1f2937;
    background: #0b1220;
    color: #e5e7eb;
    outline: none;
  }
  .footer-newsletter input::placeholder{ color:#64748b; }
  .footer-newsletter input:focus{
    border-color: var(--footer-accent);
    box-shadow: 0 0 0 3px rgba(212,175,55,.25);
    background: #0d1626;
  }
  .footer-newsletter button{
    padding: 10px 14px;
    border-radius: 10px;
    border: 1px solid #2b3440;
    background: var(--footer-accent);
    color:#1a1a1a;
    font-weight: 800;
    cursor: pointer;
  }
  .footer-newsletter button:hover{
    filter: brightness(1.05);
  }

  .footer-bottom{
    max-width: 1320px;
    margin: 18px auto 0;
    padding-top: 16px;
    border-top: 1px solid #1f2937;
    display:flex;
    flex-wrap:wrap;
    gap: 10px 22px;
    align-items:center;
    justify-content: space-between;
    color: var(--footer-muted);
    font-size: .92rem;
  }
  .footer-copy{ display:flex; gap:10px; align-items:center; }
  .footer-team{ display:flex; gap:10px; align-items:center; }
  .sep{ opacity:.5; }

  /* Accessibility helper */
  .sr-only{
    position:absolute!important; width:1px!important; height:1px!important;
    padding:0!important; margin:-1px!important; overflow:hidden!important;
    clip:rect(0,0,0,0)!important; white-space:nowrap!important; border:0!important;
  }

  /* Responsive */
  @media (max-width: 992px){
    .footer-container{
      grid-template-columns: 1fr 1fr;
    }
  }
  @media (max-width: 640px){
    .footer-container{
      grid-template-columns: 1fr;
    }
    .footer-bottom{
      flex-direction: column;
      align-items: flex-start;
      gap: 8px;
    }
  }
</style>