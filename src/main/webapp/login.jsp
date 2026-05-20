<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CourtSync - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        body {
            background-color: #f4f7f6;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .login-card {
            background: #fff;
            border: none;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            width: 100%;
            max-width: 400px;
            padding: 30px;
        }
        .brand-icon {
            color: #1a2b4c;
            font-size: 3rem;
            margin-bottom: 15px;
        }
        .btn-login {
            background-color: #1a2b4c;
            color: white;
            border-radius: 25px;
            padding: 10px;
            font-weight: 500;
            border: none;
            width: 100%;
            transition: 0.3s;
        }
        .btn-login:hover {
            background-color: #2a3f6c;
            color: white;
        }
        /* Added smooth transition for the fade-out effect */
        .alert-message {
            transition: opacity 0.5s ease-out;
        }
    </style>
</head>
<body>

    <div class="login-card text-center">
        <div class="brand-icon">
            <i class="fas fa-table-tennis"></i>
        </div>
        <h4 class="fw-bold mb-1" style="color: #1a2b4c;">CourtSync</h4>
        <p class="text-muted small mb-4">SmashPoint Academy Management</p>
        
        <% if(request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger p-2 small alert-message" id="statusMessage" role="alert">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <% if(request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success p-2 small alert-message" id="statusMessage" role="alert">
                <i class="fas fa-check-circle me-1"></i> <%= request.getAttribute("successMessage") %>
            </div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="mb-3 text-start">
                <label class="form-label small fw-medium text-muted">Username</label>
                <input type="text" name="username" class="form-control" placeholder="Enter username" required>
            </div>
            
            <div class="mb-3 text-start">
                <label class="form-label small fw-medium text-muted">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Enter password" required>
            </div>
            
            <div class="mb-4 text-start">
                <label class="form-label small fw-medium text-muted">Role</label>
                <select name="role" class="form-select">
                    <option value="ADMIN">Admin</option>
                    <option value="MEMBER">Member</option>
                </select>
            </div>
            <button type="submit" class="btn btn-login">Sign In</button>
        </form>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const messageBox = document.getElementById("statusMessage");
            if (messageBox) {
                // Wait 3 seconds, then start fading out
                setTimeout(function() {
                    messageBox.style.opacity = "0";
                    // After the 0.5s fade animation, completely remove it from the layout
                    setTimeout(function() {
                        messageBox.style.display = "none";
                    }, 500); 
                }, 3000);
            }
        });
    </script>
</body>
</html>