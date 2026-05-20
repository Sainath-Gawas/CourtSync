package com.scms.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // We use doGet here because clicking a standard <a> link in HTML is always a GET request
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Grab the current session (but don't create a new one if they are already logged out)
        HttpSession session = request.getSession(false);
        
        // 2. If a session exists, absolutely destroy it
        if (session != null) {
            session.invalidate();
        }
        
        // 3. Attach a friendly goodbye message
        request.setAttribute("successMessage", "You have successfully logged out.");
        
        // 4. Send them back to the doorway
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}