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

@WebServlet("/AddEquipmentServlet")
public class AddEquipmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp"); return;
        }

        String itemName = request.getParameter("item_name");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String condition = request.getParameter("condition");
        double rentalPrice = Double.parseDouble(request.getParameter("rental_price")); // NEW FEATURE

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement checkPs = conn.prepareStatement("SELECT id FROM equipment WHERE item_name = ?");
            checkPs.setString(1, itemName);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                PreparedStatement updatePs = conn.prepareStatement("UPDATE equipment SET total_quantity = total_quantity + ?, available_quantity = available_quantity + ?, rental_price = ? WHERE item_name = ?");
                updatePs.setInt(1, quantity); updatePs.setInt(2, quantity); updatePs.setDouble(3, rentalPrice); updatePs.setString(4, itemName);
                updatePs.executeUpdate();
                request.setAttribute("successMessage", "Stock updated! Added " + quantity + " more to " + itemName + ".");
            } else {
                PreparedStatement insertPs = conn.prepareStatement("INSERT INTO equipment (item_name, total_quantity, available_quantity, condition, rental_price) VALUES (?, ?, ?, ?, ?)");
                insertPs.setString(1, itemName); insertPs.setInt(2, quantity); insertPs.setInt(3, quantity); insertPs.setString(4, condition); insertPs.setDouble(5, rentalPrice);
                insertPs.executeUpdate();
                request.setAttribute("successMessage", "New asset '" + itemName + "' added with a rental fee of ₹" + rentalPrice);
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.getRequestDispatcher("manage_equipment.jsp").forward(request, response);
    }
}