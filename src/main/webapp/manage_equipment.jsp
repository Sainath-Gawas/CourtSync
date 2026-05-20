<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.scms.util.DBConnection" %>
<%
 
    try (Connection c = DBConnection.getConnection(); Statement s = c.createStatement()) {
        s.execute("CREATE TABLE IF NOT EXISTS equipment (id INTEGER PRIMARY KEY AUTOINCREMENT, item_name TEXT, total_quantity INTEGER, available_quantity INTEGER, condition TEXT)");
        ResultSet rsCol = s.executeQuery("PRAGMA table_info(equipment)");
        boolean hasPrice = false;
        while(rsCol.next()) { if("rental_price".equals(rsCol.getString("name"))) hasPrice = true; }
        if(!hasPrice) s.execute("ALTER TABLE equipment ADD COLUMN rental_price REAL DEFAULT 30.0");
    } catch(Exception e) { e.printStackTrace(); }

    String currentUser = (String) session.getAttribute("user");
    if(currentUser == null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CourtSync - Equipment Inventory</title>
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
        .equip-icon-box { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .bg-tennis { background-color: #e6f0fa; }
        .bg-badminton { background-color: #f0fdf4; }
        .bg-tt { background-color: #fff1f2; }
        .bg-default { background-color: #f3f4f6; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp" class="active"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    
    <div class="main-content">
        <div class="top-navbar">
            <h5 class="mb-0 text-muted fw-bold">Inventory</h5>
            <div class="d-flex align-items-center">
                <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=E5E7EB&color=374151" class="rounded-circle me-2" width="35" alt="Admin">
                <span class="fw-medium"><%= currentUser %></span>
            </div>
        </div>

        <div class="content-padding">
            <% if(request.getAttribute("successMessage") != null) { %><div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i> <%= request.getAttribute("successMessage") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
            <% if(request.getAttribute("errorMessage") != null) { %><div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("errorMessage") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="section-title fw-bold mb-0"><i class="fas fa-dumbbell me-2 text-warning"></i> Inventory Assets</h4>
                <button class="btn btn-outline-primary btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addStockModal"><i class="fas fa-plus me-1"></i> Add Stock</button>
            </div>
            
            <div class="scms-card">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Item ID</th>
                                <th>Resource Designation</th>
                                <th>Rental Fee</th>
                                <th>Available Stock</th>
                                <th>Condition</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    ps = conn.prepareStatement("SELECT * FROM equipment ORDER BY id DESC");
                                    rs = ps.executeQuery();
                                    boolean hasItems = false;
                                    while(rs.next()){
                                        hasItems = true;
                                        String itemName = rs.getString("item_name");
                                        // Escaping single quotes for JavaScript execution safety
                                        String safeItemName = itemName.replace("'", "\\'");
                                        
                                        String nameLower = itemName.toLowerCase();
                                        String nativeIcon = "📦"; String bgClass = "bg-default";
                                        if (nameLower.contains("tennis") && !nameLower.contains("table")) { nativeIcon = "🎾"; bgClass = "bg-tennis"; } 
                                        else if (nameLower.contains("badminton") || nameLower.contains("shuttle")) { nativeIcon = "🏸"; bgClass = "bg-badminton"; } 
                                        else if (nameLower.contains("table") || nameLower.contains("ping pong")) { nativeIcon = "🏓"; bgClass = "bg-tt"; }
                            %>
                                        <tr>
                                            <td class="text-muted fw-bold small">#EQ-0<%= rs.getInt("id") %></td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="equip-icon-box <%= bgClass %> me-3"><%= nativeIcon %></div>
                                                    <div><h6 class="fw-bold mb-0 text-dark"><%= itemName %></h6></div>
                                                </div>
                                            </td>
                                            <td class="fw-bold text-success">₹<%= String.format("%.0f", rs.getDouble("rental_price")) %></td>
                                            <td>
                                                <% int avail = rs.getInt("available_quantity"); %>
                                                <span class="badge <%= avail > 0 ? "bg-primary" : "bg-danger" %> px-2 py-1 rounded-pill"><%= avail %> / <%= rs.getInt("total_quantity") %> Available</span>
                                            </td>
                                            <td>
                                                <% String condition = rs.getString("condition"); %>
                                                <span class="badge <%= "New".equalsIgnoreCase(condition) || "Good".equalsIgnoreCase(condition) ? "bg-light-success text-success border border-success" : "bg-light-danger text-danger border border-danger" %> px-2 py-1"><%= condition %></span>
                                            </td>
                                            <td class="text-end">
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="openDeleteModal('<%= rs.getInt("id") %>', '<%= safeItemName %>')">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </td>
                                        </tr>
                            <%
                                    }
                                    if(!hasItems) out.println("<tr><td colspan='6' class='text-center py-4 text-muted'>Inventory is currently empty.</td></tr>");
                                } catch(Exception e){ e.printStackTrace(); }
                                finally { if(rs!=null)try{rs.close();}catch(Exception e){} if(ps!=null)try{ps.close();}catch(Exception e){} if(conn!=null)try{conn.close();}catch(Exception e){} }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="addStockModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold"><i class="fas fa-plus-circle text-primary me-2"></i> Add Equipment Stock</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="AddEquipmentServlet" method="POST">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold text-muted small">Item Name</label>
                            <input type="text" name="item_name" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold text-muted small">Quantity</label>
                                <input type="number" name="quantity" class="form-control" min="1" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold text-muted small">Rental Price (₹)</label>
                                <input type="number" name="rental_price" class="form-control" min="0" value="30" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-muted small">Initial Condition</label>
                            <select name="condition" class="form-select" required>
                                <option value="New">New</option><option value="Good">Good</option>
                                <option value="Fair">Fair</option><option value="Needs Replacement">Needs Replacement</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary fw-bold px-4">Save to Inventory</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-danger text-white border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-exclamation-triangle me-2"></i> Confirm Removal</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <p class="mb-0 fs-5">Are you sure you want to completely remove <br><strong id="displayDeleteName" class="text-dark mt-2 d-block"></strong></p>
                    <p class="text-danger small mt-3 fw-bold">This will wipe the asset from the master inventory list. This cannot be undone.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmDeleteBtn" class="btn btn-danger fw-bold px-4">Remove Equipment</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function openDeleteModal(equipId, itemName) {
            document.getElementById('displayDeleteName').innerText = itemName;
            document.getElementById('confirmDeleteBtn').href = "RemoveEquipmentServlet?id=" + equipId;
            var myModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            myModal.show();
        }
    </script>
</body>
</html>