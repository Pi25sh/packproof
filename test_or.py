import requests
import json

key = 'sk-4ee8718729360497-0901c8-247704ef'
headers = {
    'Authorization': f'Bearer {key}',
    'Content-Type': 'application/json'
}
data = {
    "model": "google/gemini-1.5-flash",
    "messages": [{"role": "user", "content": "hello"}]
}
res = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json=data)
print(res.status_code)
print(res.text)
