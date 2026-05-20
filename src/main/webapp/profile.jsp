<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - My Profile</title>
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
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 20px; }
        .btn-brand { background-color: #1a2b4c; color: white; border-radius: 8px; transition: 0.3s; }
        .btn-brand:hover { background-color: #2a3f6c; color: white; }
        .profile-header { background: linear-gradient(135deg, #1a2b4c 0%, #2a3f6c 100%); color: white; border-radius: 12px 12px 0 0; padding: 30px; }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; border: 4px solid #fff; margin-top: -50px; background: #fff; }
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
        <div class="px-3 mb-2 mt-4 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Account</div>
        <a href="profile.jsp" class="active"><i class="far fa-id-badge"></i> My Profile</a>
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
            <h4 class="fw-bold mb-4"><i class="far fa-id-badge me-2 text-primary"></i> Player Profile</h4>

            <% if(request.getAttribute("successMessage") != null) { %><div class="alert alert-success"><%= request.getAttribute("successMessage") %></div><% } %>
            <% if(request.getAttribute("errorMessage") != null) { %><div class="alert alert-danger"><%= request.getAttribute("errorMessage") %></div><% } %>

            <div class="row">
                <div class="col-md-4 mb-4">
                    <div class="scms-card p-0 text-center pb-4">
                        <div class="profile-header mb-5"></div>
                        <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&size=128&background=E5E7EB&color=374151" class="profile-avatar shadow-sm mb-3">
                        <h5 class="fw-bold mb-1"><%= currentUser %></h5>
                        <p class="text-muted small mb-3">Member</p>
                        <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-2 rounded-pill">Active Membership</span>
                    </div>
                </div>

                <div class="col-md-8 mb-4">
                    <div class="scms-card">
                        <h5 class="fw-bold mb-4">Edit Details</h5>
                        <form action="UpdateProfileServlet" method="POST">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small text-muted fw-bold">Username</label>
                                    <input type="text" class="form-control" value="<%= currentUser %>" readonly disabled>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small text-muted fw-bold">Full Name</label>
                                    <input type="text" class="form-control" value="<%= currentUser %>" disabled>
                                </div>
                                
                                <div class="col-12 mt-4">
                                    <hr class="text-muted opacity-25">
                                    <h6 class="fw-bold mb-3 mt-3">Change Password</h6>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small text-muted fw-bold">Current Temporary Password</label>
                                    <input type="password" name="old_password" class="form-control" required placeholder="Verify current password">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small text-muted fw-bold">New Password</label>
                                    <input type="password" name="new_password" class="form-control" required placeholder="Create a new password">
                                </div>
                                <div class="col-12 mt-4 text-end">
                                    <button type="submit" class="btn btn-brand px-4 py-2">Update Password</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>