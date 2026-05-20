<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.scms.util.DBConnection" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeParseException" %>
<%
    try (Connection c = DBConnection.getConnection(); Statement s = c.createStatement()) {
        ResultSet rsCol = s.executeQuery("PRAGMA table_info(bookings)");
        boolean hasId = false;
        while(rsCol.next()) { if("id".equals(rsCol.getString("name"))) hasId = true; }
        
        if(!hasId) {
            s.execute("CREATE TABLE new_bookings (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, court_name TEXT, booking_date TEXT, time_slot TEXT, status TEXT)");
            s.execute("INSERT INTO new_bookings (username, court_name, booking_date, time_slot, status) SELECT username, court_name, booking_date, time_slot, status FROM bookings");
            s.execute("DROP TABLE bookings");
            s.execute("ALTER TABLE new_bookings RENAME TO bookings");
        }
    } catch(Exception e) { e.printStackTrace(); }

    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; }
    
    // Capture today's date for historical greying out
    LocalDate today = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Master Schedule</title>
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
        .scms-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; margin-bottom: 30px; }
        
        /* CSS for historical records */
        .past-record { opacity: 0.55; background-color: #f8f9fa; }
        .past-record:hover { opacity: 0.8; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp" class="active"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Master Booking Directory</h5>
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="section-title fw-bold mb-0"><i class="far fa-calendar-check me-2 text-primary"></i> Master Booking Schedule</h4>
                <a href="admin_book_court.jsp" class="btn btn-outline-primary fw-bold"><i class="fas fa-plus me-2"></i> Book for Walk-in</a>
            </div>

            <% if(request.getAttribute("successMessage") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i><%= request.getAttribute("successMessage") %></div><% } %>
            <% if(request.getAttribute("errorMessage") != null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i><%= request.getAttribute("errorMessage") %></div><% } %>

            <div class="scms-card">
                <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-3">
                    <h5 class="fw-bold mb-0 text-dark"><i class="fas fa-table-tennis text-primary me-2"></i> Daily Court Rentals</h5>
                    <div class="d-flex align-items-center gap-2">
                        <label class="small fw-bold text-muted text-nowrap mb-0">Filter Sport:</label>
                        <select id="courtFilter" class="form-select form-select-sm" style="width: 180px;" onchange="filterTables('courtFilter', 'court-row', 'data-sport')">
                            <option value="ALL">All Facilities</option>
                            <option value="Tennis">Tennis</option>
                            <option value="Badminton">Badminton</option>
                            <option value="Table Tennis">Table Tennis</option>
                        </select>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead class="table-light">
                            <tr><th>Date & Time</th><th>Court Name</th><th>Player Username</th><th>Status</th><th class="text-end">Action</th></tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn1 = null; PreparedStatement ps1 = null; ResultSet rs1 = null;
                                try {
                                    conn1 = DBConnection.getConnection();
                                    String sql1 = "SELECT id, username, court_name, booking_date, time_slot, status FROM bookings WHERE court_name NOT LIKE 'Event - %' ORDER BY booking_date DESC, id DESC";
                                    ps1 = conn1.prepareStatement(sql1);
                                    rs1 = ps1.executeQuery();
                                    
                                    boolean hasRentals = false;
                                    while(rs1.next()) { 
                                        hasRentals = true;
                                        String bDateStr = rs1.getString("booking_date");
                                        String courtName = rs1.getString("court_name");
                                        String username = rs1.getString("username");
                                        
                                        //to determine if booking is in the past
                                        boolean isPast = false;
                                        try {
                                            LocalDate bDate = LocalDate.parse(bDateStr);
                                            isPast = bDate.isBefore(today);
                                        } catch(Exception e) { /* Ignore parsing errors for legacy data */ }
                                        
                                        String rowClass = isPast ? "past-record court-row" : "court-row";
                            %>
                                    <tr class="<%= rowClass %>" data-sport="<%= courtName %>">
                                        <td class="fw-bold"><%= bDateStr %> <span class="text-muted small ms-2"><i class="far fa-clock"></i> <%= rs1.getString("time_slot") %></span></td>
                                        <td><%= courtName %></td>
                                        <td><img src="https://ui-avatars.com/api/?name=<%= username %>&size=24&background=E5E7EB&color=374151" class="rounded-circle me-2"><%= username %></td>
                                        <td>
                                            <% if(isPast) { %> <span class="badge bg-secondary">Completed</span> <% } else { %> <span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1"><%= rs1.getString("status") %></span> <% } %>
                                        </td>
                                        <td class="text-end">
                                            <% if(isPast) { %>
                                                <button class="btn btn-sm btn-light text-muted border" disabled><i class="fas fa-lock"></i> Locked</button>
                                            <% } else { %>
                                                <button type="button" class="btn btn-sm btn-outline-danger fw-bold" onclick="openCancelModal('<%= rs1.getInt("id") %>', 'Permanently drop this booking for <b class=\'text-dark\'><%= username %></b>?')">
                                                    <i class="fas fa-trash-alt me-1"></i> Cancel
                                                </button>
                                            <% } %>
                                        </td>
                                    </tr>
                            <% 
                                    }
                                    if(!hasRentals) out.println("<tr><td colspan='5' class='text-center text-muted py-4 small'>No active court rentals recorded.</td></tr>");
                                } catch(Exception e) { e.printStackTrace(); } 
                                finally { if(rs1 != null) try { rs1.close(); } catch(Exception e){} if(ps1 != null) try { ps1.close(); } catch(Exception e){} if(conn1 != null) try { conn1.close(); } catch(Exception e){} }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="scms-card">
                <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-3">
                    <h5 class="fw-bold mb-0 text-warning"><i class="fas fa-users me-2 text-warning"></i> Community Event Sign-ups</h5>
                    <div class="d-flex align-items-center gap-2">
                        <label class="small fw-bold text-muted text-nowrap mb-0">Filter Event:</label>
                        <select id="eventFilter" class="form-select form-select-sm" style="width: 220px;" onchange="filterTables('eventFilter', 'event-row', 'data-event')">
                            <option value="ALL">All Tournaments</option>
                            <%
                                try (Connection cDrop = DBConnection.getConnection(); Statement sDrop = cDrop.createStatement();
                                     ResultSet rsDrop = sDrop.executeQuery("SELECT DISTINCT court_name FROM bookings WHERE court_name LIKE 'Event - %'")) {
                                    while(rsDrop.next()) {
                                        String cleanName = rsDrop.getString("court_name").replace("Event - ", "");
                                        out.println("<option value='" + cleanName + "'>" + cleanName + "</option>");
                                    }
                                } catch(Exception e) {}
                            %>
                        </select>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead class="table-light">
                            <tr><th>Event Context</th><th>Event Date</th><th>Player Username</th><th>Status</th><th class="text-end">Action</th></tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn2 = null; PreparedStatement ps2 = null; ResultSet rs2 = null;
                                try {
                                    conn2 = DBConnection.getConnection();
                                    String sql2 = "SELECT id, username, court_name, booking_date, time_slot, status FROM bookings WHERE court_name LIKE 'Event - %' ORDER BY booking_date DESC, id DESC";
                                    ps2 = conn2.prepareStatement(sql2);
                                    rs2 = ps2.executeQuery();
                                    
                                    boolean hasEvents = false;
                                    while(rs2.next()) { 
                                        hasEvents = true;
                                        String bDateStr = rs2.getString("booking_date");
                                        String fullEventName = rs2.getString("court_name").replace("Event - ", "");
                                        String username = rs2.getString("username");
                                        
                                        boolean isPast = false;
                                        try {
                                            LocalDate bDate = LocalDate.parse(bDateStr);
                                            isPast = bDate.isBefore(today);
                                        } catch(Exception e) { }
                                        
                                        String rowClass = isPast ? "past-record event-row" : "event-row";
                            %>
                                    <tr class="<%= rowClass %>" data-event="<%= fullEventName %>">
                                        <td class="fw-bold text-dark"><%= fullEventName %></td>
                                        <td><i class="far fa-calendar-alt text-muted me-1"></i> <%= bDateStr %></td>
                                        <td><img src="https://ui-avatars.com/api/?name=<%= username %>&size=24&background=fef3c7&color=92400e" class="rounded-circle me-2"><%= username %></td>
                                        <td>
                                            <% if(isPast) { %> <span class="badge bg-secondary">Concluded</span> <% } else { %> <span class="badge bg-warning bg-opacity-10 text-warning border border-warning px-2 py-1 text-dark">Signed Up</span> <% } %>
                                        </td>
                                        <td class="text-end">
                                            <% if(isPast) { %>
                                                <button class="btn btn-sm btn-light text-muted border" disabled><i class="fas fa-lock"></i> Locked</button>
                                            <% } else { %>
                                                <button type="button" class="btn btn-sm btn-outline-danger fw-bold" onclick="openCancelModal('<%= rs2.getInt("id") %>', 'Remove <b class=\'text-dark\'><%= username %></b> from this event roster?')">
                                                    <i class="fas fa-trash-alt me-1"></i> Remove
                                                </button>
                                            <% } %>
                                        </td>
                                    </tr>
                            <% 
                                    }
                                    if(!hasEvents) out.println("<tr><td colspan='5' class='text-center text-muted py-4 small'>No community event registrations found.</td></tr>");
                                } catch(Exception e) { e.printStackTrace(); } 
                                finally { if(rs2 != null) try { rs2.close(); } catch(Exception e){} if(ps2 != null) try { ps2.close(); } catch(Exception e){} if(conn2 != null) try { conn2.close(); } catch(Exception e){} }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            
        </div>
    </div>

    <div class="modal fade" id="cancelConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-danger text-white border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-exclamation-triangle me-2"></i> Confirm Action</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <p class="mb-0 fs-5 text-muted" id="cancelModalText"></p>
                    <p class="text-danger small mt-3 fw-bold">This action cannot be undone.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Go Back</button>
                    <a href="#" id="confirmCancelBtn" class="btn btn-danger fw-bold px-4">Confirm</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // Dropdown Filtering Logic
        function filterTables(dropdownId, rowClassName, dataAttributeName) {
            const selectedValue = document.getElementById(dropdownId).value;
            const rows = document.getElementsByClassName(rowClassName);

            for (let row of rows) {
                const rowData = row.getAttribute(dataAttributeName);
                if (selectedValue === "ALL" || rowData.includes(selectedValue)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            }
        }

        // Modal Injection Logic
        function openCancelModal(bookingId, contextText) {
            // Inject the dynamic message (e.g. "Cancel booking for Raj?")
            document.getElementById('cancelModalText').innerHTML = contextText;
            // Point the confirmation button to the backend servlet
            document.getElementById('confirmCancelBtn').href = "CancelBookingServlet?id=" + bookingId;
            // Show the modal
            var myModal = new bootstrap.Modal(document.getElementById('cancelConfirmModal'));
            myModal.show();
        }
    </script>
</body>
</html>