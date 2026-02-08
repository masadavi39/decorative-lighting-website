<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Admin Chat Center</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Bỏ partial head, dùng CDN gọn nhẹ -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <style>
    body{height:100vh;display:flex;flex-direction:column;overflow:hidden}
    .chat-wrapper{flex:1;display:flex;height:calc(100vh - 120px);overflow:hidden;background:#fff;box-shadow:0 0 20px rgba(0,0,0,0.05);margin:0}
    #user-list-panel{width:320px;background:#fff;border-right:1px solid #e5e7eb;display:flex;flex-direction:column}
    .panel-header{padding:16px;background:#fff;color:#1f2937;font-weight:600;font-size:1.05rem;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;gap:10px}
    #user-list{flex:1;overflow-y:auto;padding:10px}
    .user-item{display:flex;align-items:center;padding:10px 12px;margin-bottom:6px;border-radius:10px;cursor:pointer;transition:all .15s ease;color:#4b5563}
    .user-item:hover{background:#f3f4f6}
    .user-item.active{background:#e0f2fe;color:#0284c7}
    .avatar{width:36px;height:36px;background:#e5e7eb;color:#6b7280;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:600;font-size:13px;margin-right:10px;flex-shrink:0}
    .user-item.active .avatar{background:#0284c7;color:#fff}
    .user-info{display:flex;flex-direction:column;overflow:hidden}
    .user-name{font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .user-status{font-size:12px;color:#9ca3af}
    #chat-window{flex:1;display:flex;flex-direction:column;background:#f8fafc}
    #chat-title{padding:12px 16px;background:#fff;border-bottom:1px solid #e5e7eb;font-weight:600;color:#1f2937;display:flex;align-items:center;gap:10px}
    #messages-area{flex:1;padding:16px;overflow-y:auto;display:flex;flex-direction:column;gap:8px;background:#f8fafc}
    .msg{padding:8px 12px;border-radius:16px;max-width:70%;word-wrap:break-word;font-size:14px;line-height:1.5;box-shadow:0 1px 2px rgba(0,0,0,0.1)}
    .msg-ADMIN{align-self:flex-end;background:linear-gradient(135deg,#007bff,#0062cc);color:#fff;border-bottom-right-radius:4px}
    .msg-USER{align-self:flex-start;background:#fff;color:#1f2937;border:1px solid #f1f1f1;border-bottom-left-radius:4px}
    .input-area{padding:12px;background:#fff;border-top:1px solid #e5e7eb;display:flex;align-items:center;gap:10px}
    .input-area input{flex:1;padding:10px 12px;border-radius:20px;border:1px solid #e5e7eb;background:#f9fafb}
    .input-area input:focus{background:#fff;border-color:#007bff;box-shadow:0 0 0 3px rgba(0,123,255,0.1)}
    .input-area button{width:42px;height:42px;border-radius:50%;background:#007bff;color:#fff;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:16px}
    .empty-state{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:#9ca3af}
    .skeleton{background:linear-gradient(90deg,#eee,#f5f5f5,#eee);background-size:200% 100%;animation:s 1.2s infinite;border-radius:10px}
    @keyframes s{0%{background-position:200% 0}100%{background-position:-200% 0}}
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="chat" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header"><div class="container-fluid"><h1>Trung tâm hỗ trợ chat</h1></div></section>
    <section class="content">
      <div class="container-fluid">
        <div class="chat-wrapper">
          <div id="user-list-panel">
            <div class="panel-header"><i class="fas fa-comments text-primary"></i> Tin nhắn khách hàng</div>
            <div id="user-list">
              <div class="skeleton" style="height:44px;margin-bottom:8px"></div>
              <div class="skeleton" style="height:44px;margin-bottom:8px"></div>
              <div class="skeleton" style="height:44px;margin-bottom:8px"></div>
            </div>
          </div>

          <div id="chat-window">
            <div id="chat-title"><i class="fas fa-comment-slash" style="color:#9ca3af;"></i><span>Chưa chọn hội thoại</span></div>
            <div id="messages-area">
              <div class="empty-state"><i class="far fa-paper-plane" style="font-size:40px;opacity:.5"></i><p>Chọn một khách hàng để bắt đầu hỗ trợ</p></div>
            </div>
            <div class="input-area">
              <input type="text" id="admin-input" placeholder="Nhập tin nhắn trả lời..." disabled onkeypress="handleEnter(event)">
              <button id="send-btn" onclick="sendReply()" disabled><i class="fas fa-paper-plane"></i></button>
            </div>
          </div>

        </div>
      </div>
    </section>
  </div>

  <footer class="main-footer"><strong>Light Admin</strong></footer>
</div>

<!-- JS CDN -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script>
  const API_URL = '${pageContext.request.contextPath}/chat-api';
  let currentTalkingTo = null;
  let pollingUsers = null;
  let pollingChat = null;

  function setLoadingUsers(){
    const listEl = document.getElementById('user-list');
    listEl.innerHTML = '';
    for(let i=0;i<4;i++){
      const d = document.createElement('div');
      d.className='skeleton'; d.style.height='44px'; d.style.marginBottom='8px';
      listEl.appendChild(d);
    }
  }

  async function loadUserList() {
    try {
      const res = await fetch(API_URL + '?action=admin_load_users',{cache:'no-store'});
      if(!res.ok) { return; }
      const users = await res.json();
      const listEl = document.getElementById("user-list");
      if (!users || users.length === 0) {
        listEl.innerHTML = '<div class="empty-state" style="height:200px;"><i class="fas fa-inbox"></i><p style="font-size:13px;">Chưa có tin nhắn</p></div>';
        return;
      }
      const frag = document.createDocumentFragment();
      users.forEach(user => {
        const uid = user.id; const name = user.name || ('User #' + uid);
        const div = document.createElement('div');
        div.className = 'user-item' + (uid === currentTalkingTo ? ' active' : '');
        const initial = name.charAt(0).toUpperCase();
        div.innerHTML =
          '<div class="avatar">'+ initial +'</div>' +
          '<div class="user-info"><div class="user-name">'+ name +'</div><div class="user-status">ID: '+ uid +'</div></div>';
        div.onclick = () => selectUser(uid, name);
        frag.appendChild(div);
      });
      listEl.innerHTML = ''; listEl.appendChild(frag);
    } catch (e) { /* silent */ }
  }

  function selectUser(uid, name) {
    if (currentTalkingTo === uid) return;
    currentTalkingTo = uid;
    document.getElementById("chat-title").innerHTML =
      '<div class="avatar" style="width:30px;height:30px;font-size:12px;background:#007bff;color:#fff">'+ (name?name.charAt(0).toUpperCase():'U') +'</div>' +
      '<div><div style="font-size:14px;line-height:1.2">'+ name +'</div><div style="font-size:11px;color:#22c55e">• Đang kết nối</div></div>';
    document.getElementById("admin-input").disabled = false;
    document.getElementById("send-btn").disabled = false;
    loadChatHistory();
    startPollingChat();
  }

  async function loadChatHistory() {
    if (!currentTalkingTo) return;
    try{
      const res = await fetch(API_URL + '?action=admin_load_chat&targetId=' + encodeURIComponent(currentTalkingTo), {cache:'no-store'});
      if(!res.ok) return;
      const messages = await res.json();
      const area = document.getElementById("messages-area");
      area.innerHTML = '';
      if (!messages || messages.length === 0) {
        area.innerHTML = '<div class="empty-state"><p>Bắt đầu cuộc trò chuyện</p></div>';
        return;
      }
      messages.forEach(m => {
        const d = document.createElement('div');
        d.className = 'msg msg-' + (m.sender || 'USER');
        d.textContent = m.content || '';
        area.appendChild(d);
      });
      area.scrollTop = area.scrollHeight;
    }catch(e){}
  }

  async function sendReply() {
    const input = document.getElementById("admin-input");
    const text = input.value.trim();
    if (!text || !currentTalkingTo) return;
    input.value = ''; input.focus();
    const area = document.getElementById("messages-area");
    const temp = document.createElement('div');
    temp.className = 'msg msg-ADMIN'; temp.style.opacity = '0.8'; temp.textContent = text;
    area.appendChild(temp); area.scrollTop = area.scrollHeight;

    try{
      const res = await fetch(API_URL, {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body:'action=admin_send&targetId='+encodeURIComponent(currentTalkingTo)+'&content='+encodeURIComponent(text)
      });
      const data = await res.json().catch(()=>({}));
      if (!data || data.status !== 'success') {
        temp.style.background = '#dc3545'; temp.textContent = 'Lỗi gửi';
      } else {
        setTimeout(loadChatHistory, 300);
      }
    }catch(e){
      temp.style.background = '#dc3545'; temp.textContent = 'Lỗi mạng';
    }
  }
  function handleEnter(e){ if(e.key==='Enter') sendReply(); }

  function startPollingUsers(){ stopPollingUsers(); pollingUsers = setInterval(loadUserList, 3000); }
  function stopPollingUsers(){ if(pollingUsers){ clearInterval(pollingUsers); pollingUsers = null; } }
  function startPollingChat(){ stopPollingChat(); pollingChat = setInterval(loadChatHistory, 2000); }
  function stopPollingChat(){ if(pollingChat){ clearInterval(pollingChat); pollingChat = null; } }

  // init
  setLoadingUsers(); loadUserList(); startPollingUsers();
  window.addEventListener('beforeunload', ()=>{ stopPollingUsers(); stopPollingChat(); });
</script>
</body>
</html>