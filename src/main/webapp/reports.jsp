<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    if(currentUser == null || !"ADMIN".equals(currentRole)) { response.sendRedirect("login.jsp"); return; }

    // Analytics Variables
    int basicCount = 0, proCount = 0;
    double courtRev = 0.0, tournRev = 0.0, subRev = 0.0;
    int tennisBookings = 0, badmBookings = 0, ttBookings = 0;

    Connection conn = null; Statement st = null; ResultSet rs = null;
    try {
        conn = DBConnection.getConnection();
        st = conn.createStatement();
        
        // 1. Membership Demographics
        rs = st.executeQuery("SELECT tier, COUNT(*) FROM users WHERE role='MEMBER' GROUP BY tier");
        while(rs.next()) {
            if("PRO".equals(rs.getString(1))) proCount = rs.getInt(2);
            else basicCount = rs.getInt(2);
        }
        rs.close();

        // 2. Revenue Categorization
        rs = st.executeQuery("SELECT type, amount FROM payments WHERE status='PAID'");
        while(rs.next()) {
            String type = rs.getString("type").toLowerCase();
            double amt = rs.getDouble("amount");
            if(type.contains("court")) courtRev += amt;
            else if(type.contains("tournament") || type.contains("event")) tournRev += amt;
            else if(type.contains("membership") || type.contains("upgrade")) subRev += amt;
        }
        rs.close();

        // 3. Court Utilization
        rs = st.executeQuery("SELECT court_name FROM bookings");
        while(rs.next()) {
            String court = rs.getString("court_name").toLowerCase();
            if(court.contains("tennis") && !court.contains("table")) tennisBookings++;
            else if(court.contains("badminton")) badmBookings++;
            else if(court.contains("table")) ttBookings++;
        }
    } catch(Exception e) { e.printStackTrace(); } 
    finally { 
        if(rs!=null) try{rs.close();}catch(Exception e){} 
        if(st!=null) try{st.close();}catch(Exception e){} 
        if(conn!=null) try{conn.close();}catch(Exception e){} 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Analytics & Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        /* EXACT MATCH CSS FROM ADMIN DASHBOARD TO PREVENT LAYOUT JUMPING */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; }
        .sidebar { height: 100vh; width: 250px; background-color: #1a2b4c; color: #fff; position: fixed; top: 0; left: 0; padding-top: 20px; overflow-y: auto; }
        .sidebar .brand { font-size: 1.5rem; font-weight: bold; padding: 0 20px 20px; border-bottom: 1px solid #2a3f6c; margin-bottom: 20px;}
        .sidebar a { color: #a8b2c1; text-decoration: none; padding: 12px 20px; display: block; transition: 0.3s; font-size: 0.95rem;}
        .sidebar a:hover, .sidebar a.active { background-color: #2a3f6c; color: #fff; border-left: 4px solid #fff; }
        .sidebar i { width: 25px; }
        .main-content { margin-left: 250px; }
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; justify-content: space-between; align-items: center; }
        .content-padding { padding: 30px; }
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; height: 100%; }
        .chart-container { position: relative; height: 250px; width: 100%; display: flex; justify-content: center;}
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp" class="active"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Intelligence & Analytics</h5>
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding" id="printable-report">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="section-title fw-bold mb-0" id="report-title"><i class="fas fa-chart-pie me-2 text-info"></i> Operations Report</h4>
                
                <button class="btn btn-dark" id="export-btn" onclick="generateProfessionalPDF()"><i class="fas fa-file-pdf me-2"></i> Download PDF</button>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-6">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-1 text-center">Revenue Distribution</h6>
                        <p class="text-muted small text-center mb-4">Income generated by category</p>
                        <div class="chart-container">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-1 text-center">All-Time Court Utilization</h6>
                        <p class="text-muted small text-center mb-4">Total bookings by sport</p>
                        <div class="chart-container">
                            <canvas id="courtChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-md-4">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-1 text-center">Membership Tiers</h6>
                        <p class="text-muted small text-center mb-4">Pro vs Basic active subscriptions</p>
                        <div class="chart-container" style="height: 200px;">
                            <canvas id="memberChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-3 border-bottom pb-2">Operations Summary</h6>
                        <div class="row mt-3 align-items-center">
                            
                            <div class="col-md-5 border-end">
                                <div class="text-center mb-3">
                                    <h3 class="fw-bold text-success mb-1">₹ <%= String.format("%.0f", (courtRev + tournRev + subRev)) %></h3>
                                    <p class="text-muted small text-uppercase mb-0">Total Lifetime Revenue</p>
                                </div>
                                
                                <div class="d-flex justify-content-between small text-muted border-top pt-3">
                                    <span><i class="fas fa-border-all text-primary me-2"></i> Court Rentals</span>
                                    <span class="text-dark fw-bold">₹ <%= String.format("%.0f", courtRev) %></span>
                                </div>
                                <div class="d-flex justify-content-between small text-muted mt-2">
                                    <span><i class="fas fa-trophy text-success me-2"></i> Tournaments</span>
                                    <span class="text-dark fw-bold">₹ <%= String.format("%.0f", tournRev) %></span>
                                </div>
                                <div class="d-flex justify-content-between small text-muted mt-2">
                                    <span><i class="fas fa-star text-warning me-2"></i> Pro Upgrades</span>
                                    <span class="text-dark fw-bold">₹ <%= String.format("%.0f", subRev) %></span>
                                </div>
                            </div>
                            
                            <div class="col-md-7">
                                <div class="row">
                                    <div class="col-6 text-center border-end">
                                        <h2 class="fw-bold text-primary mb-1"><%= (tennisBookings + badmBookings + ttBookings) %></h2>
                                        <p class="text-muted small text-uppercase">Processed Bookings</p>
                                    </div>
                                    <div class="col-6 text-center">
                                        <h2 class="fw-bold text-warning mb-1"><%= proCount %></h2>
                                        <p class="text-muted small text-uppercase">Active Pro Members</p>
                                    </div>
                                </div>
                            </div>
                            
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script>
        // 1. Revenue Doughnut Chart
        new Chart(document.getElementById('revenueChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Court Rentals (₹)', 'Tournaments (₹)', 'Pro Upgrades (₹)'],
                datasets: [{
                    data: [<%= courtRev %>, <%= tournRev %>, <%= subRev %>],
                    backgroundColor: ['#3b82f6', '#10b981', '#f59e0b'],
                    borderWidth: 0
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });

        // 2. Court Utilization Polar Area Chart
        new Chart(document.getElementById('courtChart').getContext('2d'), {
            type: 'polarArea',
            data: {
                labels: ['Tennis', 'Badminton', 'Table Tennis'],
                datasets: [{
                    data: [<%= tennisBookings %>, <%= badmBookings %>, <%= ttBookings %>],
                    backgroundColor: ['rgba(59, 130, 246, 0.7)', 'rgba(16, 185, 129, 0.7)', 'rgba(244, 63, 94, 0.7)'],
                    borderWidth: 1
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });

        // 3. Membership Demographics Pie Chart
        new Chart(document.getElementById('memberChart').getContext('2d'), {
            type: 'pie',
            data: {
                labels: ['PRO Members', 'BASIC Members'],
                datasets: [{
                    data: [<%= proCount %>, <%= basicCount %>],
                    backgroundColor: ['#f59e0b', '#94a3b8'],
                    borderWidth: 0
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });
    </script>
    <script>
        function generateProfessionalPDF() {
            //to print
            const element = document.getElementById('printable-report');
            const exportBtn = document.getElementById('export-btn');
            
            exportBtn.style.display = 'none';

            // 3. Configure the PDF settings
            const opt = {
                margin:       0.3,
                filename:     'CourtSync_Operations_Report.pdf',
                image:        { type: 'jpeg', quality: 1.0 },
                html2canvas:  { scale: 2, useCORS: true },
                jsPDF:        { unit: 'in', format: 'a4', orientation: 'portrait' }
            };

            // 4. Generate the PDF and then restore the button
            html2pdf().set(opt).from(element).save().then(() => {
                exportBtn.style.display = 'inline-block';
            });
        }
    </script>
</body>
</html>