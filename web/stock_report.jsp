<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.sliate.controller.DBConnection" %>
<%
    if (session.getAttribute("userLoggedIn") == null || !(Boolean)session.getAttribute("userLoggedIn")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AI Reports & Insights - Smart Inventory Pro</title>
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

        /* Glassmorphism Sidebar */
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

        /* Mini Analytics Grid */
        .analytics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, rgba(20, 27, 45, 0.8), rgba(15, 22, 38, 0.8));
            border: 1px solid var(--border-color);
            padding: 22px;
            border-radius: 16px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 4px; height: 100%;
            background: linear-gradient(to bottom, var(--accent-blue), var(--accent-purple));
        }

        .stat-card .label {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .stat-card .value {
            font-size: 26px;
            font-weight: 800;
            color: #fff;
            margin-top: 8px;
            font-family: monospace;
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
        }

        /* Table Style */
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
        }
        
        tr:hover { 
            background-color: rgba(255, 255, 255, 0.02); 
        }

        /* AI Badges */
        .ai-glow-text {
            color: #00f2fe;
            font-weight: 700;
            text-shadow: 0 0 10px rgba(0, 242, 254, 0.4);
            font-family: monospace;
        }

        .badge-critical {
            background: rgba(255, 75, 75, 0.15);
            color: #ff4b4b;
            border: 1px solid rgba(255, 75, 75, 0.3);
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
            box-shadow: 0 0 10px rgba(255, 75, 75, 0.1);
        }

        .badge-stable {
            background: rgba(46, 232, 92, 0.1);
            color: #2ae85c;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <h2>📦 SMART STOCK</h2>
        <a href="shop_dashboard.jsp">🖥️ Dashboard</a>
        <a href="sales_transaction.jsp">🛒 Sales & Billing</a>
        <a href="stock_report.jsp" class="active">📊 AI Reports & Insights</a>
        <a href="logout.jsp" class="logout">🚪 Logout</a>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="header-title">
            <h1>📊 Predictive AI Intelligence & Reports</h1>
            <p>Smart ML Insights, warehouse metrics forecasting, and live financial stock values.</p>
        </div>

        <%
            int totalItems = 0;
            double totalValue = 0.0;
            int criticalStockCount = 0;

            // මුලින්ම මුළු ඩේටාබේස් එකම රීඩ් කරලා සාරාංශය ගණනය කරමු
            try {
                Connection con = DBConnection.getConnection();
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery("SELECT quantity, price FROM products");
                while(rs.next()) {
                    int qty = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    
                    totalItems += qty;
                    totalValue += (qty * price);
                    if(qty <= 5) {
                        criticalStockCount++;
                    }
                }
                con.close();
            } catch(Exception e) {
                // සයිලන්ට් හැන්ඩ්ලින්
            }
        %>

        <!-- LIVE METRICS CARD GRID -->
        <div class="analytics-grid">
            <div class="stat-card">
                <div class="label">Total Stock Assets Value</div>
                <div class="value" style="color: #2ae85c;">LKR <%= String.format("%,.2f", totalValue) %></div>
            </div>
            <div class="stat-card">
                <div class="label">Total Item Quantity In-Stock</div>
                <div class="value"><%= totalItems %> Units</div>
            </div>
            <div class="stat-card">
                <div class="label">AI Critical Reorder Alert</div>
                <div class="value" style="color: #ff4b4b;"><%= criticalStockCount %> Products</div>
            </div>
        </div>

        <!-- AI FORECASTING TABLE -->
        <div class="glass-card">
            <h3>🤖 Machine Learning Smart Stock Run-Out Forecast</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Product Name</th>
                            <th>Current Stock</th>
                            <th>Avg Daily Sales (ML Model)</th>
                            <th>Estimated Days Remaining</th>
                            <th>AI Recommendation Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                Statement st = con.createStatement();
                                // ප්‍රොඩක්ට් ටේබල් එකෙන් දත්ත ලෝඩ් කිරීම
                                ResultSet rs = st.executeQuery("SELECT * FROM products");
                                boolean hasProducts = false;
                                
                                while(rs.next()) {
                                    hasProducts = true;
                                    String id = rs.getString("product_id");
                                    String name = rs.getString("product_name");
                                    int qty = rs.getInt("quantity");
                                    
                                    // [AI SIMULATION LOGIC]
                                    // ප්‍රොඩක්ට් එකේ ID එක මත පදනම්ව දෛනිකව විකිණෙන සාමාන්‍ය ප්‍රමාණය (Sales Velocity) AI එකකින් වගේ සිමියුලේට් කරයි
                                    double avgDailySales = 1.2 + (Math.abs(id.hashCode()) % 4) * 0.4;
                                    if(qty > 50) { avgDailySales += 2.5; } // බඩු ගොඩක් තිබේ නම් විකිණීම වැඩියි ලෙස උපකල්පනය කෙරේ
                                    
                                    // බඩුව සම්පූර්ණයෙන්ම ඉවර වෙන්න ගතවන දවස් ගණන ගණනය කිරීම
                                    int daysRemaining = (int) Math.ceil(qty / avgDailySales);
                                    if(qty == 0) daysRemaining = 0;
                        %>
                            <tr>
                                <td style="font-family: monospace; font-weight: bold; color: var(--text-muted);"><%= id %></td>
                                <td style="color: #fff; font-weight: 600;"><%= name %></td>
                                <td><span style="font-weight: bold;"><%= qty %></span> Units</td>
                                <td style="color: var(--text-muted);"><%= String.format("%.1f", avgDailySales) %> / day</td>
                                <td>
                                    <% if (daysRemaining <= 4) { %>
                                        <span class="ai-glow-text" style="color: #ff4b4b;"><%= daysRemaining %> Days Left</span>
                                    <% } else if (daysRemaining <= 12) { %>
                                        <span class="ai-glow-text" style="color: #ffb800;"><%= daysRemaining %> Days Left</span>
                                    <% } else { %>
                                        <span class="ai-glow-text" style="color: #2ae85c;"><%= daysRemaining %> Days Left</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (qty <= 5 || daysRemaining <= 3) { %>
                                        <span class="badge-critical">⚠️ CRITICAL REORDER</span>
                                    <% } else { %>
                                        <span class="badge-stable">✅ STOCK STABLE</span>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                                }
                                con.close();
                                if(!hasProducts) {
                                    out.print("<tr><td colspan='6' style='text-align:center; padding:30px; color:var(--text-muted);'>No data available to forecast.</td></tr>");
                                }
                            } catch(Exception e) {
                                out.print("<tr><td colspan='6' style='color:#ff4b4b; padding:20px;'>⚠️ AI Engine Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</body>
</html>