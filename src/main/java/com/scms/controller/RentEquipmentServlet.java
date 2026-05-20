package com.scms.controller;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.scms.util.DBConnection;

@WebServlet("/RentEquipmentServlet")
public class RentEquipmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) { response.sendRedirect("login.jsp"); return; }

        String action = request.getParameter("action");
        String equipIdStr = request.getParameter("equip_id");

        try (Connection conn = DBConnection.getConnection()) {
            if ("rent".equals(action)) {
                // Fetch dynamic price
                PreparedStatement checkStmt = conn.prepareStatement("SELECT item_name, available_quantity, rental_price FROM equipment WHERE id = ?");
                checkStmt.setInt(1, Integer.parseInt(equipIdStr));
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next() && rs.getInt("available_quantity") > 0) {
                    String itemName = rs.getString("item_name");
                    double dynamicPrice = rs.getDouble("rental_price"); // NEW FEATURE
                    
                    PreparedStatement updateEq = conn.prepareStatement("UPDATE equipment SET available_quantity = available_quantity - 1 WHERE id = ?");
                    updateEq.setInt(1, Integer.parseInt(equipIdStr)); updateEq.executeUpdate();
                    
                    PreparedStatement insertBk = conn.prepareStatement("INSERT INTO equipment_bookings (username, equip_id, item_name, status) VALUES (?, ?, ?, 'RENTED')");
                    insertBk.setString(1, username); insertBk.setInt(2, Integer.parseInt(equipIdStr)); insertBk.setString(3, itemName); insertBk.executeUpdate();
                    
                    PreparedStatement insertPay = conn.prepareStatement("INSERT INTO payments (username, amount, type, status) VALUES (?, ?, ?, 'PAID')");
                    insertPay.setString(1, username); insertPay.setDouble(2, dynamicPrice); insertPay.setString(3, "Gear Rental: " + itemName); insertPay.executeUpdate();
                    
                    request.setAttribute("successMessage", "Successfully rented " + itemName + " for ₹" + dynamicPrice + "!");
                } else { request.setAttribute("errorMessage", "Out of stock!"); }
            } else if ("return".equals(action)) {
                String bookingId = request.getParameter("booking_id");
                PreparedStatement updateBk = conn.prepareStatement("UPDATE equipment_bookings SET status = 'RETURNED' WHERE id = ?");
                updateBk.setInt(1, Integer.parseInt(bookingId)); updateBk.executeUpdate();
                
                PreparedStatement updateEq = conn.prepareStatement("UPDATE equipment SET available_quantity = available_quantity + 1 WHERE id = ?");
                updateEq.setInt(1, Integer.parseInt(equipIdStr)); updateEq.executeUpdate();
                request.setAttribute("successMessage", "Gear returned. Thank you!");
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.getRequestDispatcher("member_dashboard.jsp").forward(request, response);
    }
}