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

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String currentUser = (String) session.getAttribute("user");
        
        if(currentUser == null || !"MEMBER".equals(session.getAttribute("role"))) { 
            response.sendRedirect("login.jsp"); 
            return; 
        }

        String oldPass = request.getParameter("old_password");
        String newPass = request.getParameter("new_password");
        
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement verifyPs = conn.prepareStatement("SELECT password FROM users WHERE username = ?");
            verifyPs.setString(1, currentUser);
            ResultSet rs = verifyPs.executeQuery();
            
            if(rs.next() && rs.getString("password").equals(oldPass)) {
                PreparedStatement updatePs = conn.prepareStatement("UPDATE users SET password = ? WHERE username = ?");
                updatePs.setString(1, newPass);
                updatePs.setString(2, currentUser);
                updatePs.executeUpdate();
                
                request.setAttribute("successMessage", "Password updated successfully! Use this on your next login.");
            } else {
                request.setAttribute("errorMessage", "Incorrect current password. Verification failed.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "A system database error occurred.");
        }
        
        // THE FIX: Changed from "member_profile.jsp" to "profile.jsp"
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}