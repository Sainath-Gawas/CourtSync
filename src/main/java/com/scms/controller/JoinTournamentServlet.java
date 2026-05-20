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

@WebServlet("/JoinTournamentServlet")
public class JoinTournamentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // THE FIX: Changed from doGet to doPost to match the form submission
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("user");
        
        if (username == null || !"MEMBER".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String tournamentTitle = request.getParameter("title");
        String eventDate = request.getParameter("event_date");
        double entryFee = Double.parseDouble(request.getParameter("entry_fee"));

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String formattedEventName = "Event - " + tournamentTitle;

            PreparedStatement checkStmt = conn.prepareStatement("SELECT * FROM bookings WHERE username = ? AND court_name = ?");
            checkStmt.setString(1, username); checkStmt.setString(2, formattedEventName);
            if (checkStmt.executeQuery().next()) {
                request.setAttribute("errorMessage", "You are already registered for " + tournamentTitle + "!");
                request.getRequestDispatcher("tournaments.jsp").forward(request, response);
                return;
            }

            PreparedStatement insertBooking = conn.prepareStatement("INSERT INTO bookings (username, court_name, booking_date, time_slot, status) VALUES (?, ?, ?, 'All Day', 'CONFIRMED')");
            insertBooking.setString(1, username); insertBooking.setString(2, formattedEventName); insertBooking.setString(3, eventDate);
            insertBooking.executeUpdate();

            if (entryFee > 0) {
                PreparedStatement insertPayment = conn.prepareStatement("INSERT INTO payments (username, amount, type, status) VALUES (?, ?, ?, 'PAID')");
                insertPayment.setString(1, username); insertPayment.setDouble(2, entryFee); insertPayment.setString(3, "Tournament Registration: " + tournamentTitle);
                insertPayment.executeUpdate();
            }

            conn.commit();
            request.setAttribute("successMessage", "Successfully registered for " + tournamentTitle + "!");
            
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            request.setAttribute("errorMessage", "A system error occurred.");
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        request.getRequestDispatcher("tournaments.jsp").forward(request, response);
    }
}