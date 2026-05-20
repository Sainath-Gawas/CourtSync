<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Announcements</title>
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
        
        .announcement-card { background: #fff; border-radius: 12px; border: none; border-left: 5px solid #1a2b4c; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; transition: 0.2s; margin-bottom: 20px;}
        .announcement-card:hover { transform: translateX(5px); box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        
        /* Dynamic Category Colors */
        .border-Event { border-left-color: #1e8e3e; }
        .border-Maintenance { border-left-color: #e53e3e; }
        .border-General { border-left-color: #3182ce; }
        
        .badge-Event { background-color: #e6f4ea; color: #1e8e3e; }
        .badge-Maintenance { background-color: #fed7d7; color: #e53e3e; }
        .badge-General { background-color: #ebf8ff; color: #3182ce; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <div class="px-3 mb-2 mt-2 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Menu</div>
        <a href="member_dashboard.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="book_court.jsp"><i class="far fa-calendar-plus"></i> Book a Court</a>
        <a href="my_bookings.jsp"><i class="fas fa-history"></i> My Bookings</a>
        <a href="tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="announcements.jsp" class="active"><i class="fas fa-bullhorn"></i> Announcements</a>
        <div class="px-3 mb-2 mt-4 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Account</div>
        <a href="profile.jsp"><i class="far fa-id-badge"></i> My Profile</a>
        <a href="LogoutServlet" class="mt-2 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <div class="d-flex align-items-center">
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Player">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h4 class="fw-bold mb-1"><i class="fas fa-bullhorn me-2 text-primary"></i> Notice Board</h4>
                    <p class="text-muted mb-0">Stay updated with the latest academy news and schedules.</p>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-12">
                    <%
                        Connection conn = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;
                        
                        try {
                            conn = DBConnection.getConnection();
                            // Fetch all announcements, newest first
                            String sql = "SELECT * FROM announcements ORDER BY id DESC";
                            ps = conn.prepareStatement(sql);
                            rs = ps.executeQuery();
                            
                            boolean hasNotices = false;
                            while(rs.next()) {
                                hasNotices = true;
                                String category = rs.getString("category");
                                String icon = "fa-info-circle";
                                
                                if("Event".equals(category)) icon = "fa-trophy";
                                else if("Maintenance".equals(category)) icon = "fa-tools";
                    %>
                                <div class="announcement-card border-<%= category %>">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="badge badge-<%= category %> px-3 py-2 rounded-pill"><i class="fas <%= icon %> me-1"></i> <%= category %></span>
                                        <small class="text-muted fw-bold"><i class="far fa-calendar-alt me-1"></i> <%= rs.getString("posted_date") %></small>
                                    </div>
                                    <h5 class="fw-bold mb-2"><%= rs.getString("title") %></h5>
                                    <p class="text-muted mb-0"><%= rs.getString("message") %></p>
                                </div>
                    <%
                            }
                            if(!hasNotices) {
                                out.println("<div class='text-center text-muted py-5'><i class='fas fa-inbox fa-3x mb-3 opacity-25'></i><h5>No announcements yet!</h5></div>");
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            try { if(rs != null) rs.close(); } catch(Exception e){}
                            try { if(ps != null) ps.close(); } catch(Exception e){}
                            try { if(conn != null) conn.close(); } catch(Exception e){}
                        }
                    %>
                </div>
            </div>
            
        </div>
    </div>
</body>
</html>