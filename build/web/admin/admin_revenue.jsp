<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Thống kê doanh thu</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js"></script>
  <style>
    /* Info boxes luôn ở ngoài, phía trên tabs */
    .summary-row .info-box { min-height: 64px; }
    .summary-row .info-box .info-box-icon { height:64px; width:64px; line-height:64px; font-size:20px; }
    .summary-row .info-box .info-box-number { font-weight:700; }
    /* Chart khu vực responsive: chiếm chiều cao linh hoạt theo viewport */
    .chart-wrap { position:relative; width:100%; }
    .chart-viewport {
      height: clamp(220px, 30vh, 420px); /* responsive theo viewport height */
      width: 100%;
    }
    .truncate { max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .sort-icon { cursor:pointer; color:#888; }
    .sort-icon.active { color:#111; }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeGroup" value="sales" scope="request"/>
  <c:set var="activeMenu" value="revenue" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="mb-0">📊 Doanh thu</h1>
        <div>
          <button type="button" class="btn btn-sm btn-success" onclick="exportExcel()"><i class="fas fa-file-excel"></i> Excel</button>
          <button type="button" class="btn btn-sm btn-danger" onclick="exportPDF()"><i class="fas fa-file-pdf"></i> PDF</button>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <!-- Bộ lọc nâng cao -->
        <div class="card card-primary card-outline">
          <div class="card-header">
            <h3 class="card-title"><i class="fas fa-filter mr-1"></i>Bộ lọc nâng cao</h3>
            <div class="card-tools"><button class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-minus"></i></button></div>
          </div>
          <div class="card-body">
            <form class="form-inline flex-wrap" method="get" action="${pageContext.request.contextPath}/admin/products">
              <input type="hidden" name="action" value="revenue">
              <div class="form-group mr-2 mb-2">
                <label class="mr-2">Từ</label><input type="date" name="from" class="form-control form-control-sm" value="${param.from}">
              </div>
              <div class="form-group mr-2 mb-2">
                <label class="mr-2">Đến</label><input type="date" name="to" class="form-control form-control-sm" value="${param.to}">
              </div>
              <div class="form-group mr-2 mb-2">
                <label class="mr-2">Trạng thái</label>
                <select name="status" class="form-control form-control-sm">
                  <option value="">-- Tất cả --</option>
                  <option value="Chờ duyệt" ${param.status=='Chờ duyệt'?'selected':''}>Chờ duyệt</option>
                  <option value="Đang giao" ${param.status=='Đang giao'?'selected':''}>Đang giao</option>
                  <option value="Đã giao" ${param.status=='Đã giao'?'selected':''}>Đã giao</option>
                  <option value="Đã hủy" ${param.status=='Đã hủy'?'selected':''}>Đã hủy</option>
                </select>
              </div>
              <div class="form-group mr-2 mb-2">
                <label class="mr-2">Danh mục</label>
                <input type="text" name="category" class="form-control form-control-sm" value="${param.category}" placeholder="Tên danh mục">
              </div>
              <button class="btn btn-sm btn-primary mb-2"><i class="fas fa-search"></i> Lọc</button>
              <a href="${pageContext.request.contextPath}/admin/products?action=revenue" class="btn btn-sm btn-secondary mb-2"><i class="fas fa-undo"></i> Reset</a>
            </form>
          </div>
        </div>

        <!-- INFOBOXES: đặt ngoài, phía trên tabs -->
        <div class="row summary-row mb-3">
          <div class="col-md-3 col-6">
            <div class="info-box">
              <span class="info-box-icon bg-info"><i class="far fa-calendar-day"></i></span>
              <div class="info-box-content">
                <span class="info-box-text">Hôm nay</span>
                <span class="info-box-number"><fmt:formatNumber value="${todayRevenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> VND</span>
              </div>
            </div>
          </div>
          <div class="col-md-3 col-6">
            <div class="info-box">
              <span class="info-box-icon bg-success"><i class="far fa-calendar-alt"></i></span>
              <div class="info-box-content">
                <span class="info-box-text">Tháng này</span>
                <span class="info-box-number"><fmt:formatNumber value="${thisMonthRevenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> VND</span>
              </div>
            </div>
          </div>
          <div class="col-md-3 col-6">
            <div class="info-box">
              <span class="info-box-icon bg-warning"><i class="far fa-calendar"></i></span>
              <div class="info-box-content">
                <span class="info-box-text">Năm nay</span>
                <span class="info-box-number"><fmt:formatNumber value="${thisYearRevenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> VND</span>
              </div>
            </div>
          </div>
          <div class="col-md-3 col-6">
            <div class="info-box">
              <span class="info-box-icon bg-primary"><i class="fas fa-percentage"></i></span>
              <div class="info-box-content">
                <span class="info-box-text">Tăng trưởng (MoM)</span>
                <span class="info-box-number">${growthMoM != null ? growthMoM : '—'}%</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Tabs ngày/tuần/tháng: CHART responsive + bảng -->
        <div class="card">
          <div class="card-header p-2">
            <ul class="nav nav-pills" id="revTabs" role="tablist">
              <li class="nav-item"><a class="nav-link active" id="tab-day-tab" data-toggle="tab" href="#tab-day" role="tab"><i class="far fa-calendar-day mr-1"></i> Theo ngày</a></li>
              <li class="nav-item"><a class="nav-link" id="tab-week-tab" data-toggle="tab" href="#tab-week" role="tab"><i class="far fa-calendar-alt mr-1"></i> Theo tuần</a></li>
              <li class="nav-item"><a class="nav-link" id="tab-month-tab" data-toggle="tab" href="#tab-month" role="tab"><i class="far fa-calendar mr-1"></i> Theo tháng</a></li>
            </ul>
          </div>
          <div class="card-body">
            <div class="tab-content">
              <!-- Ngày -->
              <div class="tab-pane fade show active" id="tab-day" role="tabpanel">
                <div class="chart-wrap mb-3">
                  <canvas id="dayRevenueChart" class="chart-viewport"></canvas>
                </div>
                <div class="table-responsive">
                  <table class="table table-striped mb-0" id="tableDay">
                    <thead>
                      <tr>
                        <th>Ngày</th>
                        <th class="text-right">Doanh thu (VND)
                          <i class="fas fa-sort sort-icon" data-target="tableDay" data-index="1" title="Sắp xếp"></i>
                        </th>
                        <th>Chi tiết</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="r" items="${dailyRevenue}">
                        <tr onclick="window.location.href='${pageContext.request.contextPath}/admin/products?action=revenueDetailDay&date=${r[0]}'" style="cursor:pointer;">
                          <td><a href="${pageContext.request.contextPath}/admin/products?action=revenueDetailDay&date=${r[0]}"><c:out value="${r[0]}"/></a></td>
                          <td class="text-right"><fmt:formatNumber value="${r[1]}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                          <td><a class="btn btn-xs btn-outline-primary" href="${pageContext.request.contextPath}/admin/products?action=revenueDetailDay&date=${r[0]}">Chi tiết</a></td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </div>

              <!-- Tuần -->
              <div class="tab-pane fade" id="tab-week" role="tabpanel">
                <div class="chart-wrap mb-3">
                  <canvas id="weeklyRevenueChart" class="chart-viewport"></canvas>
                </div>
                <div class="table-responsive">
                  <table class="table table-striped mb-0" id="tableWeek">
                    <thead>
                      <tr>
                        <th>Tuần</th>
                        <th class="text-right">Doanh thu (VND)
                          <i class="fas fa-sort sort-icon" data-target="tableWeek" data-index="1" title="Sắp xếp"></i>
                        </th>
                        <th>Chi tiết</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="r" items="${weeklyRevenue}">
                        <tr onclick="window.location.href='${pageContext.request.contextPath}/admin/products?action=revenueDetail&weekCode=${r[2]}'" style="cursor:pointer;">
                          <td><a href="${pageContext.request.contextPath}/admin/products?action=revenueDetail&weekCode=${r[2]}"> <c:out value="${r[0]}"/> </a></td>
                          <td class="text-right"><fmt:formatNumber value="${r[1]}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                          <td><a class="btn btn-xs btn-outline-primary" href="${pageContext.request.contextPath}/admin/products?action=revenueDetail&weekCode=${r[2]}">Chi tiết</a></td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </div>

              <!-- Tháng -->
              <div class="tab-pane fade" id="tab-month" role="tabpanel">
                <div class="chart-wrap mb-3">
                  <canvas id="monthRevenueChart" class="chart-viewport"></canvas>
                </div>
                <div class="table-responsive">
                  <table class="table table-striped mb-0" id="tableMonth">
                    <thead>
                      <tr>
                        <th>Tháng</th>
                        <th class="text-right">Doanh thu (VND)
                          <i class="fas fa-sort sort-icon" data-target="tableMonth" data-index="1" title="Sắp xếp"></i>
                        </th>
                        <th>Chi tiết</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="r" items="${monthlyRevenue}">
                        <tr onclick="window.location.href='${pageContext.request.contextPath}/admin/products?action=revenueDetailMonth&month=${r[0]}'" style="cursor:pointer;">
                          <td><a href="${pageContext.request.contextPath}/admin/products?action=revenueDetailMonth&month=${r[0]}"><c:out value="${r[0]}"/></a></td>
                          <td class="text-right"><fmt:formatNumber value="${r[1]}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                          <td><a class="btn btn-xs btn-outline-primary" href="${pageContext.request.contextPath}/admin/products?action=revenueDetailMonth&month=${r[0]}">Chi tiết</a></td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </div>

            </div>
          </div>
        </div>

        <!-- Phân tích theo danh mục + Top SP -->
        <div class="row">
          <div class="col-lg-6">
            <div class="card">
              <div class="card-header"><h3 class="card-title mb-0"><i class="fas fa-pie-chart mr-1"></i> Doanh thu theo danh mục</h3></div>
              <div class="card-body">
                <div class="chart-wrap"><canvas id="revenueByCategoryChart" class="chart-viewport"></canvas></div>
              </div>
            </div>
          </div>
          <div class="col-lg-6">
            <div class="card">
              <div class="card-header d-flex align-items-center justify-content-between">
                <h3 class="card-title mb-0"><i class="fas fa-trophy mr-1"></i> Top doanh thu (sản phẩm)</h3>
                <small class="text-muted">Tổng kỳ</small>
              </div>
              <div class="card-body p-0">
                <div class="table-responsive" style="max-height:300px; overflow:auto;">
                  <table class="table table-sm table-striped mb-0" id="tableTopProductRevenue">
                    <thead>
                      <tr>
                        <th>Sản phẩm</th>
                        <th class="text-right">Doanh thu
                          <i class="fas fa-sort sort-icon" data-target="tableTopProductRevenue" data-index="1" title="Sắp xếp"></i>
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="r" items="${topProductRevenue}">
                        <tr>
                          <td class="truncate" title="${fn:escapeXml(r[0])}">${fn:escapeXml(r[0])}</td>
                          <td class="text-right text-danger font-weight-bold"><fmt:formatNumber value="${r[1]}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty topProductRevenue}">
                        <tr><td colspan="2" class="text-center text-muted py-2">Chưa có dữ liệu.</td></tr>
                      </c:if>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </section>
  </div>

  <footer class="main-footer"><strong>Light Admin</strong></footer>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script>
  // Day
  var dayLabels=[],dayData=[];
  <c:forEach var="r" items="${dailyRevenue}">
    dayLabels.push('<c:out value="${r[0]}" />'); dayData.push(<c:out value="${r[1]}" />);
  </c:forEach>
  new Chart(document.getElementById('dayRevenueChart').getContext('2d'),{
    type:'line',
    data:{labels:dayLabels,datasets:[{label:'Doanh thu ngày (VND)',data:dayData,fill:false,backgroundColor:'rgba(0,217,255,0.5)',borderColor:'rgba(0,217,255,0.95)'}]},
    options:{responsive:true,maintainAspectRatio:false,scales:{y:{beginAtZero:true}},plugins:{legend:{display:false}}}
  });

  // Week
  var weekLabels=[],weekData=[],weekCodes=[];
  <c:forEach var="r" items="${weeklyRevenue}">
    weekLabels.push('<c:out value="${r[0]}" />');
    weekData.push(<c:out value="${r[1]}" />);
    weekCodes.push('<c:out value="${r[2]}" />');
  </c:forEach>
  new Chart(document.getElementById('weeklyRevenueChart').getContext('2d'),{
    type:'bar',
    data:{labels:weekLabels,datasets:[{label:'Doanh thu tuần (VND)',data:weekData,backgroundColor:'rgba(54,162,235,0.4)',borderColor:'rgba(54,162,235,1)',borderWidth:1}]},
    options:{responsive:true,maintainAspectRatio:false,scales:{y:{beginAtZero:true}},plugins:{legend:{display:false}}}
  });

  // Month
  var monthLabels=[],monthData=[];
  <c:forEach var="r" items="${monthlyRevenue}">
    monthLabels.push('<c:out value="${r[0]}" />'); monthData.push(<c:out value="${r[1]}" />);
  </c:forEach>
  new Chart(document.getElementById('monthRevenueChart').getContext('2d'),{
    type:'bar',
    data:{labels:monthLabels,datasets:[{label:'Doanh thu tháng (VND)',data:monthData,backgroundColor:'rgba(255,206,86,0.4)',borderColor:'rgba(255,206,86,1)',borderWidth:1}]},
    options:{responsive:true,maintainAspectRatio:false,scales:{y:{beginAtZero:true}},plugins:{legend:{display:false}}}
  });

  // Pie theo danh mục
  var catLabels=[],catData=[];
  <c:forEach var="rc" items="${revenueByCategory}">
    catLabels.push('<c:out value="${rc[0]}" />'); catData.push(<c:out value="${rc[1]}" />);
  </c:forEach>
  new Chart(document.getElementById('revenueByCategoryChart').getContext('2d'),{
    type:'pie',
    data:{labels:catLabels,datasets:[{data:catData,backgroundColor:['#4dc9f6','#f67019','#f53794','#537bc4','#acc236','#166a8f','#00a950','#58595b','#8549ba']}]},
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom'}}}
  });

  // Sorting helper
  function parseCurrencyCell(td){ return Number((td.innerText || '0').replace(/[^\d.]/g,'')); }
  function sortTableByNumeric(tableId, columnIndex, asc){
    const tbody = document.querySelector('#'+tableId+' tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    rows.sort((a,b)=>{
      const va = parseCurrencyCell(a.children[columnIndex]);
      const vb = parseCurrencyCell(b.children[columnIndex]);
      return asc ? (va - vb) : (vb - va);
    });
    rows.forEach(r=>tbody.appendChild(r));
  }
  document.querySelectorAll('.sort-icon').forEach(icon=>{
    icon.addEventListener('click', ()=>{
      const tableId = icon.getAttribute('data-target');
      const col = Number(icon.getAttribute('data-index'));
      const asc = !icon.classList.contains('fa-sort-up');
      // toggle icon state
      icon.classList.toggle('fa-sort-up', asc);
      icon.classList.toggle('fa-sort-down', !asc);
      icon.classList.add('active');
      sortTableByNumeric(tableId, col, asc);
    });
  });

  // Export
  function exportExcel(){
    const wb = XLSX.utils.book_new();
    ['tableDay','tableWeek','tableMonth','tableTopProductRevenue'].forEach((id, idx)=>{
      const ws = XLSX.utils.table_to_sheet(document.getElementById(id));
      XLSX.utils.book_append_sheet(wb, ws, ['Ngày','Tuần','Tháng','TopSP'][idx]);
    });
    XLSX.writeFile(wb, 'revenue.xlsx');
  }
  async function exportPDF(){
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ unit:'pt', format:'a4' });
    doc.text('Báo cáo doanh thu', 40, 40);
    let y = 70;
    function addSection(title, tableId){
      doc.setFontSize(12);
      doc.text(title, 40, y); y += 16;
      const rows = Array.from(document.querySelectorAll('#'+tableId+' tbody tr')).slice(0, 30).map(tr=>{
        const tds = tr.querySelectorAll('td');
        return Array.from(tds).map(td=>td.innerText).join(' | ');
      });
      rows.forEach(line=>{
        doc.text(line, 40, y); y += 14;
        if(y > 780){ doc.addPage(); y = 40; }
      });
      y += 10;
    }
    addSection('Theo ngày', 'tableDay');
    addSection('Theo tuần', 'tableWeek');
    addSection('Theo tháng', 'tableMonth');
    addSection('Top doanh thu (sản phẩm)', 'tableTopProductRevenue');
    doc.save('revenue.pdf');
  }
</script>
</body>
</html>