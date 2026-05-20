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
import com.scms.util.DBConnection;

@WebServlet("/AdminBookCourtServlet")
public class AdminBookCourtServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String targetMember = request.getParameter("target_member").trim();
        String courtName = request.getParameter("court_name");
        String bookingDate = request.getParameter("booking_date");
        String timeSlot = request.getParameter("time_slot");
        
        Connection conn = null;
        PreparedStatement vStmt = null, tierStmt = null, checkStmt = null, insertStmt = null, payStmt = null;
        ResultSet vRs = null, tierRs = null, rsCheck = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Lock the transaction
            
            // 1. Verify Member Profile Exists
            vStmt = conn.prepareStatement("SELECT username FROM users WHERE username = ? AND role = 'MEMBER'");
            vStmt.setString(1, targetMember);
            vRs = vStmt.executeQuery();
            
            if (!vRs.next()) {
                request.setAttribute("errorMessage", "Error: Player profile '" + targetMember + "' does not exist.");
                request.getRequestDispatcher("admin_book_court.jsp").forward(request, response);
                return;
            }
            
            // 2. SMART PRICING: Check if the walk-in is a PRO or Basic member
            String tier = "BASIC";
            tierStmt = conn.prepareStatement("SELECT tier FROM users WHERE username = ?");
            tierStmt.setString(1, targetMember);
            tierRs = tierStmt.executeQuery();
            if (tierRs.next() && tierRs.getString("tier") != null) tier = tierRs.getString("tier");

            double price = 0.0;
            if (courtName.contains("Tennis") && !courtName.contains("Table")) price = "PRO".equals(tier) ? 200.0 : 500.0;
            else if (courtName.contains("Badminton")) price = "PRO".equals(tier) ? 100.0 : 300.0;
            else if (courtName.contains("Table Tennis")) price = "PRO".equals(tier) ? 0.0 : 200.0;
            
            // 3. Collision Check
            checkStmt = conn.prepareStatement("SELECT * FROM bookings WHERE court_name = ? AND booking_date = ? AND time_slot = ?");
            checkStmt.setString(1, courtName); checkStmt.setString(2, bookingDate); checkStmt.setString(3, timeSlot);
            rsCheck = checkStmt.executeQuery();
            
            if (rsCheck.next()) {
                request.setAttribute("errorMessage", "Conflict: This court slot is already booked.");
                request.getRequestDispatcher("admin_book_court.jsp").forward(request, response);
                return;
            }
            
            // 4. Record the Booking
            insertStmt = conn.prepareStatement("INSERT INTO bookings (username, court_name, booking_date, time_slot, status) VALUES (?, ?, ?, ?, 'CONFIRMED')");
            insertStmt.setString(1, targetMember); insertStmt.setString(2, courtName); insertStmt.setString(3, bookingDate); insertStmt.setString(4, timeSlot);
            insertStmt.executeUpdate();
            
            // 5. THE FIX: Record the Revenue to sync the Dashboard!
            payStmt = conn.prepareStatement("INSERT INTO payments (username, amount, type, status) VALUES (?, ?, ?, 'PAID')");
            payStmt.setString(1, targetMember); payStmt.setDouble(2, price); payStmt.setString(3, "Walk-in Court Rental: " + courtName);
            payStmt.executeUpdate();
            
            conn.commit(); // Save everything together
            request.setAttribute("successMessage", "Success: Booking allocated to " + targetMember + ". ₹" + price + " added to ledger.");
            
        } catch (Exception e) {
            try { if(conn != null) conn.rollback(); } catch(Exception ex){}
            e.printStackTrace();
            request.setAttribute("errorMessage", "A system database error occurred.");
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        request.getRequestDispatcher("admin_book_court.jsp").forward(request, response);
    }
}