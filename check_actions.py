import urllib.request
import json
import sys

def check_actions():
    url = "https://api.github.com/repos/naderelsaany/Le3betna/actions/runs"
    try:
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'Mozilla/5.0')
        response = urllib.request.urlopen(req)
        data = json.loads(response.read())
        
        if data['workflow_runs']:
            latest_run = data['workflow_runs'][0]
            print(f"Latest Run: {latest_run['name']}")
            print(f"Status: {latest_run['status']}")
            print(f"Conclusion: {latest_run['conclusion']}")
            
            jobs_url = latest_run['jobs_url']
            jobs_req = urllib.request.Request(jobs_url)
            jobs_req.add_header('User-Agent', 'Mozilla/5.0')
            jobs_response = urllib.request.urlopen(jobs_req)
            jobs_data = json.loads(jobs_response.read())
            
            for job in jobs_data['jobs']:
                if job['conclusion'] == 'failure':
                    print(f"\nFailed Job: {job['name']}")
                    for step in job['steps']:
                        if step['conclusion'] == 'failure':
                            print(f"Failed Step: {step['name']}")
                            # We can't get exact logs without auth, but we know the step name!
                            
    except Exception as e:
        print(f"Error: {e}")

check_actions()
