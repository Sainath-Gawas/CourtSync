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

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if(request.getSession().getAttribute("user") == null || !"ADMIN".equals(request.getSession().getAttribute("role"))) { 
            response.sendRedirect("login.jsp"); return; 
        }

        String bookingId = request.getParameter("id");
        Connection conn = null;
        PreparedStatement ps = null;
        
        if(bookingId != null && !bookingId.trim().isEmpty()) {
            try {
                conn = DBConnection.getConnection();
                // REVERTED TO STANDARD ID
                ps = conn.prepareStatement("DELETE FROM bookings WHERE id = ?");
                ps.setInt(1, Integer.parseInt(bookingId));
                
                int rowsAffected = ps.executeUpdate();
                
                if(rowsAffected > 0) request.setAttribute("successMessage", "Booking successfully cancelled and cleared from the radar.");
                else request.setAttribute("errorMessage", "Could not find that booking to cancel.");
                
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Database error while trying to cancel booking.");
            } finally {
                try { if(ps != null) ps.close(); } catch(Exception e) {}
                try { if(conn != null) conn.close(); } catch(Exception e) {}
            }
        }
        
        request.getRequestDispatcher("manage_bookings.jsp").forward(request, response);
    }
}