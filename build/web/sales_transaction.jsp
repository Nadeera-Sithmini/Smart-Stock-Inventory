<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.sliate.controller.DBConnection" %>
<%
    // ලොගින් වෙලා නැත්නම් ලොගින් පේජ් එකට හරවා යැවීම
    if (session.getAttribute("userLoggedIn") == null || !(Boolean)session.getAttribute("userLoggedIn")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = null;
    String errMsg = null;

    // බිලක් සබ්මිට් කරද්දී වැඩ කරන කොටස
    if ("pos_bill".equals(request.getParameter("action"))) {
        String productId = request.getParameter("productId");
        String qtyStr = request.getParameter("qty");

        if (productId != null && qtyStr != null) {
            Connection con = null;
            PreparedStatement psCheck = null;
            PreparedStatement psSales = null;
            PreparedStatement psSalesItems = null;
            PreparedStatement psUpdateStock = null;
            
            try {
                con = DBConnection.getConnection();
                con.setAutoCommit(false); // Transactions ආරක්ෂිතව කරන්න auto commit අයින් කරනවා

                // 1. බඩුව ඩේටාබේස් එකේ තියෙනවද සහ ස්ටොක් ඇතිදැයි බැලීම
                psCheck = con.prepareStatement("SELECT product_name, price, quantity FROM products WHERE product_id = ?");
                psCheck.setString(1, productId);
                ResultSet rs = psCheck.executeQuery();

                if (rs.next()) {
                    String prodName = rs.getString("product_name");
                    double price = rs.getDouble("price");
                    int currentStock = rs.getInt("quantity");
                    int requestedQty = Integer.parseInt(qtyStr);

                    if (currentStock >= requestedQty) {
                        double totalAmount = price * requestedQty;

                        // 2. 'sales' ටේබල් එකට ප්‍රධාන බිල් විස්තර ඇතුලත් කිරීම
                        psSales = con.prepareStatement("INSERT INTO sales (total_amount, sale_date) VALUES (?, NOW())", Statement.RETURN_GENERATED_KEYS);
                        psSales.setDouble(1, totalAmount);
                        psSales.executeUpdate();

                        // අලුතින් හැදුණු Sale ID එක ලබා ගැනීම
                        ResultSet generatedKeys = psSales.getGeneratedKeys();
                        int saleId = 0;
                        if (generatedKeys.next()) {
                            saleId = generatedKeys.getInt(1);
                        }

                        // 3. 'sales_items' ටේබල් එකට බිලේ අයිටම් විස්තර ඇතුලත් කිරීම (ඔයාගේ DB එකේ තියෙන unit_price Column එකට අනුව හැදුවා 💡)
                        psSalesItems = con.prepareStatement("INSERT INTO sales_items (sale_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)");
                        psSalesItems.setInt(1, saleId);
                        psSalesItems.setInt(2, Integer.parseInt(productId));
                        psSalesItems.setInt(3, requestedQty);
                        psSalesItems.setDouble(4, price);
                        psSalesItems.executeUpdate();

                        // 4. 'products' ටේබල් එකෙන් විකුණපු ප්‍රමාණය අඩු කර ස්ටොක් අප්ඩේට් කිරීම
                        psUpdateStock = con.prepareStatement("UPDATE products SET quantity = quantity - ? WHERE product_id = ?");
                        psUpdateStock.setInt(1, requestedQty);
                        psUpdateStock.setInt(2, Integer.parseInt(productId));
                        psUpdateStock.executeUpdate();

                        con.commit(); // ඔක්කොම හරි නිසා DB එකට සේව් කරනවා
                        msg = "🛒 Bill Generated Successfully! Sold " + requestedQty + "x " + prodName + " (Total: Rs. " + (int)totalAmount + ")";
                    } else {
                        errMsg = "❌ Out of Stock! Only " + currentStock + " items available for this product.";
                    }
                } else {
                    errMsg = "❌ Invalid Product ID! No product found with ID: " + productId;
                }
            } catch (Exception e) {
                if (con != null) {
                    try { con.rollback(); } catch (SQLException ex) {}
                }
                errMsg = "⚠️ Transaction Failed: " + e.getMessage();
            } finally {
                try {
                    if (psCheck != null) psCheck.close();
                    if (psSales != null) psSales.close();
                    if (psSalesItems != null) psSalesItems.close();
                    if (psUpdateStock != null) psUpdateStock.close();
                    if (con != null) con.close();
                } catch (Exception e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sales & Billing - Smart Inventory</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #121212; color: #e0e0e0; margin: 0; display: flex; }
        .sidebar { width: 250px; height: 100vh; background: #1e1e1e; position: fixed; border-right: 1px solid #2d2d2d; padding-top: 20px; box-shadow: 2px 0 10px rgba(0,0,0,0.5); }
        .sidebar h2 { text-align: center; color: white; font-size: 22px; margin-bottom: 30px; font-weight: bold; letter-spacing: 1px; }
        .sidebar a { display: block; padding: 15px 25px; color: #b0b0b0; text-decoration: none; font-weight: bold; transition: 0.3s; margin: 5px 10px; border-radius: 6px; }
        .sidebar a:hover, .sidebar a.active { background: #2d2d2d; color: #3788d8; border-left: 4px solid #3788d8; }
        .sidebar a.logout { color: #ff6b6b; margin-top: 50px; }
        .sidebar a.logout:hover { background: #2c1616; }
        .main-content { margin-left: 270px; padding: 40px; width: calc(100% - 310px); }
        .container { background: #1e1e1e; padding: 30px; border-radius: 12px; border: 1px solid #2d2d2d; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
        h2, h3 { color: white; margin-top: 0; }
        hr { border: 0; border-top: 1px solid #2d2d2d; margin-bottom: 25px; }
        .flex-container { display: flex; gap: 30px; flex-wrap: wrap; }
        .billing-panel { flex: 1; min-width: 350px; background: #181818; padding: 25px; border-radius: 10px; border: 1px solid #2d2d2d; }
        .history-panel { flex: 1.5; min-width: 450px; background: #181818; padding: 25px; border-radius: 10px; border: 1px solid #2d2d2d; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #aaa; font-size: 14px; }
        .form-group input { width: 100%; padding: 12px; background: #2a2a2a; border: 1px solid #444; color: white; border-radius: 6px; font-size: 14px; box-sizing: border-box; }
        .btn-bill { width: 100%; background-color: #e82a5c; color: white; border: none; padding: 14px; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 15px; transition: 0.2s; text-transform: uppercase; letter-spacing: 1px; }
        .btn-bill:hover { background-color: #c61e4b; }
        .alert { padding: 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; font-weight: bold; }
        .alert-success { background: #1c3a27; border-left: 4px solid #2ae85c; color: #7bf39b; }
        .alert-danger { background: #3a1c1c; border-left: 4px solid #ff6b6b; color: #ff8b8b; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; background: #121212; border-radius: 8px; overflow: hidden; }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #2d2d2d; }
        th { background-color: #2d2d2d; color: #e82a5c; font-weight: bold; }
        tr:hover { background-color: #1a1a1a; }
        .no-records { text-align: center; color: #666; padding: 20px; font-style: italic; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>📦 Smart Stock</h2>
        <a href="shop_dashboard.jsp">🖥️ Dashboard</a>
        <a href="sales_transaction.jsp" class="active">🛒 Sales & Billing</a>
        <a href="stock_report.jsp">📊 AI Reports & Insights</a>
        <a href="logout.jsp" class="logout">🚪 Logout</a>
    </div>

    <div class="main-content">
        <div class="container">
            <h2>🛒 Live Sales & POS Billing System</h2>
            <hr>

            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>
            <% if (errMsg != null) { %>
                <div class="alert alert-danger"><%= errMsg %></div>
            <% } %>

            <div class="flex-container">
                <div class="billing-panel">
                    <h3>➕ Create New Invoice</h3>
                    <br>
                    <form action="sales_transaction.jsp" method="POST">
                        <input type="hidden" name="action" value="pos_bill">
                        
                        <div class="form-group">
                            <label>Product ID (Barcode / Code)</label>
                            <input type="number" name="productId" placeholder="Enter Product ID (e.g. 1)" required>
                        </div>
                        
                        <div class="form-group">
                            <label>Quantity to Sell</label>
                            <input type="number" name="qty" placeholder="Enter Qty (e.g. 2)" min="1" required>
                        </div>
                        
                        <button type="submit" class="btn-bill">Print & Deduct Stock</button>
                    </form>
                </div>

                <div class="history-panel">
                    <h3>📜 Recent Sales History</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Sale ID</th>
                                <th>Product Details</th>
                                <th>Qty Sold</th>
                                <th>Total Revenue</th>
                                <th>Date & Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    Statement st = con.createStatement();
                                    String sql = "SELECT s.sale_id, p.product_name, si.quantity, s.total_amount, s.sale_date " +
                                                 "FROM sales s " +
                                                 "JOIN sales_items si ON s.sale_id = si.sale_id " +
                                                 "JOIN products p ON si.product_id = p.product_id " +
                                                 "ORDER BY s.sale_id DESC LIMIT 8";
                                    ResultSet rs = st.executeQuery(sql);
                                    boolean hasSales = false;
                                    while (rs.next()) {
                                        hasSales = true;
                            %>
                                <tr>
                                    <td><code>#SAL-<%= rs.getInt("sale_id") %></code></td>
                                    <td style="color: white; font-weight: bold;"><%= rs.getString("product_name") %></td>
                                    <td><%= rs.getInt("quantity") %></td>
                                    <td style="color: #2ae85c; font-weight: bold;">Rs. <%= (int)rs.getDouble("total_amount") %></td>
                                    <td style="font-size: 13px; color: #aaa;"><%= rs.getTimestamp("sale_date") %></td>
                                </tr>
                            <%
                                    }
                                    con.close();
                                    if (!hasSales) {
                            %>
                                <tr>
                                    <td colspan="5" class="no-records">No sales recorded yet. Try selling an item!</td>
                                </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.print("<tr><td colspan='5' style='color:red;'>Error fetching sales: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>