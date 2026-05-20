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

@WebServlet("/UpgradeMemberServlet")
public class UpgradeMemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve data sent from the button
        String userId = request.getParameter("id");
        String username = request.getParameter("username");

        Connection conn = null;
        PreparedStatement updateTierStmt = null;
        PreparedStatement insertPaymentStmt = null;

        try {
            conn = DBConnection.getConnection();
            // Lock the transaction so both steps must succeed together
            conn.setAutoCommit(false);

            // Step 1: Upgrade the user's tier in the database
            String updateSql = "UPDATE users SET tier = 'PRO' WHERE id = ?";
            updateTierStmt = conn.prepareStatement(updateSql);
            updateTierStmt.setInt(1, Integer.parseInt(userId));
            updateTierStmt.executeUpdate();

            // Step 2: Automatically log the membership revenue (₹1500)
            String paymentSql = "INSERT INTO payments (username, amount, type, status) VALUES (?, ?, ?, 'PAID')";
            insertPaymentStmt = conn.prepareStatement(paymentSql);
            insertPaymentStmt.setString(1, username);
            insertPaymentStmt.setDouble(2, 1500.00);
            insertPaymentStmt.setString(3, "Pro Membership Upgrade");
            insertPaymentStmt.executeUpdate();

            // Commit both actions to the database permanently
            conn.commit();
            request.setAttribute("successMessage", username + " is now a PRO member! Revenue logged.");

        } catch (Exception e) {
            // If anything fails, rollback so we don't end up with half a transaction
            try { if(conn != null) conn.rollback(); } catch(Exception ex) {}
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to upgrade member. Transaction rolled back.");
        } finally {
            try { if(updateTierStmt != null) updateTierStmt.close(); } catch(Exception e) {}
            try { if(insertPaymentStmt != null) insertPaymentStmt.close(); } catch(Exception e) {}
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
        
        // Bounce the Admin back to the directory to see the changes
        request.getRequestDispatcher("manage_members.jsp").forward(request, response);
    }
}