<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>

<style>
    /* === CHAT WIDGET CSS === */
    #chatToggleBtn {
        position: fixed; bottom: 100px; right: 20px;
        width: 58px; height: 58px; border-radius: 50%;
        background: var(--primary, #007bff); color: #fff; border: none;
        box-shadow: 0 6px 18px rgba(0,0,0,.25);
        cursor: pointer; font-size: 22px; display: flex;
        align-items: center; justify-content: center;
        z-index: 998; transition: background .25s, transform .25s;
    }
    #chatToggleBtn:hover { background: #0056c7; transform: translateY(-3px); }
    body.dark #chatToggleBtn { background: #4ea3ff; }
    body.dark #chatToggleBtn:hover { background: #2e8adf; }

    #chatWidget {
        position: fixed; bottom: 170px; right: 20px;
        width: 360px; max-height: 600px;
        display: none; flex-direction: column;
        background: var(--card-bg, #fff); border: 1px solid var(--border, #dcdcdc);
        border-radius: 16px; box-shadow: 0 14px 40px rgba(0,0,0,.3);
        z-index: 999; overflow: hidden;
    }
    #chatWidget.active { display: flex; }

    .chat-header {
        padding: 12px 16px; background: var(--primary, #007bff); color: #fff;
        display: flex; align-items: center; justify-content: space-between;
    }
    body.dark .chat-header { background: #4ea3ff; }
    .chat-header h4 { margin: 0; font-size: 1rem; font-weight: 600; display: flex; align-items: center; gap: 6px; }

    .chat-messages {
        flex: 1; padding: 12px 14px; overflow-y: auto;
        display: flex; flex-direction: column; gap: 10px;
        background: var(--bg-color, #f8f9fa); align-items: flex-start;
        max-height: 400px;
    }

    /* Quick Replies */
    .quick-replies {
        display: flex; flex-direction: column; gap: 8px; margin: 8px 0;
        align-self: center; width: 100%;
    }
    .quick-reply-btn {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff; border: none; padding: 10px 14px;
        border-radius: 20px; cursor: pointer; font-size: 0.85rem;
        text-align: left; transition: transform 0.2s, box-shadow 0.2s;
        box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
    }
    .quick-reply-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.5);
    }

    /* Product Cards */
    .product-card-chat {
        display: flex; gap: 12px; background: var(--card-bg);
        border: 1px solid var(--border); border-radius: 12px;
        padding: 12px; max-width: 90%; align-self: flex-start;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        transition: transform 0.2s;
    }
    .product-card-chat:hover { transform: translateY(-2px); }
    .product-card-chat img {
        width: 80px; height: 80px; object-fit: cover;
        border-radius: 8px; flex-shrink: 0;
    }
    .product-card-chat .info { flex: 1; display: flex; flex-direction: column; gap: 4px; }
    .product-card-chat h4 {
        margin: 0; font-size: 0.9rem; font-weight: 600;
        color: var(--text-color); line-height: 1.3;
    }
    .product-card-chat .price {
        color: var(--primary); font-weight: 700; font-size: 1rem;
    }
    .product-card-chat .btn-view {
        background: var(--primary); color: #fff; padding: 6px 12px;
        border-radius: 6px; text-decoration: none; font-size: 0.8rem;
        text-align: center; transition: background 0.2s; align-self: flex-start;
    }
    .product-card-chat .btn-view:hover { background: #0056c7; }

    .chat-input-area {
        padding: 10px 12px; background: var(--card-bg, #fff);
        border-top: 1px solid var(--border, #dcdcdc); display: flex; gap: 8px;
        align-items: center;
    }
    .chat-input-area input {
        flex: 1; padding: 10px 12px; border-radius: 10px;
        border: 1px solid var(--input-border, #cfcfcf); background: var(--input-bg, #fff);
        color: var(--input-text, #222); outline: none;
    }
    .chat-input-area input:focus { border-color: var(--primary, #007bff); box-shadow: 0 0 0 3px rgba(0,123,255,.25); }
    body.dark .chat-input-area input:focus { box-shadow: 0 0 0 3px rgba(78,163,255,.45); }
    
    .chat-input-area button, .icon-btn {
        background: var(--primary, #007bff); color: #fff; border: none;
        padding: 10px 12px; border-radius: 10px; cursor: pointer; font-weight: 600;
        transition: background .25s; flex-shrink: 0;
    }
    .chat-input-area button:hover, .icon-btn:hover { background: #0056c7; }
    body.dark .chat-input-area button { background: #4ea3ff; }
    body.dark .chat-input-area button:hover { background: #2e8adf; }

    .icon-btn {
        font-size: 18px; padding: 8px 10px;
        display: inline-flex; align-items: center; justify-content: center;
    }

    /* Image Preview */
    .image-preview {
        display: none; position: relative; margin: 8px 0;
        max-width: 200px; border-radius: 8px; overflow: hidden;
    }
    .image-preview img {
        width: 100%; height: auto; display: block;
    }
    .image-preview .remove-img {
        position: absolute; top: 4px; right: 4px;
        background: rgba(0,0,0,0.7); color: #fff; border: none;
        border-radius: 50%; width: 24px; height: 24px; cursor: pointer;
        display: flex; align-items: center; justify-content: center;
    }

    /* Messages */
    .msg-bubble {
        max-width: 75%; padding: 8px 12px; border-radius: 14px;
        font-size: .87rem; line-height: 1.4; position: relative;
        white-space: pre-wrap; word-break: break-word;
        box-shadow: 0 2px 6px rgba(0,0,0,.15);
        animation: msgFade .25s ease;
    }
    @keyframes msgFade { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

    .msg-user {
        align-self: flex-end; background: var(--primary, #007bff); color: #fff;
        border-bottom-right-radius: 6px;
    }
    
    .msg-admin {
        align-self: flex-start; background: #e9ecef; color: #1f2937;
        border: 1px solid #e5e7eb; border-bottom-left-radius: 6px;
    }
    body.dark .msg-user { background: var(--primary, #4ea3ff); color: #fff; }
    body.dark .msg-admin { background: #2b323b; color: #e9e9e9; border: 1px solid var(--border, #2b323b); }

    .chat-empty { text-align: center; font-size: .85rem; color: var(--muted, #556); padding: 12px 8px; }
    .chat-close-btn { background: transparent; border: none; color: #fff; font-size: 18px; cursor: pointer; line-height: 1; }
    .chat-status { font-size: .65rem; font-weight: 500; background: #ffc107; color: #222; padding: 2px 6px; border-radius: 10px; margin-left: 6px; }
    body.dark .chat-status { background: #664d00; color: #ffd666; }

    /* Loading */
    .chat-loading {
        display: none; align-items: center; gap: 4px;
        padding: 8px 12px; align-self: flex-start;
    }
    .chat-loading.active { display: flex; }
    .chat-loading span {
        width: 8px; height: 8px; background: var(--primary);
        border-radius: 50%; animation: bounce 1.4s infinite ease-in-out;
    }
    .chat-loading span:nth-child(1) { animation-delay: -0.32s; }
    .chat-loading span:nth-child(2) { animation-delay: -0.16s; }
    @keyframes bounce {
        0%, 80%, 100% { transform: scale(0); }
        40% { transform: scale(1); }
    }
</style>

<button id="chatToggleBtn" type="button" aria-label="Mở chat">💬</button>

<div id="chatWidget" aria-live="polite" aria-label="Hỗ trợ chat">
    <div class="chat-header">
        <h4>🤖 Light Shop AI <span class="chat-status">ONLINE</span></h4>
        <button class="chat-close-btn" type="button" aria-label="Đóng">×</button>
    </div>
    
    <div id="chatMessages" class="chat-messages">
        <div class="chat-empty">👋 Chào bạn! Mình là AI assistant của Light Shop.</div>
        
        <!-- Quick Replies (hiển thị khi bắt đầu) -->
        <div class="quick-replies" id="quickReplies">
            <button class="quick-reply-btn" data-text="Tôi muốn kiểm tra coupon/mã giảm giá của shop">
                🎫 Kiểm tra coupon/mã giảm giá
            </button>
            <button class="quick-reply-btn" data-text="Tôi muốn kiểm tra tình trạng đơn hàng của tôi">
                📦 Kiểm tra tình trạng đơn hàng
            </button>
            <button class="quick-reply-btn" data-text="Tìm sản phẩm bằng hình ảnh">
                📷 Tìm sản phẩm bằng hình ảnh
            </button>
            <button class="quick-reply-btn" data-text="Tôi cần tư vấn sản phẩm phù hợp nhu cầu">
                💡 Tư vấn sản phẩm
            </button>
        </div>
    </div>
    
    <div class="chat-loading" id="chatLoading">
        <span></span><span></span><span></span>
    </div>

    <!-- Image Preview -->
    <div class="image-preview" id="imagePreview">
        <img src="" alt="Preview" id="previewImg">
        <button class="remove-img" type="button" id="removeImgBtn">×</button>
    </div>

    <div class="chat-input-area">
        <button class="icon-btn" id="imageUploadBtn" type="button" title="Tải ảnh lên">📷</button>
        <input type="file" id="imageInput" accept="image/*" style="display:none">
        <input id="chatInput" type="text" placeholder="Nhập tin nhắn..." maxlength="500" aria-label="Nội dung tin nhắn">
        <button id="chatSendBtn" type="button">Gửi</button>
    </div>
</div>

<script>
(function() {
    const chatToggleBtn = document.getElementById('chatToggleBtn');
    const chatWidget = document.getElementById('chatWidget');
    const chatCloseBtn = chatWidget.querySelector('.chat-close-btn');
    const chatMessagesEl = document.getElementById('chatMessages');
    const chatInput = document.getElementById('chatInput');
    const chatSendBtn = document.getElementById('chatSendBtn');
    const chatLoading = document.getElementById('chatLoading');
    const quickReplies = document.getElementById('quickReplies');
    
    // Image upload elements
    const imageUploadBtn = document.getElementById('imageUploadBtn');
    const imageInput = document.getElementById('imageInput');
    const imagePreview = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    const removeImgBtn = document.getElementById('removeImgBtn');
    
    const CHAT_API = '${pageContext.request.contextPath}/chat-api';
    
    let pollingTimer = null;
    let isSending = false;
    let lastRenderedCount = 0;
    let isComposing = false;
    let uploadedFile = null;

    // === QUICK REPLY ===
    quickReplies.querySelectorAll('.quick-reply-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const text = btn.dataset.text;
            if (text === "Tìm sản phẩm bằng hình ảnh") {
                imageInput.click();
            } else {
                chatInput.value = text;
                sendMessage();
            }
            quickReplies.style.display = 'none';
        });
    });

    // === IMAGE UPLOAD ===
    imageUploadBtn.addEventListener('click', () => imageInput.click());
    
    imageInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;
        
        if (!file.type.startsWith('image/')) {
            alert('Vui lòng chọn file ảnh!');
            return;
        }
        
        if (file.size > 10 * 1024 * 1024) {
            alert('File quá lớn! Tối đa 10MB.');
            return;
        }
        
        uploadedFile = file;
        
        // Preview
        const reader = new FileReader();
        reader.onload = (event) => {
            previewImg.src = event.target.result;
            imagePreview.style.display = 'block';
        };
        reader.readAsDataURL(file);
        
        // Auto send
        sendImageSearch();
    });

    removeImgBtn.addEventListener('click', () => {
        uploadedFile = null;
        imagePreview.style.display = 'none';
        imageInput.value = '';
    });

    async function sendImageSearch() {
        if (!uploadedFile || isSending) return;
        
        isSending = true;
        chatLoading.classList.add('active');
        chatSendBtn.disabled = true;
        quickReplies.style.display = 'none';

        try {
            const formData = new FormData();
            formData.append('action', 'image_search');
            formData.append('image', uploadedFile);

            const res = await fetch(CHAT_API, {
                method: 'POST',
                body: formData
            });

            const data = await res.json();
            
            // Remove preview
            uploadedFile = null;
            imagePreview.style.display = 'none';
            imageInput.value = '';

            // Reload messages
            setTimeout(loadHistory, 300);

        } catch (e) {
            console.error(e);
            appendMessage('ADMIN', 'Lỗi upload ảnh. Vui lòng thử lại!');
        } finally {
            isSending = false;
            chatLoading.classList.remove('active');
            chatSendBtn.disabled = false;
        }
    }

    // === MESSAGE RENDERING ===
    function appendMessage(sender, content, meta = null) {
        if (!chatMessagesEl) return;
        
        // Hide empty message
        const emptyMsg = chatMessagesEl.querySelector('.chat-empty');
        if (emptyMsg) emptyMsg.remove();
        
        if (meta && meta.productsJson) {
            // Render product cards
            const products = JSON.parse(meta.productsJson);
            products.forEach(p => {
                const card = document.createElement('div');
                card.className = 'product-card-chat';
                card.innerHTML = `
                    <img src="${p.imageUrl}" alt="${p.name}" onerror="this.src='${pageContext.request.contextPath}/images/no-image.png'">
                    <div class="info">
                        <h4>${p.name}</h4>
                        <p class="price">${formatPrice(p.price)}₫</p>
                        <a href="${p.url}" class="btn-view">Xem chi tiết</a>
                    </div>
                `;
                chatMessagesEl.appendChild(card);
            });
        } else {
            // Normal text message
            const div = document.createElement('div');
            div.className = 'msg-bubble ' + (sender === 'ADMIN' ? 'msg-admin' : 'msg-user');
            div.textContent = content;
            chatMessagesEl.appendChild(div);
        }
        
        chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight;
    }

    function formatPrice(price) {
        return new Intl.NumberFormat('vi-VN').format(price);
    }

    function renderHistoryIncremental(list) {
        if (!list || list.length === 0) {
            if (chatMessagesEl.innerHTML.trim() === '') {
                chatMessagesEl.innerHTML = '<div class="chat-empty">Chưa có tin nhắn nào.</div>';
            }
            lastRenderedCount = 0;
            return;
        }
        
        const emptyMsg = chatMessagesEl.querySelector('.chat-empty');
        if (emptyMsg) emptyMsg.remove();
        
        for (let i = lastRenderedCount; i < list.length; i++) {
            const msg = list[i];
            appendMessage(msg.sender, msg.content, msg.meta);
        }
        lastRenderedCount = list.length;
    }

    async function loadHistory() {
        try {
            const res = await fetch(CHAT_API, {cache:'no-store'});
            if (!res.ok) return;
            const data = await res.json();
            renderHistoryIncremental(data.messages || data);
        } catch (e) {
            console.warn('Load chat error', e);
        }
    }

    async function sendMessage() {
        if (isSending || isComposing) return;
        
        const text = (chatInput.value || '').trim();
        if (!text) return;

        isSending = true;
        chatSendBtn.disabled = true;
        chatInput.disabled = true;
        chatLoading.classList.add('active');
        quickReplies.style.display = 'none';
        
        try {
            chatInput.value = '';

            const res = await fetch(CHAT_API, {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                body: new URLSearchParams({action: 'ai_chat', content: text})
            });
            
            setTimeout(loadHistory, 300);
        } catch (e) {
            console.error(e);
            appendMessage('ADMIN', 'Lỗi gửi tin nhắn.');
        } finally {
            isSending = false;
            chatSendBtn.disabled = false;
            chatInput.disabled = false;
            chatLoading.classList.remove('active');
            chatInput.focus();
        }
    }

    function startPolling() {
        stopPolling();
        pollingTimer = setInterval(loadHistory, 2000);
    }
    
    function stopPolling() {
        if (pollingTimer) {
            clearInterval(pollingTimer);
            pollingTimer = null;
        }
    }

    // === EVENTS ===
    chatToggleBtn.addEventListener('click', () => {
        const active = chatWidget.classList.toggle('active');
        if (active) {
            loadHistory();
            startPolling();
            chatInput.focus();
        } else {
            stopPolling();
        }
    });

    chatCloseBtn.addEventListener('click', () => {
        chatWidget.classList.remove('active');
        stopPolling();
    });

    chatSendBtn.addEventListener('click', sendMessage);

    chatInput.addEventListener('compositionstart', () => { isComposing = true; });
    chatInput.addEventListener('compositionend', () => { isComposing = false; });
    
    chatInput.addEventListener('keydown', e => {
        if (e.key === 'Enter' && !isComposing) {
            e.preventDefault();
            sendMessage();
        }
    });

    if (new URLSearchParams(location.search).get('chat') === 'open') {
        chatWidget.classList.add('active');
        loadHistory();
        startPolling();
    }

    window.addEventListener('beforeunload', stopPolling);

})();
</script>