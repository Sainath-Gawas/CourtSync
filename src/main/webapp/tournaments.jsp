<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Tournaments</title>
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
        /* UNIFIED NAVBAR & PADDING STYLES */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; justify-content: flex-end; align-items: center; }
        .content-padding { padding: 30px; }
        /* TOURNAMENT CARD STYLES */
        .tournament-card { border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); background: #fff; transition: 0.3s; }
        .tournament-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        .card-img-top { height: 120px; background: linear-gradient(135deg, #1a2b4c 0%, #2a3f6c 100%); display:flex; align-items:center; justify-content:center; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <div class="px-3 mb-2 mt-2 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Menu</div>
        <a href="member_dashboard.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="book_court.jsp"><i class="far fa-calendar-plus"></i> Book a Court</a>
        <a href="my_bookings.jsp"><i class="fas fa-history"></i> My Bookings</a>
        <a href="tournaments.jsp" class="active"><i class="fas fa-trophy"></i> Tournaments</a>
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
            <h4 class="fw-bold mb-4"><i class="fas fa-trophy me-2 text-warning"></i> Upcoming Tournaments</h4>
            
            <% if(request.getAttribute("successMessage") != null) { %> <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i><%= request.getAttribute("successMessage") %></div> <% } %>
            <% if(request.getAttribute("errorMessage") != null) { %> <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i><%= request.getAttribute("errorMessage") %></div> <% } %>

            <div class="row g-4">
                <%
                    try (Connection conn = DBConnection.getConnection(); 
                         Statement st = conn.createStatement(); 
                         // Only show events happening today or in the future
                         ResultSet rs = st.executeQuery("SELECT * FROM tournaments WHERE event_date >= date('now') ORDER BY event_date ASC")) {
                        
                        boolean hasUpcoming = false;
                        while(rs.next()){
                            hasUpcoming = true;
                            String feeDisplay = rs.getDouble("entry_fee") == 0 ? "FREE" : "₹" + rs.getDouble("entry_fee");
                %>
                        <div class="col-md-4">
                            <div class="tournament-card h-100 d-flex flex-column">
                                <div class="card-img-top"><i class="fas fa-trophy fa-3x text-white opacity-50"></i></div>
                                <div class="p-4 d-flex flex-column flex-grow-1">
                                    <span class="badge bg-dark mb-2 align-self-start"><%= rs.getString("sport") %></span>
                                    <h5 class="fw-bold mb-2"><%= rs.getString("title") %></h5>
                                    <p class="text-muted small mb-3"><%= rs.getString("description") %></p>
                                    <div class="mt-auto d-flex justify-content-between align-items-center mb-3">
                                        <span class="text-dark small fw-bold"><i class="far fa-calendar-alt text-muted me-1"></i> <%= rs.getString("event_date") %></span>
                                        <span class="text-success fw-bold"><%= feeDisplay %></span>
                                    </div>
                                    <form action="JoinTournamentServlet" method="POST" class="m-0 w-100">
                                        <input type="hidden" name="title" value="<%= rs.getString("title") %>">
                                        <input type="hidden" name="event_date" value="<%= rs.getString("event_date") %>">
                                        <input type="hidden" name="entry_fee" value="<%= rs.getDouble("entry_fee") %>">
                                        <button type="submit" class="btn w-100 py-2 fw-medium" style="background:#1a2b4c; color:white;">Register Now</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                <%      
                        }
                        if(!hasUpcoming) {
                            out.println("<div class='col-12'><div class='alert alert-light text-center py-5 text-muted border'>No upcoming tournaments at the moment. Check back soon!</div></div>");
                        }
                    } catch(Exception e) { e.printStackTrace(); }
                %>
            </div>
        </div>
    </div>
</body>
</html>