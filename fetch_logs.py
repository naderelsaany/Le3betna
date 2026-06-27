import urllib.request
import json
import zipfile
import io
import re

def get_failed_logs():
    url = "https://api.github.com/repos/naderelsaany/Le3betna/actions/runs"
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Mozilla/5.0')
    response = urllib.request.urlopen(req)
    data = json.loads(response.read())
    latest_run = data['workflow_runs'][0]
    
    logs_url = latest_run['logs_url']
    print(f"Fetching logs from {logs_url}")
    
    req_logs = urllib.request.Request(logs_url)
    req_logs.add_header('User-Agent', 'Mozilla/5.0')
    
    # GitHub redirects to an S3 url for logs zip
    try:
        log_res = urllib.request.urlopen(req_logs)
        zip_data = log_res.read()
        
        with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
            # find the file for "Build Web App"
            for filename in z.namelist():
                if "Build Web App.txt" in filename:
                    content = z.read(filename).decode('utf-8')
                    # Look for errors
                    lines = content.split('\n')
                    error_lines = []
                    for i, line in enumerate(lines):
                        if 'Error:' in line or 'Exception:' in line or 'Failed' in line:
                            start = max(0, i-5)
                            end = min(len(lines), i+15)
                            error_lines.append('\n'.join(lines[start:end]))
                            break
                    print("--- ERROR LOG ---")
                    if error_lines:
                        print(error_lines[0])
                    else:
                        print(content[-1000:])
                    return
    except Exception as e:
        print(f"Error fetching logs: {e}")

get_failed_logs()
