<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.sliate.controller.DBConnection" %>
<%
    if (session.getAttribute("userLoggedIn") == null || !(Boolean)session.getAttribute("userLoggedIn")) {
        response.sendRedirect("login.jsp");
        return;
    }
    String search = request.getParameter("search");
    if (search == null) search = "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Smart Inventory Pro</title>
    <style>
        :root {
            --bg-color: #0b0f19;
            --panel-bg: rgba(20, 27, 45, 0.7);
            --accent-blue: #00f2fe;
            --accent-purple: #4facfe;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --border-color: rgba(255, 255, 255, 0.08);
        }

        body { 
            font-family: 'Plus Jakarta Sans', 'Segoe UI', sans-serif; 
            background-color: var(--bg-color); 
            background-image: radial-gradient(circle at top right, rgba(79, 172, 254, 0.08), transparent 400px),
                              radial-gradient(circle at bottom left, rgba(0, 242, 254, 0.05), transparent 400px);
            color: var(--text-main); 
            margin: 0; 
            display: flex;
            min-height: 100vh;
        }

        /* Modern Glassmorphism Sidebar */
        .sidebar { 
            width: 260px; 
            background: rgba(15, 22, 38, 0.9); 
            position: fixed; 
            height: 100vh;
            border-right: 1px solid var(--border-color); 
            padding-top: 30px; 
            backdrop-filter: blur(10px);
            z-index: 100;
        }
        
        .sidebar h2 { 
            text-align: center; 
            color: #fff; 
            font-size: 20px; 
            margin-bottom: 40px; 
            font-weight: 800; 
            letter-spacing: 1.5px;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .sidebar a { 
            display: flex;
            align-items: center;
            padding: 14px 24px; 
            color: var(--text-muted); 
            text-decoration: none; 
            font-weight: 600; 
            font-size: 14px;
            transition: all 0.3s ease; 
            margin: 4px 16px; 
            border-radius: 8px; 
        }
        
        .sidebar a:hover, .sidebar a.active { 
            background: linear-gradient(135deg, rgba(0, 242, 254, 0.1), rgba(79, 172, 254, 0.05)); 
            color: var(--accent-blue); 
            box-shadow: inset 0 0 10px rgba(0, 242, 254, 0.05);
        }
        
        .sidebar a.logout { 
            color: #ff6b6b; 
            margin-top: 80px; 
        }
        
        .sidebar a.logout:hover { 
            background: rgba(255, 107, 107, 0.1); 
            color: #ff8b8b;
        }

        /* Main Content Layout */
        .main-content { 
            margin-left: 260px; 
            padding: 40px; 
            width: calc(100% - 260px); 
            box-sizing: border-box;
        }
        
        .header-title h1 {
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 10px 0;
            background: linear-gradient(to right, #ffffff, #cbd5e1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .header-title p {
            color: var(--text-muted);
            margin: 0 0 30px 0;
            font-size: 14px;
        }

        /* Glass Cards */
        .glass-card { 
            background: var(--panel-bg); 
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: 25px; 
            border-radius: 16px; 
            border: 1px solid var(--border-color); 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2); 
            margin-bottom: 30px;
        }
        
        .glass-card h3 { 
            color: #fff; 
            margin-top: 0; 
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Modern Grid Forms */
        .form-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); 
            gap: 16px; 
        }
        
        .form-group-input {
            position: relative;
        }
        
        .form-group-input input { 
            width: 100%; 
            padding: 13px 16px; 
            background: rgba(11, 15, 25, 0.6); 
            border: 1px solid rgba(255,255,255,0.1); 
            color: white; 
            border-radius: 10px; 
            font-size: 14px; 
            transition: all 0.3s;
            box-sizing: border-box;
        }
        
        .form-group-input input:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 12px rgba(0, 242, 254, 0.2);
            outline: none;
        }

        /* Action Buttons */
        .btn-prime { 
            background: linear-gradient(135deg, var(--accent-purple), var(--accent-blue)); 
            color: #0b0f19; 
            border: none; 
            padding: 13px 24px; 
            border-radius: 10px; 
            cursor: pointer; 
            font-weight: 700; 
            font-size: 14px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 242, 254, 0.2);
        }
        
        .btn-prime:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 242, 254, 0.4);
        }

        .btn-update { 
            background: rgba(79, 172, 254, 0.15); 
            color: var(--accent-blue); 
            border: 1px solid rgba(0, 242, 254, 0.3); 
            padding: 6px 14px; 
            border-radius: 6px; 
            cursor: pointer; 
            font-weight: 600; 
            font-size: 13px;
            transition: 0.2s;
        }
        
        .btn-update:hover { 
            background: var(--accent-blue); 
            color: #0b0f19; 
        }

        .btn-delete { 
            background: rgba(255, 107, 107, 0.1); 
            color: #ff6b6b; 
            border: 1px solid rgba(255, 107, 107, 0.2); 
            padding: 6px 14px; 
            border-radius: 6px; 
            text-decoration: none; 
            font-size: 13px; 
            font-weight: 600;
            transition: 0.2s;
        }
        
        .btn-delete:hover { 
            background: #ff6b6b; 
            color: white; 
        }

        /* Premium Inventory Table */
        .table-container {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }

        table { 
            width: 100%; 
            border-collapse: collapse; 
            background: rgba(15, 22, 38, 0.6);
            font-size: 14px;
        }
        
        th, td { 
            padding: 16px 20px; 
            text-align: left; 
            border-bottom: 1px solid var(--border-color); 
        }
        
        th { 
            background-color: rgba(20, 27, 45, 0.9); 
            color: #fff; 
            font-weight: 600; 
            letter-spacing: 0.5px;
        }
        
        tr:hover { 
            background-color: rgba(255, 255, 255, 0.02); 
        }
        
        .low-stock-tr { 
            background-color: rgba(255, 107, 107, 0.04) !important; 
        }
        
        .badge-low { 
            background: rgba(255, 107, 107, 0.15); 
            color: #ff6b6b; 
            padding: 4px 10px; 
            border-radius: 6px; 
            font-size: 11px; 
            font-weight: 700; 
            border: 1px solid rgba(255, 107, 107, 0.2);
        }
        
        .badge-normal {
            background: rgba(46, 232, 92, 0.1); 
            color: #2ae85c; 
            padding: 4px 10px; 
            border-radius: 6px; 
            font-size: 11px; 
            font-weight: 700;
        }
        
        .no-records { 
            text-align: center; 
            color: var(--text-muted); 
            padding: 40px; 
            font-style: italic; 
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

    <div class="sidebar">
        <h2>📦 SMART STOCK</h2>
        <a href="shop_dashboard.jsp" class="active">🖥️ Dashboard</a>
        <a href="sales_transaction.jsp">🛒 Sales & Billing</a>
        <a href="stock_report.jsp">📊 AI Reports & Insights</a>
        <a href="logout.jsp" class="logout">🚪 Logout</a>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>🖥️ Stock Control Center</h1>
            <p>Manage, search, and monitor your warehouse inventory with real-time analytics.</p>
        </div>

        <div class="glass-card">
            <h3>🔍 Filter & Search Inventory</h3>
            <form action="shop_dashboard.jsp" method="GET">
                <div class="form-grid" style="grid-template-columns: 1fr auto;">
                    <div class="form-group-input">
                        <input type="text" name="search" value="<%= search %>" placeholder="Search by Product Name...">
                    </div>
                    <button type="submit" class="btn-prime">Search Item</button>
                </div>
            </form>
        </div>

        <div class="glass-card">
            <h3>➕ Add New Product Asset</h3>
            <form action="ShopInventoryServlet" method="POST">
                <input type="hidden" name="op" value="add">
                <div class="form-grid">
                    <div class="form-group-input"><input type="text" name="itemCode" placeholder="Product ID (e.g. 101)" required></div>
                    <div class="form-group-input"><input type="text" name="itemName" placeholder="Product Name" required></div>
                    <div class="form-group-input"><input type="number" name="qty" placeholder="Quantity" required></div>
                    <div class="form-group-input"><input type="number" name="price" placeholder="Price per Unit" required></div>
                    <button type="submit" class="btn-prime">Add Item</button>
                </div>
            </form>
        </div>

        <div class="glass-card">
            <h3>🛒 Live Inventory Ledger</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Product ID</th>
                            <th>Product Name</th>
                            <th>Quantity</th>
                            <th>Price (LKR)</th>
                            <th>Status</th>
                            <th style="text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasData = false;
                            try {
                                Connection con = DBConnection.getConnection();
                                String sql = "SELECT * FROM products";
                                if(!search.equals("")) {
                                    sql += " WHERE product_name LIKE ?";
                                }
                                PreparedStatement ps = con.prepareStatement(sql);
                                if(!search.equals("")) {
                                    ps.setString(1, "%" + search + "%");
                                }
                                ResultSet rs = ps.executeQuery();
                                while(rs.next()) {
                                    hasData = true;
                                    String code = rs.getString("product_id");
                                    String name = rs.getString("product_name");
                                    int q = rs.getInt("quantity");
                                    double p = rs.getDouble("price");
                                    boolean isLow = (q <= 5);
                        %>
                            <tr class="<%= isLow ? "low-stock-tr" : "" %>">
                                <form action="ShopInventoryServlet" method="POST">
                                    <input type="hidden" name="op" value="update">
                                    <input type="hidden" name="itemCode" value="<%= code %>">
                                    
                                    <td><span style="color: var(--accent-blue); font-family: monospace; font-weight: bold;"><%= code %></span></td>
                                    <td style="color: #fff; font-weight: 600;"><%= name %></td>
                                    <td><input type="number" name="qty" value="<%= q %>" style="width:75px; background: rgba(0,0,0,0.3); color:#fff; border:1px solid rgba(255,255,255,0.1); padding:7px 10px; border-radius:6px; text-align: center;"></td>
                                    <td><input type="number" name="price" value="<%= (int)p %>" style="width:95px; background: rgba(0,0,0,0.3); color:#fff; border:1px solid rgba(255,255,255,0.1); padding:7px 10px; border-radius:6px;"></td>
                                    <td><%= isLow ? "<span class='badge-low'>Low Stock</span>" : "<span class='badge-normal'>Active</span>" %></td>
                                    <td style="text-align: center; display: flex; gap: 8px; justify-content: center;">
                                        <button type="submit" class="btn-update">Update</button>
                                        <a href="ShopInventoryServlet?op=delete&itemCode=<%= code %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this item?')">Delete</a>
                                    </td>
                                </form>
                            </tr>
                        <%      }
                                con.close();
                                if(!hasData) {
                        %>
                            <tr>
                                <td colspan="6" class="no-records">No products found. Add some assets to populate the grid.</td>
                            </tr>
                        <%
                                }
                            } catch(Exception e) { 
                                out.print("<tr><td colspan='6' style='color:#ff6b6b; padding:20px;'>⚠️ Error Loading Inventory: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>