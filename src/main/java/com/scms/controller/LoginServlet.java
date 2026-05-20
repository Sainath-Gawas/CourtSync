package com.scms.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.scms.util.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String inputUser = request.getParameter("username");
        String inputPass = request.getParameter("password");
        String inputRole = request.getParameter("role");
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Verify if the exact username, password, AND role match the database
            String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND role = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, inputUser);
            ps.setString(2, inputPass);
            ps.setString(3, inputRole);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // SUCCESS: Create a session to remember who logged in
                HttpSession session = request.getSession();
                session.setAttribute("user", inputUser);
                session.setAttribute("role", inputRole);
                
                // --- THE TRAFFIC COP (ROLE-BASED ROUTING) ---
                if ("ADMIN".equals(inputRole)) {
                    // Admins go to the back-office
                    response.sendRedirect("admin_dashboard.jsp");
                } else if ("MEMBER".equals(inputRole)) {
                    // Members/Players go to their personal portal
                    response.sendRedirect("member_dashboard.jsp");
                }
                
            } else {
                // FAILURE: Send them back to login with an error message
                request.setAttribute("errorMessage", "Invalid Username, Password, or Role.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error occurred.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            // Clean up resources
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}