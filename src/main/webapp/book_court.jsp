<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.scms.util.DBConnection" %>
<%
    String currentUser = (String) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    
    if(currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    //PRICING LOGIC
    String userTier = "BASIC";
    try (Connection conn = DBConnection.getConnection(); 
         PreparedStatement ps = conn.prepareStatement("SELECT tier FROM users WHERE username=?")) {
        ps.setString(1, currentUser);
        ResultSet rs = ps.executeQuery();
        if(rs.next() && rs.getString("tier") != null) userTier = rs.getString("tier");
    } catch(Exception e) { e.printStackTrace(); }

    String tennisPrice = "PRO".equals(userTier) ? "₹200" : "₹500";
    String badmPrice = "PRO".equals(userTier) ? "₹100" : "₹300";
    String ttPrice = "PRO".equals(userTier) ? "FREE" : "₹200";

    // FETCH FUTURE BOOKINGS FOR THE BLOCKER
    StringBuilder bookedSlots = new StringBuilder("[");
    try(Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT booking_date, court_name, time_slot FROM bookings WHERE booking_date >= date('now', 'localtime') AND status != 'CANCELLED'");
        ResultSet rs = ps.executeQuery()) {
        
        while(rs.next()) {
            bookedSlots.append("{date: '").append(rs.getString("booking_date"))
                       .append("', court: '").append(rs.getString("court_name"))
                       .append("', time: '").append(rs.getString("time_slot")).append("'},");
        }
        if(bookedSlots.length() > 1) bookedSlots.setLength(bookedSlots.length() - 1);
    } catch(Exception e) { e.printStackTrace(); }
    bookedSlots.append("]");
    
    // Get today's date to restrict the date picker from selecting past days
    String todayStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Book a Court</title>
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
        <div class="px-3 mb-2 mt-2 text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 1px;">Menu</div>
        <a href="member_dashboard.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="book_court.jsp" class="active"><i class="far fa-calendar-plus"></i> Book a Court</a>
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
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    
                    <h4 class="fw-bold mb-4"><i class="far fa-calendar-plus me-2 text-primary"></i> Reserve a Court</h4>

                    <div class="alert alert-info py-2 small shadow-sm border-0 bg-white border-start border-4 border-info">
                        <i class="fas fa-info-circle text-info me-2"></i> You are booking as a <strong><%= userTier %></strong> member. Prices below reflect your active tier benefits.
                    </div>

                    <% if(request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("errorMessage") %></div>
                    <% } %>
                    <% if(request.getAttribute("successMessage") != null) { %>
                        <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i> <%= request.getAttribute("successMessage") %></div>
                    <% } %>

                    <div class="scms-card">
                        <form action="BookCourtServlet" method="POST">
                            
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-muted small">Select Court</label>
                                    <select name="court_name" id="courtSelect" class="form-select" required>
                                        <option value="" disabled selected>-- Choose Facility --</option>
                                        <optgroup label="Tennis (<%= tennisPrice %> / hour)">
                                            <option value="Tennis - Court 1 (Clay)">Tennis - Court 1 (Clay)</option>
                                            <option value="Tennis - Court 2 (Grass)">Tennis - Court 2 (Grass)</option>
                                        </optgroup>
                                        <optgroup label="Badminton (<%= badmPrice %> / hour)">
                                            <option value="Badminton - Court 1 (Indoor)">Badminton - Court 1 (Indoor)</option>
                                            <option value="Badminton - Court 2 (Indoor)">Badminton - Court 2 (Indoor)</option>
                                        </optgroup>
                                        <optgroup label="Table Tennis (<%= ttPrice %> / hour)">
                                            <option value="Table Tennis - Table 1">Table Tennis - Table 1</option>
                                            <option value="Table Tennis - Table 2">Table Tennis - Table 2</option>
                                        </optgroup>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-muted small">Select Date</label>
                                    <input type="date" name="booking_date" id="dateInput" class="form-control" min="<%= todayStr %>" required>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-bold text-muted small">Available Time Slots</label>
                                    <select name="time_slot" id="timeSelect" class="form-select" required disabled>
                                        <option value="" disabled selected>-- Select Court & Date First --</option>
                                        <option value="05:00 PM - 06:00 PM">05:00 PM - 06:00 PM</option>
                                        <option value="06:00 PM - 07:00 PM">06:00 PM - 07:00 PM</option>
                                        <option value="07:00 PM - 08:00 PM">07:00 PM - 08:00 PM</option>
                                        <option value="08:00 PM - 09:00 PM">08:00 PM - 09:00 PM</option>
                                    </select>
                                    <small id="slotHelper" class="text-muted d-block mt-1" style="font-size: 0.75rem;">Pick a court and date to see live availability.</small>
                                </div>
                            </div>

                            <hr class="my-4 text-muted opacity-25">
                            
                            <button type="submit" class="btn btn-brand w-100 py-3 fw-bold fs-5">Confirm Reservation</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Data injected directly from Java backend
        const bookedData = <%= bookedSlots.toString() %>;
        
        const courtSelect = document.getElementById('courtSelect');
        const dateInput = document.getElementById('dateInput');
        const timeSelect = document.getElementById('timeSelect');
        const slotHelper = document.getElementById('slotHelper');

        function checkAvailability() {
            const selectedCourt = courtSelect.value;
            const selectedDate = dateInput.value;

            //if they haven't picked both
            if(!selectedCourt || !selectedDate) {
                timeSelect.disabled = true;
                return;
            }

            // Enable the dropdown
            timeSelect.disabled = false;
            slotHelper.innerHTML = "<span class='text-success'><i class='fas fa-circle ms-1' style='font-size: 8px;'></i> Live availability loaded.</span>";

            // Find all times that are already booked for this specific court and date
            const takenSlots = bookedData
                .filter(b => b.court === selectedCourt && b.date === selectedDate)
                .map(b => b.time);

            // Loop through the dropdown options and disable the taken ones
            let availableCount = 0;
            Array.from(timeSelect.options).forEach(opt => {
                if(opt.value === "") return;

                if(takenSlots.includes(opt.value) || takenSlots.includes("All Day")) {
                    opt.disabled = true;
                    opt.text = opt.value + " (Booked)";
                    opt.style.color = "#dc3545"; // Make it red so it's obvious
                } else {
                    opt.disabled = false;
                    opt.text = opt.value;
                    opt.style.color = "#212529";
                    availableCount++;
                }
            });

            // Auto-select the first available slot for better UX
            for (let i = 0; i < timeSelect.options.length; i++) {
                if (!timeSelect.options[i].disabled && timeSelect.options[i].value !== "") {
                    timeSelect.selectedIndex = i;
                    break;
                }
            }

            // If completely booked out
            if(availableCount === 0) {
                timeSelect.selectedIndex = 0;
                slotHelper.innerHTML = "<span class='text-danger fw-bold'><i class='fas fa-exclamation-circle me-1'></i> Fully Booked! Please choose another date or court.</span>";
            }
        }

        courtSelect.addEventListener('change', checkAvailability);
        dateInput.addEventListener('change', checkAvailability);
    </script>
</body>
</html>