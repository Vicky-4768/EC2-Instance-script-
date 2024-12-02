
#!/bin/bash

# Step 1: Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Step 2: Install nginx if not installed
echo "Installing Nginx..."
sudo apt-get install nginx -y

# Step 3: Create a simple HTML file with a button to show hostname
echo "Creating HTML file..."

html_file="/tmp/show_hostname.html"
cat <<EOF > $html_file
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Show Hostname</title>
    <script>
        function showHostname() {
            fetch('/hostname')
                .then(response => response.text())
                .then(data => document.getElementById('hostname').innerText = "Hostname: " + data)
                .catch(error => console.error('Error fetching hostname:', error));
        }
    </script>
</head>
<body>
    <h1>Click the button to show the system's hostname</h1>
    <button onclick="showHostname()">Show Hostname</button>
    <p id="hostname"></p>
</body>
</html>
EOF

echo "HTML file created at $html_file"

# Step 4: Copy HTML file to nginx web server directory
echo "Copying HTML file to nginx web server directory..."
sudo cp $html_file /var/www/html/index.html

# Step 5: Configure nginx to serve a simple endpoint for hostname
echo "Configuring Nginx to serve /hostname endpoint..."

# Edit nginx config to add a new location for the /hostname endpoint
nginx_conf="/etc/nginx/sites-available/default"

sudo sed -i '/location \/ {/a \ \ \ \ location /hostname {\n\ \ \ \ \ \ \ \ default_type text/plain;\n\ \ \ \ \ \ \ \ return 200 $(hostname);\n\ \ \ \ \ }' $nginx_conf

# Step 6: Restart nginx to apply the changes
echo "Restarting nginx..."
sudo systemctl restart nginx

# Step 7: Verify nginx status
echo "Checking nginx status..."
sudo systemctl status nginx

echo "Setup complete! Visit your server's IP address in a browser to see the HTML page."

