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

@WebServlet("/DeleteTournamentServlet")
public class DeleteTournamentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if(request.getSession().getAttribute("user") == null || !"ADMIN".equals(request.getSession().getAttribute("role"))) { 
            response.sendRedirect("login.jsp"); 
            return; 
        }

        String tournamentId = request.getParameter("id");
        
        if(tournamentId != null && !tournamentId.trim().isEmpty()) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM tournaments WHERE id = ?")) {
                
                ps.setInt(1, Integer.parseInt(tournamentId));
                int rows = ps.executeUpdate();
                
                if(rows > 0) {
                    request.setAttribute("successMessage", "Tournament successfully removed from the schedule.");
                } else {
                    request.setAttribute("errorMessage", "Tournament could not be found.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Database error occurred while deleting tournament.");
            }
        }
        
        request.getRequestDispatcher("manage_tournaments.jsp").forward(request, response);
    }
}