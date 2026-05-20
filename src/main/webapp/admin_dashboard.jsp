<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    if(currentUser == null || !"ADMIN".equals(currentRole)) { response.sendRedirect("login.jsp"); return; }

    int totalMembers = 0, totalCourts = 6, todaysBookings = 0;
    double monthlyRevenue = 0.0;
    double[] dynamicRevenueData = new double[12];
    String todayStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        try(PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE role = 'MEMBER'"); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) totalMembers = rs.getInt(1);
        }
        try(PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM bookings WHERE booking_date = date('now', 'localtime')"); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) todaysBookings = rs.getInt(1);
        }
        try(PreparedStatement ps = conn.prepareStatement("SELECT SUM(amount) FROM payments WHERE status = 'PAID'"); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) monthlyRevenue = rs.getDouble(1);
        }
        try(PreparedStatement ps = conn.prepareStatement("SELECT strftime('%m', payment_date) as mth, SUM(amount) as total FROM payments WHERE status = 'PAID' AND strftime('%Y', payment_date) = strftime('%Y', 'now') GROUP BY mth"); ResultSet rs = ps.executeQuery()) {
            while(rs.next()) {
                int monthIndex = Integer.parseInt(rs.getString("mth")) - 1;
                dynamicRevenueData[monthIndex] = rs.getDouble("total");
            }
        }
    } catch(Exception e) { e.printStackTrace(); } 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
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
        .stat-icon { width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #f0f4f8; color: #1a2b4c; }
        .quick-action-btn { background-color: #1a2b4c; color: white; border-radius: 25px; padding: 10px 20px; border: none; font-weight: 500; transition: 0.3s; width: 100%;}
        .quick-action-btn:hover { background-color: #2a3f6c; color: white; }
        .equip-icon-box { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .bg-tennis { background-color: #e6f0fa; }
        .bg-badminton { background-color: #f0fdf4; }
        .bg-tt { background-color: #fff1f2; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp" class="active"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Academy Overview</h5>
            <div class="d-flex align-items-center">
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="row g-4 mb-4">
                <div class="col-md-3"><div class="scms-card d-flex justify-content-between align-items-center"><div><p class="text-muted mb-1 fs-6">Total Members</p><h3 class="fw-bold mb-0"><%= totalMembers %></h3></div><div class="stat-icon"><i class="fas fa-user-friends"></i></div></div></div>
                <div class="col-md-3"><div class="scms-card d-flex justify-content-between align-items-center"><div><p class="text-muted mb-1 fs-6">Active Courts</p><h3 class="fw-bold mb-0"><%= totalCourts %></h3></div><div class="stat-icon"><i class="fas fa-border-all"></i></div></div></div>
                <div class="col-md-3"><div class="scms-card d-flex justify-content-between align-items-center"><div><p class="text-muted mb-1 fs-6">Today's Bookings</p><h3 class="fw-bold mb-0"><%= todaysBookings %></h3></div><div class="stat-icon"><i class="far fa-calendar-check"></i></div></div></div>
                <div class="col-md-3"><div class="scms-card d-flex justify-content-between align-items-center"><div><p class="text-muted mb-1 fs-6">Total Collections</p><h3 class="fw-bold mb-0 text-success">₹ <%= String.format("%.0f", monthlyRevenue) %></h3></div><div class="stat-icon"><span class="text-success fs-4">₹</span></div></div></div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-1">Revenue Analytics</h6>
                        <p class="text-muted small mb-4">Membership & court fees</p>
                        <canvas id="revenueChart" height="300"></canvas>
                    </div>
                </div>
                
                <div class="col-md-8">
                    <div class="scms-card">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h6 class="fw-bold mb-0"><i class="fas fa-satellite-dish text-primary me-2"></i> Live Facility Radar</h6>
                            <span class="badge bg-dark px-3 py-2"><%= todayStr %></span>
                        </div>
                        <div class="row g-3">
                            <%
                                String[] masterCourts = {
                                    "Tennis - Court 1 (Clay)", "Tennis - Court 2 (Grass)", 
                                    "Badminton - Court 1 (Indoor)", "Badminton - Court 2 (Indoor)", 
                                    "Table Tennis - Table 1", "Table Tennis - Table 2"
                                };
                                
                                java.util.HashMap<String, String> todayMap = new java.util.HashMap<>();
                                try {
                                    if(conn == null || conn.isClosed()) conn = DBConnection.getConnection();
                                    PreparedStatement psLive = conn.prepareStatement("SELECT court_name, time_slot, username FROM bookings WHERE booking_date = date('now', 'localtime')");
                                    ResultSet rsLive = psLive.executeQuery();
                                    
                                    while(rsLive.next()) {
                                        String c = rsLive.getString("court_name");
                                        String info = "<strong>" + rsLive.getString("time_slot") + "</strong> <span class='text-muted'>by " + rsLive.getString("username") + "</span>";
                                        if(todayMap.containsKey(c)) todayMap.put(c, todayMap.get(c) + "<br>" + info);
                                        else todayMap.put(c, info);
                                    }
                                    
                                    for(String c : masterCourts) {
                                        String nativeIcon = "🏓"; String bg = "bg-tt";
                                        if(c.contains("Tennis") && !c.contains("Table")) { nativeIcon = "🎾"; bg = "bg-tennis"; }
                                        else if(c.contains("Badminton")) { nativeIcon = "🏸"; bg = "bg-badminton"; }
                                        
                                        boolean isBooked = todayMap.containsKey(c);
                            %>
                                        <div class="col-md-6">
                                            <div class="border rounded p-3 h-100 d-flex flex-column">
                                                <div class="d-flex align-items-center mb-2">
                                                    <div class="equip-icon-box <%= bg %> me-3"><%= nativeIcon %></div>
                                                    <h6 class="fw-bold mb-0 text-dark small"><%= c %></h6>
                                                </div>
                                                <div class="mt-auto pt-2">
                                                    <% if(isBooked) { %>
                                                        <div class="p-2 bg-light-warning rounded small border border-warning" style="background-color: #fffbeb;">
                                                            <strong class="text-dark"><i class="fas fa-lock text-warning me-1"></i> Booked Today:</strong><br>
                                                            <%= todayMap.get(c) %>
                                                        </div>
                                                    <% } else { %>
                                                        <div class="p-2 bg-light-success rounded small border border-success text-success fw-bold text-center" style="background-color: #ecfdf5;">
                                                            <i class="fas fa-lock-open me-1"></i> Available All Day
                                                        </div>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                            <%
                                    }
                                } catch(Exception e) { e.printStackTrace(); } 
                                finally { if(conn != null) conn.close(); }
                            %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="scms-card mb-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h6 class="fw-bold mb-0"><i class="fas fa-bullhorn text-danger me-2"></i> Community Announcements</h6>
                </div>
                <div class="row g-3"> 
                    <%
                        try(Connection conn2 = DBConnection.getConnection(); 
                            PreparedStatement annPs = conn2.prepareStatement("SELECT * FROM announcements ORDER BY id DESC LIMIT 3"); 
                            ResultSet annRs = annPs.executeQuery()) {
                            
                            boolean hasData = false;
                            while(annRs.next()) {
                                hasData = true;
                    %>
                                <div class="col-md-4">
                                    <div class="border rounded p-3 h-100 bg-light">
                                        <h6 class="fw-bold small mb-2 text-dark"><%= annRs.getString("title") %></h6>
                                        <p class="text-muted small mb-0"><%= annRs.getString("message") %></p>
                                    </div>
                                </div>
                    <%
                            }
                            if(!hasData) out.println("<div class='col-12 text-center text-muted py-3 small'>No announcements broadcasted yet.</div>");
                        } catch(Exception e) { e.printStackTrace(); } 
                    %>
                </div>
            </div>
            
            <h6 class="fw-bold mb-3 mt-2 text-muted">Administrative Quick Actions</h6>
            <div class="row g-3">
                <div class="col"><a href="manage_members.jsp" style="text-decoration: none;"><button class="quick-action-btn"><i class="fas fa-user-plus me-2"></i> Add Member</button></a></div>
                <div class="col"><a href="admin_book_court.jsp" style="text-decoration: none;"><button class="quick-action-btn"><i class="far fa-calendar-plus me-2"></i> Walk-In</button></a></div>
                <div class="col"><a href="manage_tournaments.jsp" style="text-decoration: none;"><button class="quick-action-btn"><i class="fas fa-trophy me-2"></i> Event</button></a></div>
                <div class="col"><a href="manage_payments.jsp" style="text-decoration: none;"><button class="quick-action-btn"><i class="fas fa-rupee-sign me-2"></i> Collect Fee</button></a></div>
                <div class="col"><a href="post_announcement.jsp" style="text-decoration: none;"><button class="quick-action-btn"><i class="fas fa-bullhorn me-2"></i> Announce</button></a></div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'line', 
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Revenue (₹)',
                    data: [
                        <%= dynamicRevenueData[0] %>, <%= dynamicRevenueData[1] %>, <%= dynamicRevenueData[2] %>, 
                        <%= dynamicRevenueData[3] %>, <%= dynamicRevenueData[4] %>, <%= dynamicRevenueData[5] %>,
                        <%= dynamicRevenueData[6] %>, <%= dynamicRevenueData[7] %>, <%= dynamicRevenueData[8] %>,
                        <%= dynamicRevenueData[9] %>, <%= dynamicRevenueData[10] %>, <%= dynamicRevenueData[11] %>
                    ],
                    borderColor: '#1a2b4c', backgroundColor: 'rgba(26, 43, 76, 0.1)', borderWidth: 2, fill: true, tension: 0.4
                }]
            },
            options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true }, x: { grid: { display: false } } } }
        });
    </script>
</body>
</html>