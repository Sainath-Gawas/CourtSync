<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    if(currentUser == null || !"ADMIN".equals(currentRole)) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Payments Ledger</title>
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
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp" class="active"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Financial Statement Accounting</h5>
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <h4 class="section-title fw-bold mb-4"><i class="fas fa-file-invoice-dollar me-2 text-success"></i> Revenue Transactions Audit</h4>
            
            <div class="scms-card">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Transaction ID</th>
                                <th>Member Profile</th>
                                <th>Allocation Context</th>
                                <th>Processing Date</th>
                                <th>Amount Received</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    ps = conn.prepareStatement("SELECT * FROM payments ORDER BY id DESC");
                                    rs = ps.executeQuery();
                                    while(rs.next()){
                            %>
                                        <tr>
                                            <td class="text-muted small fw-bold">#TR-00<%= rs.getInt("id") %></td>
                                            <td class="fw-bold">
                                                <img src="https://ui-avatars.com/api/?name=<%= rs.getString("username") %>&size=24&background=E5E7EB&color=374151" class="rounded-circle me-2">
                                                <%= rs.getString("username") %>
                                            </td>
                                            <td><%= rs.getString("type") %></td>
                                            <td><%= rs.getString("payment_date") %></td>
                                            <td class="text-success fw-bold">₹ <%= String.format("%.0f", rs.getDouble("amount")) %></td>
                                            <td><span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1">PAID</span></td>
                                        </tr>
                            <%
                                    }
                                } catch(Exception e){ e.printStackTrace(); }
                                finally { 
                                    if(rs!=null)rs.close(); if(ps!=null)ps.close(); if(conn!=null)conn.close(); 
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>