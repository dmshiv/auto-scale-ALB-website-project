#!/bin/bash
sudo yum update -y

# Install Apache web server (httpd)
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Write your custom HydCafe HTML homepage
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>HydCafe - Your Cozy Coffee Spot</title>
  <style>
    /* Reset some basics */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f9f5f1;
      color: #3b2f2f;
      line-height: 1.6;
    }

    header {
      background: #6f4e37;
      color: #fff;
      padding: 1.5rem 2rem;
      text-align: center;
      font-size: 2.5rem;
      font-weight: bold;
      letter-spacing: 2px;
      font-family: 'Georgia', serif;
      box-shadow: 0 2px 5px rgba(0,0,0,0.15);
    }

    main {
      max-width: 900px;
      margin: 3rem auto;
      padding: 0 1rem;
    }

    .hero {
      text-align: center;
      margin-bottom: 3rem;
    }

    .hero h1 {
      font-size: 3.5rem;
      margin-bottom: 0.3rem;
      font-family: 'Georgia', serif;
      color: #4b3621;
      text-shadow: 1px 1px 4px rgba(0,0,0,0.1);
    }

    .hero p {
      font-size: 1.3rem;
      color: #7e6651;
      margin-bottom: 1.5rem;
      font-style: italic;
    }

    .btn-primary {
      background-color: #6f4e37;
      color: white;
      padding: 0.8rem 2rem;
      font-size: 1.1rem;
      border: none;
      border-radius: 30px;
      cursor: pointer;
      transition: background-color 0.3s ease;
      text-decoration: none;
      display: inline-block;
      font-weight: 600;
      box-shadow: 0 4px 8px rgba(111, 78, 55, 0.3);
    }

    .btn-primary:hover {
      background-color: #563d29;
      box-shadow: 0 6px 12px rgba(86, 61, 41, 0.5);
    }

    section.menu {
      margin-top: 2rem;
    }

    section.menu h2 {
      font-size: 2rem;
      margin-bottom: 1rem;
      border-bottom: 3px solid #6f4e37;
      display: inline-block;
      padding-bottom: 0.2rem;
      font-family: 'Georgia', serif;
    }

    .menu-items {
      display: flex;
      flex-wrap: wrap;
      gap: 2rem;
      justify-content: center;
    }

    .menu-item {
      background: white;
      border-radius: 15px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
      padding: 1.2rem 1.5rem;
      width: 220px;
      text-align: center;
      transition: transform 0.3s ease;
    }

    .menu-item:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.15);
    }

    .menu-item h3 {
      font-family: 'Georgia', serif;
      margin-bottom: 0.5rem;
      color: #5a3e1b;
    }

    .menu-item p {
      font-size: 0.9rem;
      color: #7e6651;
      margin-bottom: 1rem;
      min-height: 50px;
    }

    .menu-item .price {
      font-weight: 700;
      font-size: 1.1rem;
      color: #6f4e37;
    }

    footer {
      margin-top: 4rem;
      background: #6f4e37;
      color: white;
      text-align: center;
      padding: 1rem 0;
      font-size: 0.9rem;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    @media (max-width: 600px) {
      .menu-items {
        flex-direction: column;
        align-items: center;
      }
    }
  </style>
</head>
<body>
  <header>
    HydCafe
  </header>

  <main>
    <section class="hero">
      <h1>Welcome to HydCafe</h1>
      <p>Your cozy corner for the finest coffee and baked delights.</p>
      <a href="#menu" class="btn-primary">Explore Our Menu</a>
    </section>

    <section id="menu" class="menu">
      <h2>Our Menu</h2>
      <div class="menu-items">
        <div class="menu-item">
          <h3>Espresso</h3>
          <p>Rich and bold shot of our signature coffee.</p>
          <div class="price">$2.50</div>
        </div>

        <div class="menu-item">
          <h3>Cappuccino</h3>
          <p>Creamy espresso with steamed milk and foam.</p>
          <div class="price">$3.50</div>
        </div>

        <div class="menu-item">
          <h3>Latte</h3>
          <p>Velvety milk blended with a smooth espresso shot.</p>
          <div class="price">$3.75</div>
        </div>

        <div class="menu-item">
          <h3>Chocolate Muffin</h3>
          <p>Moist, chocolatey, and perfect for your sweet tooth.</p>
          <div class="price">$2.00</div>
        </div>

        <div class="menu-item">
          <h3>Blueberry Scone</h3>
          <p>Flaky and fruity scone baked fresh daily.</p>
          <div class="price">$2.25</div>
        </div>
      </div>
    </section>
  </main>

  <footer>
    &copy; 2025 HydCafe | 123 Coffee Street, Hyderabad, India | Contact: +91 98765 43210
  </footer>
</body>
</html>
EOF
