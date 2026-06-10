package com.sliate.controller;

import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ShopInventoryServlet")
public class ShopInventoryServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // 1. සෙෂන් එකෙන් දැනට තියෙන ඉන්වෙන්ටරි ලිස්ට් එක ගන්නවා
        ArrayList<String[]> itemList = (ArrayList<String[]>) session.getAttribute("inventoryList");
        if (itemList == null) {
            itemList = new ArrayList<>();
            // මුලින්ම සිස්ටම් එක රන් වෙද්දී දකින ඩෙමෝ ඩේටා ටිකක්
            itemList.add(new String[]{"I001", "Laptop", "4", "150000"});
            itemList.add(new String[]{"I002", "Mouse", "20", "1500"});
            itemList.add(new String[]{"I003", "Keyboard", "3", "3500"});
            session.setAttribute("inventoryList", itemList);
        }

        // 2. JSP එකෙන් එවන Operation එක (op) සහ දත්ත ටික කියවා ගැනීම
        String op = request.getParameter("op");
        String itemCode = request.getParameter("itemCode");
        String itemName = request.getParameter("itemName");
        String qty = request.getParameter("qty");
        String price = request.getParameter("price");

        if (op != null) {
            // ➕ ADD OPERATION
            if (op.equals("add") && itemCode != null && itemName != null && qty != null && price != null) {
                itemList.add(new String[]{itemCode, itemName, qty, price});
            } 
            
            // 🔄 UPDATE OPERATION
            else if (op.equals("update") && itemCode != null && qty != null && price != null) {
                for (String[] item : itemList) {
                    if (item[0].equals(itemCode)) {
                        item[2] = qty;  // අලුත් Qty එක දානවා
                        item[3] = price; // අලුත් මිල දානවා
                        break;
                    }
                }
            } 
            
            // ❌ DELETE OPERATION
            else if (op.equals("delete") && itemCode != null) {
                for (int i = 0; i < itemList.size(); i++) {
                    if (itemList.get(i)[0].equals(itemCode)) {
                        itemList.remove(i); // ලිස්ට් එකෙන් අයින් කරනවා
                        break;
                    }
                }
            }
            
            // අලුත් දත්ත ටික ආයෙමත් සෙෂන් එකට අප්ඩේට් කරනවා
            session.setAttribute("inventoryList", itemList);
        }

        // හැම ඔපරේෂන් එකක්ම ඉවර වුනාම ආපහු Dashboard එකටම හරවා යවනවා
        response.sendRedirect("shop_dashboard.jsp");
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