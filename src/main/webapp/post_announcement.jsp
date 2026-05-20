<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security check: Only Admins
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    if(currentUser == null || !"ADMIN".equals(currentRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Post Announcement</title>
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
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 30px; }
        .btn-brand { background-color: #1a2b4c; color: white; border-radius: 8px; transition: 0.3s; }
        .btn-brand:hover { background-color: #2a3f6c; color: white; }
    </style>
</head>
<body>

   <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp" class="<%= request.getRequestURI().contains("dashboard") ? "active" : "" %>"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp" class="<%= request.getRequestURI().contains("members") ? "active" : "" %>"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp" class="<%= request.getRequestURI().contains("bookings") ? "active" : "" %>"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp" class="<%= request.getRequestURI().contains("tournaments") ? "active" : "" %>"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp" class="<%= request.getRequestURI().contains("payments") ? "active" : "" %>"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp" class="<%= request.getRequestURI().contains("equipment") ? "active" : "" %>"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp" class="<%= request.getRequestURI().contains("announcement") ? "active" : "" %>"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp" class="<%= request.getRequestURI().contains("reports") ? "active" : "" %>"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35">
                <span class="fw-medium"><%= currentUser %> <i class="fas fa-chevron-down ms-1 fs-6 text-muted"></i></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    
                    <div class="d-flex align-items-center justify-content-between mb-4">
                        <h4 class="fw-bold mb-0"><i class="fas fa-bullhorn me-2 text-primary"></i> Broadcast Notice</h4>
                    </div>

                    <% if(request.getAttribute("successMessage") != null) { %>
                        <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i> <%= request.getAttribute("successMessage") %></div>
                    <% } %>
                    <% if(request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("errorMessage") %></div>
                    <% } %>

                    <div class="scms-card">
                        <form action="PostAnnouncementServlet" method="POST">
                            
                            <div class="row g-3 mb-4">
                                <div class="col-md-8">
                                    <label class="form-label fw-bold text-muted small">Notice Title</label>
                                    <input type="text" name="title" class="form-control form-control-lg" placeholder="e.g., Weekend Tournament Registration" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold text-muted small">Category</label>
                                    <select name="category" class="form-select form-select-lg" required>
                                        <option value="Event">Event</option>
                                        <option value="Maintenance">Maintenance</option>
                                        <option value="General">General Notice</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold text-muted small">Message Details</label>
                                <textarea name="message" class="form-control" rows="6" placeholder="Type your detailed announcement here..." required></textarea>
                            </div>

                            <div class="d-flex justify-content-end">
                                <button type="reset" class="btn btn-light me-2 fw-bold px-4">Clear</button>
                                <button type="submit" class="btn btn-brand px-5 fw-bold"><i class="fas fa-paper-plane me-2"></i> Publish Notice</button>
                            </div>
                            
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>
</body>
</html>