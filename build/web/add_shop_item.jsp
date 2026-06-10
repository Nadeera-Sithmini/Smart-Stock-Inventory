<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Shop Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <div class="container my-5">
        <div class="row">
            <div class="col-md-6 mx-auto">
                <div class="card shadow-lg border-0 p-4 rounded-3">
                    <h3 class="fw-bold text-center mb-3 text-success">📦 Add Product to Stock</h3>
                    <p class="text-muted text-center small">Enter new retail product details below to update inventory.</p>
                    <hr>
                    
                    <form action="ShopInventoryServlet" method="POST">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Product Name</label>
                            <input type="text" name="prodName" class="form-control" placeholder="e.g., Munchee Super Cream Cracker" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Product Category</label>
                            <select name="prodCategory" class="form-select" required>
                                <option value="Grocery">Grocery / ☕</option>
                                <option value="Beverages">Beverages / 🥤</option>
                                <option value="Dairy">Dairy Products / 🥛</option>
                                <option value="Cosmetics">Cosmetics & Soap / 🧼</option>
                            </select>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Buying Price (Rs.)</label>
                                <input type="number" step="0.01" name="buyPrice" class="form-control" placeholder="0.00" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Selling Price (Rs.)</label>
                                <input type="number" step="0.01" name="sellPrice" class="form-control" placeholder="0.00" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Initial Stock Quantity</label>
                            <input type="number" name="prodQty" class="form-control" min="1" placeholder="e.g., 50" required>
                        </div>

                        <div class="d-grid gap-2 mt-4">
                            <button type="submit" class="btn btn-success fw-bold py-2">Add to Shop Stock</button>
                            <a href="shop_dashboard.jsp" class="btn btn-outline-secondary py-2">Back to Dashboard</a>
                        </div>
                    </form>
                    
                </div>
            </div>
        </div>
    </div>

</body>
</html>
