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

@WebServlet("/RemoveEquipmentServlet")
public class RemoveEquipmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession().getAttribute("user") == null || !"ADMIN".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect("login.jsp"); return;
        }
        String id = request.getParameter("id");
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement("DELETE FROM equipment WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
            request.setAttribute("successMessage", "Item successfully removed from inventory.");
        } catch (Exception e) { e.printStackTrace(); }
        request.getRequestDispatcher("manage_equipment.jsp").forward(request, response);
    }
}