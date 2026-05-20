<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - My Schedule</title>
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
        /* NEW TOP NAVBAR STYLES */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; justify-content: flex-end; align-items: center; }
        .content-padding { padding: 30px; }
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; margin-bottom: 30px; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <div class="px-3 mb-2 mt-2 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Menu</div>
        <a href="member_dashboard.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="book_court.jsp"><i class="far fa-calendar-plus"></i> Book a Court</a>
        <a href="my_bookings.jsp" class="active"><i class="fas fa-history"></i> My Bookings</a>
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
            <h4 class="fw-bold mb-4"><i class="fas fa-history me-2 text-primary"></i> My Schedule</h4>

            <div class="scms-card">
                <h5 class="fw-bold mb-3"><i class="fas fa-table-tennis text-primary me-2"></i> Court Rentals</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light"><tr><th>Date</th><th>Time Slot</th><th>Court</th><th>Status</th></tr></thead>
                        <tbody>
                            <%
                                Connection conn1 = null; PreparedStatement ps1 = null; ResultSet rs1 = null;
                                try {
                                    conn1 = DBConnection.getConnection();
                                    ps1 = conn1.prepareStatement("SELECT * FROM bookings WHERE username = ? AND court_name NOT LIKE 'Event - %' ORDER BY booking_date DESC");
                                    ps1.setString(1, currentUser);
                                    rs1 = ps1.executeQuery();
                                    boolean hasCourts = false;
                                    while(rs1.next()) { hasCourts = true;
                            %>
                                        <tr>
                                            <td class="fw-bold text-dark"><%= rs1.getString("booking_date") %></td>
                                            <td><i class="far fa-clock text-muted me-1"></i> <%= rs1.getString("time_slot") %></td>
                                            <td><%= rs1.getString("court_name") %></td>
                                            <td><span class="badge bg-success"><%= rs1.getString("status") %></span></td>
                                        </tr>
                            <%
                                    }
                                    if(!hasCourts) out.println("<tr><td colspan='4' class='text-center text-muted py-4'>No court bookings found.</td></tr>");
                                } catch(Exception e) {} finally { try{if(rs1!=null)rs1.close(); if(ps1!=null)ps1.close(); if(conn1!=null)conn1.close();}catch(Exception e){} }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="scms-card">
                <h5 class="fw-bold mb-3"><i class="fas fa-trophy text-warning me-2"></i> Tournament Registrations</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light"><tr><th>Event Name</th><th>Event Date</th><th>Status</th></tr></thead>
                        <tbody>
                            <%
                                Connection conn2 = null; PreparedStatement ps2 = null; ResultSet rs2 = null;
                                try {
                                    conn2 = DBConnection.getConnection();
                                    ps2 = conn2.prepareStatement("SELECT * FROM bookings WHERE username = ? AND court_name LIKE 'Event - %' ORDER BY booking_date DESC");
                                    ps2.setString(1, currentUser);
                                    rs2 = ps2.executeQuery();
                                    boolean hasEvents = false;
                                    while(rs2.next()) { hasEvents = true;
                            %>
                                        <tr>
                                            <td class="fw-bold text-dark"><%= rs2.getString("court_name").replace("Event - ", "") %></td>
                                            <td><i class="far fa-calendar-alt text-muted me-1"></i> <%= rs2.getString("booking_date") %></td>
                                            <td><span class="badge bg-warning text-dark">Registered</span></td>
                                        </tr>
                            <%
                                    }
                                    if(!hasEvents) out.println("<tr><td colspan='3' class='text-center text-muted py-4'>You haven't joined any tournaments yet.</td></tr>");
                                } catch(Exception e) {} finally { try{if(rs2!=null)rs2.close(); if(ps2!=null)ps2.close(); if(conn2!=null)conn2.close();}catch(Exception e){} }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>