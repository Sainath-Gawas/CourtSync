<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    if(currentUser == null || !"ADMIN".equals(currentRole)) { response.sendRedirect("login.jsp"); return; }
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
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; justify-content: space-between; align-items: center; }
        .content-padding { padding: 30px; }
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; height: 100%; }
        /* Grey out rows for past events */
        .table-past-event td { opacity: 0.6; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp" class="active"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Tournament Management</h5>
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <h4 class="section-title fw-bold mb-4"><i class="fas fa-trophy text-warning me-2"></i> Event & Tournament Manager</h4>
            
            <% if(request.getAttribute("successMessage") != null) { %> <div class="alert alert-success mb-4"><i class="fas fa-check-circle me-2"></i><%= request.getAttribute("successMessage") %></div> <% } %>
            <% if(request.getAttribute("errorMessage") != null) { %> <div class="alert alert-danger mb-4"><i class="fas fa-exclamation-triangle me-2"></i><%= request.getAttribute("errorMessage") %></div> <% } %>
            
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="scms-card">
                        <h6 class="fw-bold mb-3">Create New Event</h6>
                        <form action="CreateTournamentServlet" method="POST">
                            <div class="mb-3"><input type="text" name="title" class="form-control" placeholder="Event Title" required></div>
                            <div class="mb-3">
                                <select name="sport" class="form-select" required>
                                    <option value="Tennis">Tennis</option>
                                    <option value="Badminton">Badminton</option>
                                    <option value="Table Tennis">Table Tennis</option>
                                </select>
                            </div>
                            <div class="mb-3"><input type="date" name="event_date" class="form-control" required></div>
                            <div class="mb-3"><input type="number" name="entry_fee" class="form-control" placeholder="Entry Fee (₹) - 0 for Free" required></div>
                            <div class="mb-3"><textarea name="description" class="form-control" rows="3" placeholder="Short description..." required></textarea></div>
                            <button type="submit" class="btn w-100 fw-bold" style="background:#1a2b4c; color:white;">Publish Tournament</button>
                        </form>
                    </div>
                </div>
                
                <div class="col-md-8">
                    
                    <div class="scms-card mb-4">
                        <h6 class="fw-bold mb-3 text-success"><i class="fas fa-play-circle me-2"></i> Upcoming & Active Events</h6>
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead class="table-light"><tr><th>Event Details</th><th>Event Date</th><th>Entry Fee</th><th>Status</th><th class="text-end">Action</th></tr></thead>
                                <tbody>
                                    <%
                                        try (Connection conn = DBConnection.getConnection(); 
                                             Statement st = conn.createStatement(); 
                                             ResultSet rs = st.executeQuery("SELECT * FROM tournaments WHERE event_date >= date('now') ORDER BY event_date ASC")) {
                                            
                                            boolean hasUpcoming = false;
                                            while(rs.next()){
                                                hasUpcoming = true;
                                                // Escaping single quotes in title to prevent JavaScript errors
                                                String safeTitle = rs.getString("title").replace("'", "\\'");
                                    %>
                                            <tr>
                                                <td class="fw-bold"><%= rs.getString("title") %> <br><small class="text-muted"><%= rs.getString("sport") %></small></td>
                                                <td><i class="far fa-calendar-alt text-muted me-1"></i> <%= rs.getString("event_date") %></td>
                                                <td class="text-success fw-bold"><%= rs.getDouble("entry_fee") == 0 ? "FREE" : "₹" + rs.getDouble("entry_fee") %></td>
                                                <td><span class="badge bg-primary bg-opacity-10 text-primary border border-primary px-2 py-1">REGISTRATION OPEN</span></td>
                                                <td class="text-end">
                                                    <button type="button" class="btn btn-sm btn-outline-danger" onclick="openDeleteModal('<%= rs.getInt("id") %>', '<%= safeTitle %>')">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                    <%      }
                                            if(!hasUpcoming) { out.println("<tr><td colspan='5' class='text-center text-muted py-3 small'>No upcoming events scheduled.</td></tr>"); }
                                        } catch(Exception e) { e.printStackTrace(); }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="scms-card">
                        <h6 class="fw-bold mb-3 text-secondary"><i class="fas fa-history me-2"></i> Event History</h6>
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead class="table-light"><tr><th>Event Details</th><th>Event Date</th><th>Entry Fee</th><th>Status</th><th class="text-end">Action</th></tr></thead>
                                <tbody>
                                    <%
                                        try (Connection conn = DBConnection.getConnection(); 
                                             Statement st = conn.createStatement(); 
                                             ResultSet rs = st.executeQuery("SELECT * FROM tournaments WHERE event_date < date('now') ORDER BY event_date DESC")) {
                                            
                                            boolean hasPast = false;
                                            while(rs.next()){
                                                hasPast = true;
                                                String safeTitle = rs.getString("title").replace("'", "\\'");
                                    %>
                                            <tr class="table-past-event">
                                                <td class="fw-bold"><%= rs.getString("title") %> <br><small class="text-muted"><%= rs.getString("sport") %></small></td>
                                                <td><i class="far fa-calendar-check text-muted me-1"></i> <%= rs.getString("event_date") %></td>
                                                <td class="fw-bold"><%= rs.getDouble("entry_fee") == 0 ? "FREE" : "₹" + rs.getDouble("entry_fee") %></td>
                                                <td><span class="badge bg-secondary px-2 py-1">COMPLETED</span></td>
                                                <td class="text-end">
                                                    <button type="button" class="btn btn-sm btn-outline-danger" onclick="openDeleteModal('<%= rs.getInt("id") %>', '<%= safeTitle %>')">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                    <%      }
                                            if(!hasPast) { out.println("<tr><td colspan='5' class='text-center text-muted py-3 small'>No past events found.</td></tr>"); }
                                        } catch(Exception e) { e.printStackTrace(); }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-danger text-white border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-exclamation-triangle me-2"></i> Confirm Cancellation</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <p class="mb-0 fs-5">Are you sure you want to permanently delete the tournament <br><strong id="displayDeleteTitle" class="text-dark mt-2 d-block"></strong></p>
                    <p class="text-danger small mt-3 fw-bold">This action will remove it from the schedule. Cannot be undone.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmDeleteBtn" class="btn btn-danger fw-bold px-4">Delete Tournament</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function openDeleteModal(tournamentId, title) {
            // Inject the exact tournament title into the modal text
            document.getElementById('displayDeleteTitle').innerText = title;
            // Update the button link to point to the backend with the correct ID
            document.getElementById('confirmDeleteBtn').href = "DeleteTournamentServlet?id=" + tournamentId;
            // Trigger the modal to show
            var myModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            myModal.show();
        }
    </script>
</body>
</html>