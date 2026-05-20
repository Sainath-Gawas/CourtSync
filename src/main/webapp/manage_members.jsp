<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.scms.util.DBConnection" %>
<%
    // Security check Only Admins allowed
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
    <title>CourtSync - Manage Members</title>
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
        .btn-brand { background-color: #1a2b4c; color: white; border-radius: 8px; transition: 0.3s; }
        .btn-brand:hover { background-color: #2a3f6c; color: white; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand"><i class="fas fa-table-tennis me-2"></i> CourtSync</div>
        <a href="admin_dashboard.jsp"><i class="fas fa-th-large"></i> Dashboard</a>
        <a href="manage_members.jsp" class="active"><i class="far fa-user"></i> Members</a>
        <a href="manage_bookings.jsp"><i class="far fa-calendar-alt"></i> Bookings</a>
        <a href="manage_tournaments.jsp"><i class="fas fa-trophy"></i> Tournaments</a>
        <a href="manage_payments.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a>
        <a href="manage_equipment.jsp"><i class="fas fa-dumbbell"></i> Equipment</a>
        <a href="post_announcement.jsp"><i class="fas fa-bullhorn"></i> Announcements</a>
        <a href="reports.jsp"><i class="far fa-file-alt"></i> Reports</a>
        <a href="LogoutServlet" class="mt-4 text-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main-content">
        <div class="top-navbar">
            <div class="fw-bold text-muted">Admin Portal</div> 
            <div class="d-flex align-items-center">
                <i class="far fa-bell text-muted me-4 fs-5"></i>
                <div class="d-flex align-items-center select-none">
                    <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=1a2b4c&color=ffffff" class="rounded-circle me-2" width="35" alt="Admin">
                    <span class="fw-medium text-dark"><%= currentUser %></span>
                    <span class="badge bg-danger ms-2 small fw-bold" style="font-size: 0.7rem;">ADMIN</span>
                </div>
            </div>
        </div>

        <div class="content-padding">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="fw-bold mb-0"><i class="fas fa-users me-2 text-primary"></i> Member Directory</h4>
                <button class="btn btn-brand px-4" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                    <i class="fas fa-user-plus me-2"></i> Register New Player
                </button>
            </div>

            <% if(request.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i> <%= request.getAttribute("successMessage") %></div>
            <% } %>
            <% if(request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("errorMessage") %></div>
            <% } %>

            <div class="scms-card">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Player ID</th>
                                <th>Username</th>
                                <th>Membership Tier</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                PreparedStatement ps = null;
                                ResultSet rs = null;
                                
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM users WHERE role = 'MEMBER' ORDER BY id DESC";
                                    ps = conn.prepareStatement(sql);
                                    rs = ps.executeQuery();
                                    
                                    while(rs.next()) {
                                        String tier = rs.getString("tier");
                                        if (tier == null) tier = "BASIC";
                                        
                                        String tierBadge = "PRO".equals(tier) ? "bg-warning text-dark border-warning" : "bg-light text-secondary border-secondary";
                            %>
                                <tr>
                                    <td class="fw-bold text-muted">#<%= rs.getInt("id") %></td>
                                    <td class="fw-bold text-dark">
                                        <img src="https://ui-avatars.com/api/?name=<%= rs.getString("username") %>&size=32&background=E5E7EB&color=374151" class="rounded-circle me-2">
                                        <%= rs.getString("username") %>
                                    </td>
                                    <td><span class="badge <%= tierBadge %> border"><i class="fas <%= "PRO".equals(tier) ? "fa-star" : "fa-user" %> me-1"></i> <%= tier %></span></td>
                                    <td><span class="badge bg-success bg-opacity-10 text-success border border-success rounded-pill px-2">Active</span></td>
                                    <td class="text-end">
                                        
                                        <% if ("BASIC".equals(tier)) { %>
                                            <button type="button" class="btn btn-sm btn-outline-warning fw-bold me-1" onclick="openUpgradeModal('<%= rs.getInt("id") %>', '<%= rs.getString("username") %>')">
                                                <i class="fas fa-arrow-up"></i> Upgrade
                                            </button>
                                        <% } else if ("PRO".equals(tier)) { %>
                                            <button type="button" class="btn btn-sm btn-outline-secondary fw-bold me-1" onclick="openDowngradeModal('<%= rs.getInt("id") %>', '<%= rs.getString("username") %>')">
                                                <i class="fas fa-arrow-down"></i> Downgrade
                                            </button>
                                        <% } %>
                                        
                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="openDeleteModal('<%= rs.getInt("id") %>', '<%= rs.getString("username") %>')">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch(Exception e) { e.printStackTrace(); } 
                                finally {
                                    try { if(rs != null) rs.close(); } catch(Exception e){}
                                    try { if(ps != null) ps.close(); } catch(Exception e){}
                                    try { if(conn != null) conn.close(); } catch(Exception e){}
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <div class="modal fade" id="addMemberModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold"><i class="fas fa-user-plus me-2 text-primary"></i> Register New Player</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="AddUserServlet" method="POST">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold text-muted small">Username</label>
                            <input type="text" name="username" class="form-control" placeholder="Player's display name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-muted small">Temporary Password</label>
                            <input type="password" name="password" class="form-control" placeholder="Provide a starting password" required>
                        </div>
                        <input type="hidden" name="role" value="MEMBER">
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-brand px-4">Save Player</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="upgradeConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-warning text-dark border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-star me-2"></i> Confirm PRO Upgrade</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="display-1 text-warning mb-3"><i class="fas fa-arrow-circle-up"></i></div>
                    <h5 class="fw-bold mb-2">Upgrade <span id="displayUpgradeName" class="text-primary"></span> to PRO?</h5>
                    <p class="text-muted mb-0">This action will automatically charge <strong class="text-dark">₹1,500</strong> to their account ledger.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmUpgradeBtn" class="btn btn-warning fw-bold px-4">Confirm Upgrade</a>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="downgradeConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-secondary text-white border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-user me-2"></i> Revoke PRO Status</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="display-1 text-secondary mb-3"><i class="fas fa-arrow-circle-down"></i></div>
                    <h5 class="fw-bold mb-2">Downgrade <span id="displayDowngradeName" class="text-dark"></span> to BASIC?</h5>
                    <p class="text-muted mb-0">They will lose access to all premium features immediately. No automatic refunds will be issued.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmDowngradeBtn" class="btn btn-secondary fw-bold px-4">Revoke PRO</a>
                </div>
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
                    <p class="mb-0 fs-5">Are you sure you want to permanently delete player <strong id="displayDeleteName"></strong>?</p>
                    <p class="text-danger small mt-2 fw-bold">This action cannot be undone.</p>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-outline-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmDeleteBtn" class="btn btn-danger fw-bold px-4">Delete Player</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function openUpgradeModal(userId, username) {
            document.getElementById('displayUpgradeName').innerText = username;
            document.getElementById('confirmUpgradeBtn').href = "UpgradeMemberServlet?id=" + userId + "&username=" + encodeURIComponent(username);
            var myModal = new bootstrap.Modal(document.getElementById('upgradeConfirmModal'));
            myModal.show();
        }

        function openDowngradeModal(userId, username) {
            document.getElementById('displayDowngradeName').innerText = username;
            document.getElementById('confirmDowngradeBtn').href = "DowngradeMemberServlet?id=" + userId + "&username=" + encodeURIComponent(username);
            var myModal = new bootstrap.Modal(document.getElementById('downgradeConfirmModal'));
            myModal.show();
        }

        function openDeleteModal(userId, username) {
            document.getElementById('displayDeleteName').innerText = username;
            document.getElementById('confirmDeleteBtn').href = "DeleteUserServlet?id=" + userId;
            var myModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            myModal.show();
        }
    </script>
</body>
</html>