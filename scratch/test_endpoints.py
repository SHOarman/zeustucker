import requests

# We will test the list endpoints on port 8004
urls = [
    "http://10.10.28.89:8004/api/v1/admin/storybooks?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093&limit=1",
    "http://10.10.28.89:8004/admin/storybooks?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093&limit=1",
    "http://10.10.28.89:8004/api/v1/storybook/94a948bf-902d-40a7-bed1-16ae247c6740",
    "http://10.10.28.89:8004/storybook/94a948bf-902d-40a7-bed1-16ae247c6740",
]

for url in urls:
    try:
        r = requests.get(url)
        print(f"URL: {url} -> Status: {r.statusCode if hasattr(r, 'statusCode') else r.status_code}")
    except Exception as e:
        print(f"URL: {url} -> Error: {e}")
