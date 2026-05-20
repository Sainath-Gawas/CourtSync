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

@WebServlet("/BookCourtServlet")
public class BookCourtServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("user");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String courtName = request.getParameter("court_name");
        String bookingDate = request.getParameter("booking_date");
        String timeSlot = request.getParameter("time_slot");
        
        Connection conn = null;
        PreparedStatement tierStmt = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertBookingStmt = null;
        PreparedStatement insertPaymentStmt = null;
        ResultSet rsTier = null;
        ResultSet rsCheck = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction
            
            // 1. Fetch the user's tier
            String tier = "BASIC";
            tierStmt = conn.prepareStatement("SELECT tier FROM users WHERE username = ?");
            tierStmt.setString(1, username);
            rsTier = tierStmt.executeQuery();
            if (rsTier.next() && rsTier.getString("tier") != null) {
                tier = rsTier.getString("tier");
            }

            // 2. Calculate the Dynamic Price
            double price = 0.0;
            if (courtName.contains("Tennis") && !courtName.contains("Table")) {
                price = "PRO".equals(tier) ? 200.0 : 500.0;
            } else if (courtName.contains("Badminton")) {
                price = "PRO".equals(tier) ? 100.0 : 300.0;
            } else if (courtName.contains("Table Tennis")) {
                price = "PRO".equals(tier) ? 0.0 : 200.0;
            }
            
            // 3. Check for double bookings
            String checkSql = "SELECT * FROM bookings WHERE court_name = ? AND booking_date = ? AND time_slot = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, courtName);
            checkStmt.setString(2, bookingDate);
            checkStmt.setString(3, timeSlot);
            rsCheck = checkStmt.executeQuery();
            
            if (rsCheck.next()) {
                request.setAttribute("errorMessage", "Sorry! That court is already booked for that specific time.");
                request.getRequestDispatcher("book_court.jsp").forward(request, response);
                return;
            } 

            // 4. Insert the Booking
            String insertBookingSql = "INSERT INTO bookings (username, court_name, booking_date, time_slot, status) VALUES (?, ?, ?, ?, 'CONFIRMED')";
            insertBookingStmt = conn.prepareStatement(insertBookingSql);
            insertBookingStmt.setString(1, username);
            insertBookingStmt.setString(2, courtName);
            insertBookingStmt.setString(3, bookingDate);
            insertBookingStmt.setString(4, timeSlot);
            insertBookingStmt.executeUpdate();
            
            // 5. Insert the Payment Ledger Entry
            String insertPaymentSql = "INSERT INTO payments (username, amount, type, status) VALUES (?, ?, ?, 'PAID')";
            insertPaymentStmt = conn.prepareStatement(insertPaymentSql);
            insertPaymentStmt.setString(1, username);
            insertPaymentStmt.setDouble(2, price);
            insertPaymentStmt.setString(3, "Court Rental: " + courtName);
            insertPaymentStmt.executeUpdate();
            
            // Commit transaction
            conn.commit();
            
            String successMsg = price > 0 ? "Court booked! ₹" + price + " charged to your account." : "Court booked for FREE with your PRO membership!";
            request.setAttribute("successMessage", successMsg);
            request.getRequestDispatcher("book_court.jsp").forward(request, response);
            
        } catch (Exception e) {
            try { if(conn != null) conn.rollback(); } catch(Exception ex) {}
            e.printStackTrace();
            request.setAttribute("errorMessage", "A system error occurred. Transaction rolled back.");
            request.getRequestDispatcher("book_court.jsp").forward(request, response);
        } finally {
            try { if (rsTier != null) rsTier.close(); } catch (Exception e) {}
            try { if (rsCheck != null) rsCheck.close(); } catch (Exception e) {}
            try { if (tierStmt != null) tierStmt.close(); } catch (Exception e) {}
            try { if (checkStmt != null) checkStmt.close(); } catch (Exception e) {}
            try { if (insertBookingStmt != null) insertBookingStmt.close(); } catch (Exception e) {}
            try { if (insertPaymentStmt != null) insertPaymentStmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}