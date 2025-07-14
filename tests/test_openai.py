from openai import OpenAI
import os

client = OpenAI()
# error if no token
if not os.getenv("TITANMIND_API_TOKEN"):
    raise ValueError("TITANMIND_API_TOKEN is not set")

resp = client.responses.create(
    model="gpt-4.1",
    tools=[{
        "type": "mcp",
        "server_label": "meta-ads",
        "server_url": "https://mcp.platform.titanmindhq.com/meta-ads-mcp",
        "headers": {
            "Authorization": f"Bearer {os.getenv('TITANMIND_API_TOKEN')}"
        },
        "require_approval": "never",
    }],
    input="What are my meta ad accounts? Do not pass access_token since auth is already done.",
)

print(resp.output_text)
