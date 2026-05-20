package com.scms.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.scms.util.DBConnection;

@WebServlet("/DowngradeMemberServlet")
public class DowngradeMemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if(request.getSession().getAttribute("user") == null || !"ADMIN".equals(request.getSession().getAttribute("role"))) { 
            response.sendRedirect("login.jsp"); 
            return; 
        }

        String userId = request.getParameter("id");
        String username = request.getParameter("username");
        
        if(userId != null && !userId.trim().isEmpty()) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE users SET tier = 'BASIC' WHERE id = ?")) {
                
                ps.setInt(1, Integer.parseInt(userId));
                int rows = ps.executeUpdate();
                
                if(rows > 0) {
                    request.setAttribute("successMessage", "Player " + username + " has been successfully downgraded to BASIC tier.");
                } else {
                    request.setAttribute("errorMessage", "Could not update player status.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Database error occurred during downgrade.");
            }
        }
        
        request.getRequestDispatcher("manage_members.jsp").forward(request, response);
    }
}