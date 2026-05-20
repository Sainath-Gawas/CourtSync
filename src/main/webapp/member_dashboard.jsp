<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    //FETCH DATA
    String nextSport = "No upcoming matches";
    String nextDate = "--";
    String nextTime = "--";
    int totalMatches = 0;
    boolean hasMatch = false;

    Connection conn = null;
    PreparedStatement psMatch = null;
    PreparedStatement psCount = null;
    ResultSet rsMatch = null;
    ResultSet rsCount = null;

    try {
        conn = DBConnection.getConnection();
        
        //Get their next upcoming match
        String matchSql = "SELECT court_name, booking_date, time_slot FROM bookings WHERE username = ? AND booking_date >= DATE('now') ORDER BY booking_date ASC LIMIT 1";
        psMatch = conn.prepareStatement(matchSql);
        psMatch.setString(1, currentUser);
        rsMatch = psMatch.executeQuery();
        
        if(rsMatch.next()) {
            hasMatch = true;
            nextSport = rsMatch.getString("court_name");
            nextDate = rsMatch.getString("booking_date");
            nextTime = rsMatch.getString("time_slot");
        }

        // Query 2: Get total matches booked
        String countSql = "SELECT COUNT(*) AS total FROM bookings WHERE username = ?";
        psCount = conn.prepareStatement(countSql);
        psCount.setString(1, currentUser);
        rsCount = psCount.executeQuery();
        
        if(rsCount.next()) {
            totalMatches = rsCount.getInt("total");
        }
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if(rsMatch != null) rsMatch.close(); } catch(Exception e){}
        try { if(rsCount != null) rsCount.close(); } catch(Exception e){}
        try { if(psMatch != null) psMatch.close(); } catch(Exception e){}
        try { if(psCount != null) psCount.close(); } catch(Exception e){}
        try { if(conn != null) conn.close(); } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Player Dashboard</title>
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
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; justify-content: flex-end; align-items: center; }
        .content-padding { padding: 30px; }
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 20px; height: 100%; }
        .stat-icon { width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #f0f4f8; color: #1a2b4c; }
        .highlight-card { background: linear-gradient(135deg, #1a2b4c 0%, #2a3f6c 100%); color: white; }
        .highlight-card .stat-icon { background: rgba(255,255,255,0.2); color: white; }
        .btn-brand { background-color: #1a2b4c; color: white; border-radius: 8px; transition: 0.3s; }
        .btn-brand:hover { background-color: #2a3f6c; color: white; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <div class="px-3 mb-2 mt-2 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Menu</div>
        <a href="member_dashboard.jsp" class="active"><i class="fas fa-home"></i> Home</a>
        <a href="book_court.jsp"><i class="far fa-calendar-plus"></i> Book a Court</a>
        <a href="my_bookings.jsp"><i class="fas fa-history"></i> My Bookings</a>
        <a href="tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <div class="px-3 mb-2 mt-4 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Account</div>
        <a href="profile.jsp"><i class="far fa-id-badge"></i> My Profile</a>
        <a href="LogoutServlet" class="mt-2 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Player">
                <span class="fw-medium"><%= currentUser %> <i class="fas fa-chevron-down ms-1 fs-6 text-muted"></i></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="mb-4">
                <h4 class="fw-bold mb-1">Welcome back, <%= currentUser %>!</h4>
                <p class="text-muted">Here is your academy overview for today.</p>
            </div>

            <div class="row g-4 mb-4">
                
                <div class="col-md-6">
                    <div class="scms-card highlight-card d-flex flex-column justify-content-between p-4">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div>
                                <span class="badge bg-warning text-dark mb-2">Next Match</span>
                                <h4 class="fw-bold mb-0"><%= nextSport %></h4>
                            </div>
                            <div class="stat-icon"><i class="fas fa-table-tennis fs-4"></i></div>
                        </div>
                        <div>
                            <p class="mb-1 opacity-75"><i class="far fa-calendar-alt me-2"></i> <%= nextDate %></p>
                            <p class="mb-1 opacity-75"><i class="far fa-clock me-2"></i> <%= nextTime %></p>
                        </div>
                        <% if(hasMatch) { %>
                            <a href="my_bookings.jsp" class="btn btn-light mt-3 fw-bold w-100">View Schedule</a>
                        <% } else { %>
                            <a href="book_court.jsp" class="btn btn-warning mt-3 fw-bold w-100">Book Your First Court!</a>
                        <% } %>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="scms-card d-flex flex-column justify-content-center align-items-center text-center">
                        <div class="stat-icon mb-3 bg-primary bg-opacity-10 text-primary" style="width: 80px; height: 80px; font-size: 2rem;">
                            <i class="fas fa-fire"></i>
                        </div>
                        <h5 class="text-muted mb-2">Total Bookings & Events</h5>
                        <h2 class="fw-bold mb-0 text-dark"><%= totalMatches %></h2>
                        <p class="small text-muted mt-2 mb-0">Lifetime Sessions</p>
                    </div>
                </div>
                <div class="row g-4 mt-1">
                <div class="col-md-7">
                    <div class="scms-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0"><i class="fas fa-shopping-bag text-primary me-2"></i> Pro Shop Quick Rent</h6>
                        </div>
                        <div class="table-responsive">
                            <table class="table align-middle table-hover mb-0">
                                <tbody>
                                    <%
                                        try(Connection eqConn = DBConnection.getConnection();
                                            PreparedStatement eqPs = eqConn.prepareStatement("SELECT * FROM equipment WHERE available_quantity > 0 LIMIT 4");
                                            ResultSet eqRs = eqPs.executeQuery()) {
                                            boolean hasGear = false;
                                            while(eqRs.next()) {
                                                hasGear = true;
                                    %>
                                                <tr>
                                                    <td class="fw-bold text-dark"><%= eqRs.getString("item_name") %></td>
                                                    <td><span class="badge bg-light-success text-success border border-success"><%= eqRs.getInt("available_quantity") %> In Stock</span></td>
                                                    <td class="text-end">
                                                        <form action="RentEquipmentServlet" method="POST" class="m-0">
                                                            <input type="hidden" name="action" value="rent">
                                                            <input type="hidden" name="equip_id" value="<%= eqRs.getInt("id") %>">
                                                            <button type="submit" class="btn btn-sm btn-outline-primary fw-bold px-3">Rent (₹<%= String.format("%.0f", eqRs.getDouble("rental_price")) %>)</button>
                                                        </form>
                                                    </td>
                                                </tr>
                                    <%
                                            }
                                            if(!hasGear) out.println("<tr><td colspan='3' class='text-muted small text-center py-3'>No gear available right now.</td></tr>");
                                        } catch(Exception e) {}
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="col-md-5">
                    <div class="scms-card highlight-card">
                        <h6 class="fw-bold mb-3"><i class="fas fa-box-open text-warning me-2"></i> My Active Rentals</h6>
                        <ul class="list-group list-group-flush rounded bg-transparent">
                            <%
                                try(Connection myEqConn = DBConnection.getConnection();
                                    // Ensure table exists for this initial read to prevent silent crashes
                                    Statement setupStmt = myEqConn.createStatement()) {
                                    setupStmt.execute("CREATE TABLE IF NOT EXISTS equipment_bookings (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, equip_id INTEGER, item_name TEXT, status TEXT)");
                                    
                                    try(PreparedStatement myEqPs = myEqConn.prepareStatement("SELECT * FROM equipment_bookings WHERE username = ? AND status = 'RENTED'");) {
                                        myEqPs.setString(1, currentUser);
                                        ResultSet myEqRs = myEqPs.executeQuery();
                                        boolean hasRentals = false;
                                        while(myEqRs.next()) {
                                            hasRentals = true;
                            %>
                                            <li class="list-group-item bg-transparent text-white border-white border-opacity-25 d-flex justify-content-between align-items-center px-0">
                                                <span><i class="fas fa-check-circle text-success me-2"></i> <%= myEqRs.getString("item_name") %></span>
                                                <form action="RentEquipmentServlet" method="POST" class="m-0">
                                                    <input type="hidden" name="action" value="return">
                                                    <input type="hidden" name="booking_id" value="<%= myEqRs.getInt("id") %>">
                                                    <input type="hidden" name="equip_id" value="<%= myEqRs.getInt("equip_id") %>">
                                                    <button type="submit" class="btn btn-sm btn-light text-dark fw-bold" style="font-size: 0.75rem;">Return</button>
                                                </form>
                                            </li>
                            <%
                                        }
                                        if(!hasRentals) out.println("<li class='list-group-item bg-transparent text-white border-0 px-0 opacity-75 small'>You have no active gear rentals.</li>");
                                    }
                                } catch(Exception e) {}
                            %>
                        </ul>
                    </div>
                </div>
            </div>
            </div>

            <div class="row g-4">
                <div class="col-md-6">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-3">Quick Actions</h6>
                        <div class="d-grid gap-3">
                            <a href="book_court.jsp" class="btn btn-brand py-3 text-start px-4"><i class="far fa-calendar-plus me-3"></i> Book a Court</a>
                            <a href="tournaments.jsp" class="btn btn-outline-dark py-3 text-start px-4"><i class="fas fa-trophy me-3"></i> View Upcoming Tournaments</a>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-3">Academy Notices</h6>
                        <div class="list-group list-group-flush">
                            <%
                                Connection dashConn = null;
                                PreparedStatement dashPs = null;
                                ResultSet dashRs = null;
                                try {
                                    dashConn = DBConnection.getConnection();
                                    // Fetch only the 2 most recent notices
                                    String sql = "SELECT * FROM announcements ORDER BY id DESC LIMIT 2";
                                    dashPs = dashConn.prepareStatement(sql);
                                    dashRs = dashPs.executeQuery();
                                    
                                    while(dashRs.next()) {
                            %>
                                        <div class="list-group-item px-0 py-3 border-bottom">
                                            <div class="d-flex w-100 justify-content-between">
                                                <h6 class="mb-1 fw-bold text-truncate" style="max-width: 70%;"><%= dashRs.getString("title") %></h6>
                                                <small class="text-muted" style="font-size: 0.75rem;"><%= dashRs.getString("posted_date") %></small>
                                            </div>
                                            <p class="mb-1 small text-muted text-truncate"><%= dashRs.getString("message") %></p>
                                        </div>
                            <%
                                    }
                                } catch(Exception e) { e.printStackTrace(); } 
                                finally {
                                    try{ if(dashRs != null) dashRs.close(); } catch(Exception e){}
                                    try{ if(dashPs != null) dashPs.close(); } catch(Exception e){}
                                    try{ if(dashConn != null) dashConn.close(); } catch(Exception e){}
                                }
                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>