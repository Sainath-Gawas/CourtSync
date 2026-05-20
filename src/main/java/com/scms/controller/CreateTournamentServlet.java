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

@WebServlet("/CreateTournamentServlet")
public class CreateTournamentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String title = request.getParameter("title");
        String sport = request.getParameter("sport");
        String date = request.getParameter("event_date");
        double fee = Double.parseDouble(request.getParameter("entry_fee"));
        String desc = request.getParameter("description");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO tournaments (title, sport, event_date, entry_fee, description) VALUES (?, ?, ?, ?, ?)")) {
            ps.setString(1, title);
            ps.setString(2, sport);
            ps.setString(3, date);
            ps.setDouble(4, fee);
            ps.setString(5, desc);
            ps.executeUpdate();
            request.setAttribute("successMessage", "Tournament '" + title + "' published live!");
        } catch (Exception e) {
            e.printStackTrace();
        }
        request.getRequestDispatcher("manage_tournaments.jsp").forward(request, response);
    }
}