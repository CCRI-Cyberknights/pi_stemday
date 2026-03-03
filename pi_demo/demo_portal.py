import socketserver
import http.server
import os

# Force the script to use its own directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

PORT = 8080

def generate_html():
    # Hardcoded Demo Variables
    team_name = "Demo Team - Local Environment"
    target_ip = "127.0.0.1"
    station = 1
    theme_color = "#6f42c1" # Purple for the Demo!
    theme_hover = "#59339d"
    text_color = "white"
    
    # Station 1 Ports
    juice_port = "3001"
    sqli_port = "8011"
    webgoat_port = "8021"
    cowrie_port = "2221"
    mystery_port = "2231" 

    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>CCRI STEM Day - Demo Lab</title>
        <style>
            body {{ font-family: Arial, sans-serif; background-color: #f4f4f9; text-align: center; padding: 15px; margin: 0; }}
            .header {{ background-color: {theme_color}; color: {text_color}; padding: 15px; border-radius: 10px; margin-bottom: 15px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }}
            .header h1 {{ margin: 5px 0; font-size: 2em; }}
            .header h2 {{ margin: 5px 0 10px 0; font-size: 1.4em; }}
            .header p {{ margin: 5px 0; font-size: 1em; }}
            h2.section-title {{ color: #333; margin-bottom: 10px; font-size: 1.6em; }}
            .web-grid {{ display: flex; justify-content: center; gap: 15px; flex-wrap: wrap; margin-bottom: 20px; }}
            .web-card {{ background: white; padding: 15px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-top: 4px solid {theme_color}; width: 300px; display: flex; flex-direction: column; justify-content: space-between; }}
            .web-card h3 {{ margin-top: 0; margin-bottom: 15px; font-size: 1.2em; color: #333; }}
            .btn-group {{ display: flex; gap: 10px; width: 100%; }}
            .btn {{ flex: 2; padding: 10px; font-size: 15px; color: {text_color}; background-color: {theme_color}; text-decoration: none; border-radius: 5px; font-weight: bold; transition: background-color 0.2s; }}
            .btn:hover {{ background-color: {theme_hover}; color: {text_color}; }}
            .btn-secondary {{ flex: 1; background-color: #6c757d; color: white; font-weight: normal; }}
            .btn-secondary:hover {{ background-color: #5a6268; color: white; }}
            .terminal-grid {{ display: flex; justify-content: center; gap: 15px; max-width: 1000px; margin: 0 auto; }}
            .manual-box {{ background-color: white; padding: 15px; flex: 1; border-radius: 10px; border-top: 5px solid {theme_color}; box-shadow: 0 4px 8px rgba(0,0,0,0.1); text-align: left; display: flex; flex-direction: column; justify-content: space-between; }}
            .manual-box h3 {{ margin-top: 0; font-size: 1.3em; color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 10px; }}
            .manual-box p {{ font-size: 0.95em; color: #555; line-height: 1.4; margin: 5px 0; }}
            code {{ font-size: 1.1em; background: #1e1e1e; padding: 6px; border-radius: 4px; display: block; margin: 10px 0; color: #00ff00; text-align: center; font-family: monospace; font-weight: bold; }}
            code.inline {{ display: inline; padding: 3px 6px; margin: 0; }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Welcome to the Cyber Smorgasbord</h1>
            <h2>{team_name}</h2>
            <p>Target IP: <strong>{target_ip}</strong> (Localhost)</p>
        </div>

        <h2 class="section-title">Web Application Challenges</h2>
        <div class="web-grid">
            <div class="web-card">
                <h3>🧃 OWASP Juice Shop</h3>
                <div class="btn-group">
                    <a href="http://{target_ip}:{juice_port}" target="_blank" class="btn">Start Target</a>
                    <a href="readme_juice.html" class="btn btn-secondary" target="_blank">Guide</a>
                </div>
            </div>
            <div class="web-card">
                <h3>🐐 OWASP WebGoat</h3>
                <div class="btn-group">
                    <a href="http://{target_ip}:{webgoat_port}/WebGoat" target="_blank" class="btn">Start Target</a>
                    <a href="readme_webgoat.html" class="btn btn-secondary" target="_blank">Guide</a>
                </div>
            </div>
            <div class="web-card">
                <h3>💉 SQLi-Labs</h3>
                <div class="btn-group">
                    <a href="http://{target_ip}:{sqli_port}/" target="_blank" class="btn">Start Target</a>
                    <a href="readme_sqli.html" class="btn btn-secondary" target="_blank">Guide</a>
                </div>
            </div>
        </div>

        <h2 class="section-title">Terminal Challenges</h2>
        <div class="terminal-grid">
            <div class="manual-box">
                <div>
                    <h3>🕵️‍♂️ The Command Line Murders</h3>
                    <p>A murder has occurred in Terminal City! SSH into the police database to read the case files and find the killer.</p>
                    <code>ssh -p {mystery_port} detective@{target_ip}</code>
                    <div style="background: #f8f9fa; padding: 8px; border-left: 4px solid #007BFF; margin-top: 10px; font-size: 0.85em;">
                        <strong>Step-by-Step Login:</strong>
                        <ol style="margin-top: 5px; margin-bottom: 0; padding-left: 20px;">
                            <li>Type the SSH command above into your terminal.</li>
                            <li>If it asks "Are you sure...", type <strong>yes</strong> and hit Enter.</li>
                            <li>Type the password: <strong>detective</strong> <em>(Your typing will be invisible!)</em></li>
                        </ol>
                    </div>
                </div>
                <div style="background: #1e1e1e; padding: 10px; border-radius: 4px; margin-top: 15px; text-align: center; color: white; font-size: 0.9em;">
                    <span style="color: #d63384; font-weight: bold;">Once inside, run:</span> 
                    <code class="inline">cd clmystery</code>
                    <span style="color: #d63384; font-weight: bold;"> then </span>
                    <code class="inline">cat instructions</code>
                </div>
            </div>

            <div class="manual-box">
                <div>
                    <h3>🍯 Active Defense (Cowrie)</h3>
                    <p>This target does not have a web page. Open your terminal and attempt to hack into the server using a fake password.</p>
                    <code>ssh -p {cowrie_port} root@{target_ip}</code>
                    <div style="background: #f8f9fa; padding: 8px; border-left: 4px solid #dc3545; margin-top: 10px; font-size: 0.85em;">
                        <strong>Step-by-Step Login:</strong>
                        <ol style="margin-top: 5px; margin-bottom: 0; padding-left: 20px;">
                            <li>Type the SSH command above into your terminal.</li>
                            <li>If it asks to continue connecting, type <strong>yes</strong> and hit Enter.</li>
                            <li>Try guessing a terrible password like <strong>123456</strong> or <strong>admin</strong>.</li>
                        </ol>
                    </div>
                </div>
                <div style="text-align: center; margin-top: auto; padding-top: 15px;">
                    <a href="readme_cowrie.html" class="btn btn-secondary" target="_blank" style="display: inline-block; width: 80%; padding: 10px;">Read The Honeypot Guide</a>
                </div>
            </div>
        </div>
    </body>
    </html>
    """
    with open("index.html", "w", encoding="utf-8") as f:
        f.write(html_content)
    print("Generated Demo index.html")

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass # Shuts up the terminal logging so it stays clean

if __name__ == "__main__":
    generate_html()
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving DEMO captive portal on http://127.0.0.1:{PORT}")
        httpd.serve_forever()