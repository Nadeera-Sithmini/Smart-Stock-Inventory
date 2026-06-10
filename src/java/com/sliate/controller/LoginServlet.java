package com.sliate.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        if ("admin".equals(uname) && "1234".equals(pass)) {
            HttpSession session = request.getSession();
            session.setAttribute("userLoggedIn", true);
            
            // කෙලින්ම ඔයාගේ අලුත් ඩෑෂ්බෝඩ් එකට යවනවා
            response.sendRedirect("shop_dashboard.jsp");
        } else {
            // වැරදි නම් පරණ ලොගින් පේජ් එකටම एरර් මැසේජ් එකක් යවනවා
            request.setAttribute("errorMessage", "Invalid Username or Password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}