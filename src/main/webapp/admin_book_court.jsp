<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
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
    <title>CourtSync - Admin Court Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .booking-card { background: #fff; border-radius: 12px; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .btn-brand { background-color: #1a2b4c; color: white; transition: 0.3s; }
        .btn-brand:hover { background-color: #2a3f6c; color: white; }
    </style>
</head>
<body>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            
            <div class="d-flex align-items-center justify-content-between mb-4">
                <h3 class="fw-bold text-dark mb-0"><i class="far fa-calendar-plus me-2 text-primary"></i> Walk-In Booking</h3>
                <a href="manage_bookings.jsp" class="btn btn-outline-secondary btn-sm">Back to Schedule</a>
            </div>

            <% if(request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger"><%= request.getAttribute("errorMessage") %></div>
            <% } %>
            <% if(request.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success"><%= request.getAttribute("successMessage") %></div>
            <% } %>

            <div class="card booking-card p-4">
                <form action="AdminBookCourtServlet" method="POST">
                    
                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Member Username</label>
                        <input type="text" name="target_member" class="form-control" placeholder="e.g., Rahul" required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Select Court</label>
                        <select name="court_name" id="courtSelect" class="form-select" required>
    <option value="" disabled selected>-- Choose Facility --</option>
    <optgroup label="Tennis">
        <option value="Tennis - Court 1 (Clay)">Tennis - Court 1 (Clay)</option>
        <option value="Tennis - Court 2 (Grass)">Tennis - Court 2 (Grass)</option>
    </optgroup>
    <optgroup label="Badminton">
        <option value="Badminton - Court 1 (Indoor)">Badminton - Court 1 (Indoor)</option>
        <option value="Badminton - Court 2 (Indoor)">Badminton - Court 2 (Indoor)</option>
    </optgroup>
    <optgroup label="Table Tennis">
        <option value="Table Tennis - Table 1">Table Tennis - Table 1</option>
        <option value="Table Tennis - Table 2">Table Tennis - Table 2</option>
    </optgroup>
</select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Date</label>
                        <input type="date" name="booking_date" class="form-control" required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Time Slot</label>
                        <select name="time_slot" class="form-select" required>
                            <option value="05:00 PM - 06:00 PM">05:00 PM - 06:00 PM</option>
                            <option value="06:00 PM - 07:00 PM">06:00 PM - 07:00 PM</option>
                            <option value="07:00 PM - 08:00 PM">07:00 PM - 08:00 PM</option>
                            <option value="08:00 PM - 09:00 PM">08:00 PM - 09:00 PM</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-brand w-100 py-2 fw-bold">Process Allocation</button>
                </form>
            </div>
            
        </div>
    </div>
</div>

</body>
</html>