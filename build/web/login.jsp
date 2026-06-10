<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Smart Inventory Pro</title>
    <style>
        :root {
            --bg-color: #0b0f19;
            --panel-bg: rgba(20, 27, 45, 0.6);
            --accent-blue: #00f2fe;
            --accent-purple: #4facfe;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --border-color: rgba(255, 255, 255, 0.08);
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Segoe UI', sans-serif;
            background-color: var(--bg-color);
            /* පසුබිමට ලස්සන Neon Gradients දෙකක් දමා ඇත */
            background-image: radial-gradient(circle at top left, rgba(0, 242, 254, 0.06), transparent 400px),
                              radial-gradient(circle at bottom right, rgba(79, 172, 254, 0.06), transparent 400px);
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden;
        }

        /* Glassmorphism Login Card */
        .login-container {
            width: 380px;
            background: var(--panel-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            padding: 40px;
            border-radius: 24px;
            border: 1px solid var(--border-color);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.4),
                        inset 0 0 20px rgba(255, 255, 255, 0.02);
            text-align: center;
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .brand-logo {
            font-size: 24px;
            font-weight: 800;
            letter-spacing: 1.5px;
            margin-bottom: 10px;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .login-container h3 {
            color: var(--text-main);
            font-size: 16px;
            font-weight: 500;
            margin: 0 0 35px 0;
            color: var(--text-muted);
        }

        /* Form Controls */
        .form-group {
            position: relative;
            margin-bottom: 22px;
            text-align: left;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 8px;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .form-group input {
            width: 100%;
            padding: 14px 16px;
            background: rgba(11, 15, 25, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            border-radius: 12px;
            font-size: 14px;
            transition: all 0.3s ease;
            box-sizing: border-box;
        }

        .form-group input:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 15px rgba(0, 242, 254, 0.2);
            background: rgba(11, 15, 25, 0.8);
            outline: none;
        }

        /* Premium Submit Button */
        .btn-login {
            width: 100%;
            background: linear-gradient(135deg, var(--accent-purple), var(--accent-blue));
            color: #0b0f19;
            border: none;
            padding: 14px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 700;
            font-size: 15px;
            letter-spacing: 0.5px;
            margin-top: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 20px rgba(0, 242, 254, 0.2);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(0, 242, 254, 0.4);
        }

        /* Error Messages Alert */
        .error-alert {
            background: rgba(255, 107, 107, 0.1);
            border: 1px solid rgba(255, 107, 107, 0.2);
            color: #ff8b8b;
            padding: 12px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: left;
        }
        
        .footer-text {
            margin-top: 30px;
            font-size: 12px;
            color: rgba(255,255,255,0.2);
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

    <div class="login-container">
        <div class="brand-logo">📦 SMART STOCK</div>
        <h3>Inventory Control Authentication</h3>

        <%-- සර්ව්ලට් එකෙන් එන වැරදි ලොගින් මැසේජ් පෙන්වීමට --%>
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="error-alert">
                ⚠️ <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="form-group">
                <label>USERNAME</label>
                <input type="text" name="username" placeholder="Enter your username" required autocomplete="off">
            </div>

            <div class="form-group">
                <label>PASSWORD</label>
                <input type="password" name="password" placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn-login">Sign In to System</button>
        </form>

        <div class="footer-text">
            Protected by Smart Stock Enterprise Secure-Shield v2.0
        </div>
    </div>

</body>
</html>