<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>

<style>
/* ====== CHAT WIDGET – DOCKED ====== */
#chatToggleBtn {
    position: fixed; bottom: 0; right: 28px; z-index: 998;
    display: flex; align-items: center; gap: 8px;
    padding: 12px 20px;
    background: linear-gradient(135deg, #4f46e5, #7c3aed);
    color: #fff; border: none;
    border-radius: 16px 16px 0 0;
    box-shadow: 0 -4px 20px rgba(79,70,229,.3);
    cursor: pointer; font-size: 14px; font-weight: 600;
    font-family: inherit;
    transition: transform .3s ease, box-shadow .3s ease;
}
#chatToggleBtn:hover { transform: translateY(-3px); box-shadow: 0 -6px 28px rgba(79,70,229,.45); }
.toggle-icon { font-size: 20px; line-height: 1; }
.toggle-badge {
    background: #ef4444; color: #fff; font-size: 11px; font-weight: 700;
    min-width: 20px; height: 20px; border-radius: 10px;
    align-items: center; justify-content: center; padding: 0 6px;
    display: none;
}
.toggle-badge.has-unread { display: flex; }

#chatWidget {
    position: fixed; bottom: 0; right: 28px;
    width: 380px; max-height: 520px;
    display: flex; flex-direction: column;
    z-index: 999;
    border: 1px solid #e5e7eb; border-bottom: none;
    border-radius: 16px 16px 0 0;
    box-shadow: 0 -8px 40px rgba(0,0,0,.15);
    overflow: hidden; font-family: inherit;
    background: #fff;
    transform: translateY(100%); opacity: 0;
    visibility: hidden; pointer-events: none;
    transition: transform .4s cubic-bezier(.4,0,.2,1), opacity .3s ease, visibility .3s ease;
}
#chatWidget.active {
    transform: translateY(0); opacity: 1;
    visibility: visible; pointer-events: auto;
}

/* Header */
.chat-header {
    padding: 14px 18px;
    background: linear-gradient(135deg, #4f46e5, #7c3aed);
    color: #fff; display: flex; align-items: center;
    justify-content: space-between; flex-shrink: 0;
}
.chat-header h4 {
    margin: 0; font-size: .95rem; font-weight: 600;
    display: flex; align-items: center; gap: 8px;
}
.chat-status {
    font-size: .6rem; font-weight: 600;
    background: #34d399; color: #fff;
    padding: 2px 8px; border-radius: 10px;
    animation: pulseStatus 2s ease-in-out infinite;
}
@keyframes pulseStatus { 0%,100%{opacity:1} 50%{opacity:.7} }

.chat-close-btn {
    background: rgba(255,255,255,.15); border: none; color: #fff;
    font-size: 18px; cursor: pointer; width: 32px; height: 32px;
    border-radius: 8px; display: flex; align-items: center;
    justify-content: center; transition: background .2s;
}
.chat-close-btn:hover { background: rgba(255,255,255,.3); }

/* Messages */
.chat-messages {
    flex: 1; padding: 14px 16px; overflow-y: auto;
    display: flex; flex-direction: column; gap: 10px;
    background: #f9fafb; align-items: flex-start;
    max-height: 340px; min-height: 200px;
}
.chat-messages::-webkit-scrollbar { width: 4px; }
.chat-messages::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }

/* Quick Replies */
.quick-replies {
    display: flex; flex-direction: column; gap: 6px;
    margin: 6px 0; width: 100%;
}
.quick-reply-btn {
    background: #fff; color: #4f46e5;
    border: 1.5px solid #e0e7ff; padding: 10px 14px;
    border-radius: 12px; cursor: pointer; font-size: .82rem;
    font-weight: 500; text-align: left;
    transition: all .2s ease; line-height: 1.4;
}
.quick-reply-btn:hover {
    background: #eef2ff; border-color: #818cf8;
    transform: translateX(4px);
}

/* Bubbles */
.msg-bubble {
    max-width: 80%; padding: 10px 14px; border-radius: 16px;
    font-size: .85rem; line-height: 1.5;
    white-space: pre-wrap; word-break: break-word;
    animation: msgSlide .25s ease;
}
@keyframes msgSlide { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }

.msg-user {
    align-self: flex-end;
    background: linear-gradient(135deg, #4f46e5, #7c3aed);
    color: #fff; border-bottom-right-radius: 4px;
    box-shadow: 0 2px 8px rgba(79,70,229,.2);
}
.msg-admin {
    align-self: flex-start; background: #fff; color: #1f2937;
    border: 1px solid #e5e7eb; border-bottom-left-radius: 4px;
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
}

.chat-empty {
    text-align: center; font-size: .85rem; color: #9ca3af;
    padding: 16px 8px; align-self: center;
}

/* Product Cards */
.product-card-chat {
    display: flex; gap: 12px; background: #fff;
    border: 1px solid #e5e7eb; border-radius: 12px;
    padding: 12px; max-width: 90%; align-self: flex-start;
    box-shadow: 0 1px 4px rgba(0,0,0,.06); transition: transform .2s;
}
.product-card-chat:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,.1); }
.product-card-chat img { width: 70px; height: 70px; object-fit: cover; border-radius: 10px; flex-shrink: 0; }
.product-card-chat .info { flex: 1; display: flex; flex-direction: column; gap: 4px; }
.product-card-chat h4 { margin: 0; font-size: .85rem; font-weight: 600; color: #1f2937; }
.product-card-chat .price { color: #4f46e5; font-weight: 700; font-size: .95rem; }
.product-card-chat .btn-view {
    background: #4f46e5; color: #fff; padding: 5px 12px;
    border-radius: 8px; text-decoration: none; font-size: .78rem;
    text-align: center; align-self: flex-start; font-weight: 500;
    transition: background .2s;
}
.product-card-chat .btn-view:hover { background: #4338ca; }

/* Loading */
.chat-loading {
    display: none; align-items: center; gap: 5px;
    padding: 8px 16px; flex-shrink: 0;
}
.chat-loading.active { display: flex; }
.chat-loading span {
    width: 8px; height: 8px; background: #818cf8;
    border-radius: 50%; animation: dotBounce 1.4s infinite ease-in-out;
}
.chat-loading span:nth-child(1) { animation-delay: -.32s; }
.chat-loading span:nth-child(2) { animation-delay: -.16s; }
@keyframes dotBounce { 0%,80%,100%{transform:scale(0)} 40%{transform:scale(1)} }

/* Image Preview */
.chat-image-preview {
    display: none; position: relative; margin: 0 16px 8px;
    max-width: 180px; border-radius: 10px; overflow: hidden;
    border: 1px solid #e5e7eb; flex-shrink: 0;
}
.chat-image-preview img { width: 100%; height: auto; display: block; }
.chat-image-preview .remove-img {
    position: absolute; top: 4px; right: 4px;
    background: rgba(0,0,0,.6); color: #fff; border: none;
    border-radius: 50%; width: 24px; height: 24px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
}
.chat-image-preview .remove-img:hover { background: #ef4444; }

/* Input Area */
.chat-input-area {
    padding: 12px 14px; background: #fff;
    border-top: 1px solid #e5e7eb;
    display: flex; gap: 8px; align-items: center; flex-shrink: 0;
}
.chat-input-area input[type="text"] {
    flex: 1; padding: 10px 14px; border-radius: 12px;
    border: 1.5px solid #e5e7eb; background: #f9fafb;
    color: #1f2937; outline: none; font-size: .9rem;
    transition: border-color .2s, box-shadow .2s;
}
.chat-input-area input[type="text"]:focus {
    border-color: #818cf8;
    box-shadow: 0 0 0 3px rgba(129,140,248,.2);
    background: #fff;
}
.chat-img-btn {
    background: transparent; border: 1.5px solid #e5e7eb;
    color: #6b7280; width: 40px; height: 40px;
    border-radius: 10px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px; flex-shrink: 0; transition: all .2s;
}
.chat-img-btn:hover { border-color: #818cf8; color: #4f46e5; background: #eef2ff; }
.chat-send-btn {
    background: linear-gradient(135deg, #4f46e5, #7c3aed);
    color: #fff; border: none; padding: 10px 16px;
    border-radius: 12px; cursor: pointer; font-weight: 600;
    font-size: .85rem; flex-shrink: 0;
    display: flex; align-items: center; gap: 6px;
    transition: transform .2s, box-shadow .2s;
}
.chat-send-btn:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,70,229,.3); }
.chat-send-btn:disabled { opacity: .5; cursor: not-allowed; transform: none; box-shadow: none; }

/* New message indicator */
.new-msg-indicator {
    position: absolute; bottom: 70px; left: 50%;
    transform: translateX(-50%);
    background: #4f46e5; color: #fff;
    padding: 6px 14px; border-radius: 20px;
    font-size: .78rem; font-weight: 500;
    cursor: pointer; box-shadow: 0 2px 12px rgba(79,70,229,.3);
    z-index: 10; display: none;
    animation: slideUp .3s ease;
}
@keyframes slideUp { from{opacity:0;transform:translateX(-50%) translateY(10px)} to{opacity:1;transform:translateX(-50%) translateY(0)} }

/* Responsive */
@media (max-width: 768px) {
    #chatToggleBtn {
        width: 56px; height: 56px; padding: 0;
        border-radius: 50%; bottom: 90px; right: 16px;
        justify-content: center;
        box-shadow: 0 6px 24px rgba(79,70,229,.35);
    }
    #chatToggleBtn .toggle-text { display: none; }
    #chatToggleBtn .toggle-icon { font-size: 24px; }
    #chatToggleBtn .toggle-badge { position: absolute; top: -4px; right: -4px; }
    #chatWidget { right: 0; width: 100%; max-height: 70vh; }
}
</style>

<!-- Toggle Button -->
<button id="chatToggleBtn" type="button" aria-label="Mở chat">
    <span class="toggle-icon">💬</span>
    <span class="toggle-text">Chat ngay</span>
    <span class="toggle-badge" id="chatUnreadBadge">0</span>
</button>

<!-- Chat Widget -->
<div id="chatWidget" aria-live="polite" aria-label="Hỗ trợ chat">
    <div class="chat-header">
        <h4>🤖 Light Shop AI <span class="chat-status">ONLINE</span></h4>
        <button class="chat-close-btn" type="button" aria-label="Đóng">×</button>
    </div>

    <div id="chatMessages" class="chat-messages">
        <div class="chat-empty">👋 Chào bạn! Mình là AI assistant của Light Shop.</div>
        <div class="quick-replies" id="quickReplies">
            <button class="quick-reply-btn" data-text="Tôi muốn kiểm tra coupon/mã giảm giá của shop">🎫 Kiểm tra coupon / mã giảm giá</button>
            <button class="quick-reply-btn" data-text="Tôi muốn kiểm tra tình trạng đơn hàng của tôi">📦 Kiểm tra tình trạng đơn hàng</button>
            <button class="quick-reply-btn" data-text="Tìm sản phẩm bằng hình ảnh">📷 Tìm sản phẩm bằng hình ảnh</button>
            <button class="quick-reply-btn" data-text="Tôi cần tư vấn sản phẩm phù hợp nhu cầu">💡 Tư vấn sản phẩm</button>
        </div>
    </div>

    <!-- New message indicator (khi user đang scroll lên) -->
    <div class="new-msg-indicator" id="newMsgIndicator">
        ↓ Tin nhắn mới
    </div>

    <div class="chat-loading" id="chatLoading">
        <span></span><span></span><span></span>
    </div>

    <div class="chat-image-preview" id="chatImagePreview">
        <img src="" alt="Preview" id="chatPreviewImg">
        <button class="remove-img" type="button" id="chatRemoveImgBtn">×</button>
    </div>

    <div class="chat-input-area">
        <button class="chat-img-btn" id="chatImageUploadBtn" type="button" title="Tải ảnh lên">📷</button>
        <input type="file" id="chatImageInput" accept="image/*" style="display:none">
        <input id="chatInput" type="text" placeholder="Nhập tin nhắn..." maxlength="500" aria-label="Nội dung tin nhắn">
        <button class="chat-send-btn" id="chatSendBtn" type="button">
            <i class="fas fa-paper-plane"></i> Gửi
        </button>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {

    /* ====== DOM ====== */
    var toggle      = document.getElementById('chatToggleBtn'),
        widget      = document.getElementById('chatWidget'),
        closeBtn    = widget ? widget.querySelector('.chat-close-btn') : null,
        messagesEl  = document.getElementById('chatMessages'),
        input       = document.getElementById('chatInput'),
        sendBtn     = document.getElementById('chatSendBtn'),
        loading     = document.getElementById('chatLoading'),
        quickReplies= document.getElementById('quickReplies'),
        badge       = document.getElementById('chatUnreadBadge'),
        newMsgInd   = document.getElementById('newMsgIndicator'),
        imgBtn      = document.getElementById('chatImageUploadBtn'),
        imgInput    = document.getElementById('chatImageInput'),
        imgPreview  = document.getElementById('chatImagePreview'),
        imgPreviewEl= document.getElementById('chatPreviewImg'),
        imgRemove   = document.getElementById('chatRemoveImgBtn'),
        API         = '${pageContext.request.contextPath}/chat-api';

    if (!toggle || !widget) return;

    /* ====== STATE ====== */
    var timer         = null,
        sending       = false,
        composing     = false,
        uploadedFile  = null,
        unread        = 0,
        // ★ Cache: lưu toàn bộ messages đã nhận, tránh re-render
        cachedMessages = [],
        // ★ Track: user đang scroll lên xem tin cũ?
        userIsScrollingUp = false,
        // ★ Có tin mới chờ hiển thị khi user đang scroll lên
        pendingNewMessages = 0;

    /* ====== QUICK REPLIES TEMPLATE ====== */
    var qrHTML = quickReplies ? quickReplies.outerHTML : '';

    function bindQR(el) {
        if (!el) return;
        el.querySelectorAll('.quick-reply-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var text = btn.dataset.text;
                if (text === 'Tìm sản phẩm bằng hình ảnh') {
                    if (imgInput) imgInput.click();
                } else {
                    if (input) input.value = text;
                    sendMessage();
                }
            });
        });
    }
    bindQR(quickReplies);

    function showQR() {
        var old = messagesEl.querySelector('.quick-replies');
        if (old) old.remove();
        var tmp = document.createElement('div');
        tmp.innerHTML = qrHTML;
        var el = tmp.firstElementChild;
        if (el) { messagesEl.appendChild(el); bindQR(el); }
    }

    function hideQR() {
        var el = messagesEl.querySelector('.quick-replies');
        if (el) el.remove();
    }

    /* ====== SCROLL DETECTION ======
     * Chỉ auto-scroll xuống khi user đang ở gần cuối.
     * Nếu user đang kéo lên xem tin cũ → KHÔNG tự scroll, hiện indicator.
     */
    var SCROLL_THRESHOLD = 60; // px từ đáy

    function isNearBottom() {
        if (!messagesEl) return true;
        return (messagesEl.scrollHeight - messagesEl.scrollTop - messagesEl.clientHeight) < SCROLL_THRESHOLD;
    }

    function scrollToBottom() {
        if (messagesEl) messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    function smartScroll() {
        if (userIsScrollingUp) {
            // User đang xem tin cũ → chỉ hiện indicator, KHÔNG scroll
            showNewMsgIndicator();
        } else {
            scrollToBottom();
            hideNewMsgIndicator();
        }
    }

    // Track scroll position
    if (messagesEl) {
        messagesEl.addEventListener('scroll', function() {
            userIsScrollingUp = !isNearBottom();
            if (!userIsScrollingUp) {
                hideNewMsgIndicator();
                pendingNewMessages = 0;
            }
        }, { passive: true });
    }

    /* ====== NEW MESSAGE INDICATOR ====== */
    function showNewMsgIndicator() {
        if (newMsgInd && pendingNewMessages > 0) {
            newMsgInd.textContent = '↓ ' + pendingNewMessages + ' tin nhắn mới';
            newMsgInd.style.display = 'block';
        }
    }

    function hideNewMsgIndicator() {
        if (newMsgInd) newMsgInd.style.display = 'none';
    }

    // Click indicator → scroll xuống
    if (newMsgInd) {
        newMsgInd.addEventListener('click', function() {
            userIsScrollingUp = false;
            pendingNewMessages = 0;
            scrollToBottom();
            hideNewMsgIndicator();
        });
    }

    /* ====== BADGE ====== */
    function setBadge(n) {
        unread = n;
        if (badge) {
            badge.textContent = n;
            badge.classList.toggle('has-unread', n > 0);
        }
    }

    /* ====== FORMAT ====== */
    function formatPrice(p) {
        return new Intl.NumberFormat('vi-VN').format(p);
    }

    /* ====== CREATE MESSAGE DOM ======
     * Tạo DOM element cho 1 message, KHÔNG append vào container.
     */
    function createMsgEl(msg) {
        if (msg.meta && msg.meta.productsJson) {
            var frag = document.createDocumentFragment();
            try {
                JSON.parse(msg.meta.productsJson).forEach(function(p) {
                    var card = document.createElement('div');
                    card.className = 'product-card-chat';
                    card.innerHTML =
                        '<img src="' + p.imageUrl + '" alt="' + p.name + '" onerror="this.src=\'${pageContext.request.contextPath}/images/no-image.png\'">' +
                        '<div class="info">' +
                            '<h4>' + p.name + '</h4>' +
                            '<p class="price">' + formatPrice(p.price) + '₫</p>' +
                            '<a href="' + p.url + '" class="btn-view">Xem chi tiết</a>' +
                        '</div>';
                    frag.appendChild(card);
                });
            } catch(e) { console.error(e); }
            return frag;
        } else {
            var div = document.createElement('div');
            div.className = 'msg-bubble ' + (msg.sender === 'ADMIN' ? 'msg-admin' : 'msg-user');
            div.textContent = msg.content;
            return div;
        }
    }

    /* ====== DIFF & RENDER ======
     * So sánh server data với cache.
     * Chỉ render tin nhắn MỚI (chưa có trong cache).
     * KHÔNG xóa/re-render tin cũ → không bị giật scroll.
     */
    function diffAndRender(serverList) {
        if (!serverList || !Array.isArray(serverList)) return;

        // Lần đầu: render tất cả
        if (cachedMessages.length === 0 && serverList.length === 0) {
            if (!messagesEl.querySelector('.msg-bubble,.product-card-chat')) {
                if (!messagesEl.querySelector('.chat-empty')) {
                    messagesEl.innerHTML = '<div class="chat-empty">Chưa có tin nhắn nào.</div>';
                }
                showQR();
            }
            return;
        }

        // Tìm messages mới (index > cache length)
        var newStart = cachedMessages.length;
        var newMessages = serverList.slice(newStart);

        if (newMessages.length === 0) return; // Không có gì mới

        // Xóa empty message & quick replies cũ
        var empty = messagesEl.querySelector('.chat-empty');
        if (empty) empty.remove();
        hideQR();

        // ★ Chỉ append tin mới, không động vào tin cũ
        var hasNewAdmin = false;
        var frag = document.createDocumentFragment();

        newMessages.forEach(function(msg) {
            frag.appendChild(createMsgEl(msg));
            if (msg.sender === 'ADMIN') hasNewAdmin = true;
        });

        messagesEl.appendChild(frag);

        // Update cache
        cachedMessages = serverList.slice(); // shallow copy

        // Quick replies sau admin response cuối
        var lastMsg = serverList[serverList.length - 1];
        if (lastMsg && lastMsg.sender === 'ADMIN') {
            showQR();
        }

        // ★ Smart scroll: chỉ tự scroll nếu user đang ở gần cuối
        if (hasNewAdmin) {
            pendingNewMessages += newMessages.filter(function(m) { return m.sender === 'ADMIN'; }).length;
        }
        smartScroll();

        // Unread badge (khi widget đóng)
        if (hasNewAdmin && !widget.classList.contains('active')) {
            var adminCount = newMessages.filter(function(m) { return m.sender === 'ADMIN'; }).length;
            setBadge(unread + adminCount);
        }
    }

    /* ====== LOAD HISTORY ======
     * Fetch từ server, so sánh với cache, chỉ render diff.
     */
    function loadHistory() {
        fetch(API, { cache: 'no-store' })
            .then(function(r) { if (!r.ok) throw new Error(r.status); return r.json(); })
            .then(function(d) { diffAndRender(d.messages || d); })
            .catch(function(e) { console.warn('[Chat] Load error', e); });
    }

    /* ====== OPTIMISTIC SEND ======
     * Hiển thị tin nhắn user ngay lập tức (không chờ server).
     * Tránh cảm giác lag.
     */
    function sendMessage() {
        if (sending || composing) return;
        var text = (input ? input.value : '').trim();
        if (!text) return;

        sending = true;
        if (sendBtn) sendBtn.disabled = true;
        if (input) { input.disabled = true; input.value = ''; }
        if (loading) loading.classList.add('active');

        hideQR();

        // ★ Optimistic: render tin nhắn user ngay
        var optimisticMsg = { sender: 'USER', content: text };
        var empty = messagesEl.querySelector('.chat-empty');
        if (empty) empty.remove();
        messagesEl.appendChild(createMsgEl(optimisticMsg));
        cachedMessages.push(optimisticMsg);

        // Scroll xuống vì chính user vừa gửi
        userIsScrollingUp = false;
        pendingNewMessages = 0;
        scrollToBottom();
        hideNewMsgIndicator();

        fetch(API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: new URLSearchParams({ action: 'ai_chat', content: text })
        })
        .then(function() {
            // Server đã xử lý, poll lại để lấy admin response
            // Dùng setTimeout ngắn để server kịp xử lý
            setTimeout(loadHistory, 500);
        })
        .catch(function() {
            var errMsg = { sender: 'ADMIN', content: 'Lỗi gửi tin nhắn. Vui lòng thử lại.' };
            messagesEl.appendChild(createMsgEl(errMsg));
            cachedMessages.push(errMsg);
            showQR();
            scrollToBottom();
        })
        .finally(function() {
            sending = false;
            if (sendBtn) sendBtn.disabled = false;
            if (input) { input.disabled = false; input.focus(); }
            if (loading) loading.classList.remove('active');
        });
    }

    /* ====== IMAGE SEARCH ====== */
    function sendImageSearch() {
        if (!uploadedFile || sending) return;
        sending = true;
        if (loading) loading.classList.add('active');
        if (sendBtn) sendBtn.disabled = true;
        hideQR();

        var fd = new FormData();
        fd.append('action', 'image_search');
        fd.append('image', uploadedFile);

        fetch(API, { method: 'POST', body: fd })
            .then(function(r) { return r.json(); })
            .then(function() {
                uploadedFile = null;
                if (imgPreview) imgPreview.style.display = 'none';
                if (imgInput) imgInput.value = '';
                setTimeout(loadHistory, 500);
            })
            .catch(function() {
                var errMsg = { sender: 'ADMIN', content: 'Lỗi upload ảnh. Vui lòng thử lại!' };
                messagesEl.appendChild(createMsgEl(errMsg));
                cachedMessages.push(errMsg);
                showQR();
                scrollToBottom();
            })
            .finally(function() {
                sending = false;
                if (loading) loading.classList.remove('active');
                if (sendBtn) sendBtn.disabled = false;
            });
    }

    if (imgBtn && imgInput) {
        imgBtn.addEventListener('click', function() { imgInput.click(); });
        imgInput.addEventListener('change', function(e) {
            var file = e.target.files[0];
            if (!file) return;
            if (!file.type.startsWith('image/')) return alert('Vui lòng chọn file ảnh!');
            if (file.size > 10485760) return alert('File quá lớn! Tối đa 10MB.');
            uploadedFile = file;
            var reader = new FileReader();
            reader.onload = function(ev) {
                if (imgPreviewEl) imgPreviewEl.src = ev.target.result;
                if (imgPreview) imgPreview.style.display = 'block';
            };
            reader.readAsDataURL(file);
            sendImageSearch();
        });
    }
    if (imgRemove) {
        imgRemove.addEventListener('click', function() {
            uploadedFile = null;
            if (imgPreview) imgPreview.style.display = 'none';
            if (imgInput) imgInput.value = '';
        });
    }

    /* ====== POLLING ====== */
    function startPolling() { stopPolling(); timer = setInterval(loadHistory, 3000); }
    function stopPolling() { if (timer) { clearInterval(timer); timer = null; } }

    /* ====== TOGGLE ====== */
    toggle.addEventListener('click', function() {
        var active = widget.classList.toggle('active');
        toggle.style.visibility = active ? 'hidden' : 'visible';
        toggle.style.opacity    = active ? '0' : '1';
        if (active) {
            setBadge(0);
            pendingNewMessages = 0;
            userIsScrollingUp = false;
            hideNewMsgIndicator();
            loadHistory();
            startPolling();
            // Scroll xuống khi mở chat
            requestAnimationFrame(scrollToBottom);
            if (input) input.focus();
        } else {
            stopPolling();
        }
    });

    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            widget.classList.remove('active');
            toggle.style.visibility = 'visible';
            toggle.style.opacity = '1';
            stopPolling();
        });
    }

    /* ====== INPUT EVENTS ====== */
    if (sendBtn) sendBtn.addEventListener('click', sendMessage);
    if (input) {
        input.addEventListener('compositionstart', function() { composing = true; });
        input.addEventListener('compositionend', function() { composing = false; });
        input.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !composing) { e.preventDefault(); sendMessage(); }
        });
    }

    /* ====== AUTO OPEN ====== */
    if (new URLSearchParams(location.search).get('chat') === 'open') {
        widget.classList.add('active');
        toggle.style.visibility = 'hidden';
        toggle.style.opacity = '0';
        setBadge(0); loadHistory(); startPolling();
    }

    window.addEventListener('beforeunload', stopPolling);
});
</script>