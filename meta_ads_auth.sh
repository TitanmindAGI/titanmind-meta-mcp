#!/bin/bash
echo "Starting Meta Ads MCP with Titanmind authentication..."

# Set the Titanmind API token as an environment variable
export TITANMIND_API_TOKEN="your_titanmind_token"

# Check if the Titanmind server is running and can handle meta auth
echo "Checking if Titanmind meta auth endpoint is available..."
curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/meta" > /dev/null
if [ $? -ne 0 ]; then
    echo "Warning: Could not connect to Titanmind meta endpoint"
    echo "Please make sure the Titanmind server is running before proceeding."
    echo "You can start it with: cd /path/to/titanmind && npm run dev"
    echo ""
    echo "As a test, you can try running this command separately:"
    echo "curl -X POST \"http://localhost:3000/api/meta/auth?api_token=pk_8ee8c727644d4d32b646ddcf16f2385e\" -H \"Content-Type: application/json\""
    echo ""
    read -p "Press Enter to continue anyway or Ctrl+C to abort..." 
fi

# Try direct auth to test the endpoint
echo "Testing direct authentication with Titanmind..."
AUTH_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/meta/auth?api_token=pk_8ee8c727644d4d32b646ddcf16f2385e" -H "Content-Type: application/json")
if [[ $AUTH_RESPONSE == *"loginUrl"* ]]; then
    echo "Authentication endpoint working correctly!"
    LOGIN_URL=$(echo $AUTH_RESPONSE | grep -o 'https://[^"]*')
    echo "Login URL: $LOGIN_URL"
    
    # Open the browser directly as a fallback
    echo "Opening browser to login URL (as a fallback)..."
    if [ "$(uname)" == "Darwin" ]; then
        # macOS
        open "$LOGIN_URL"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Linux
        xdg-open "$LOGIN_URL" || firefox "$LOGIN_URL" || google-chrome "$LOGIN_URL" || echo "Could not open browser automatically"
    else
        # Windows or others
        echo "Please open this URL in your browser manually: $LOGIN_URL"
    fi
    
    echo "After authorizing in your browser, the MCP script will retrieve the token."
else
    echo "Warning: Authentication endpoint test failed!"
    echo "Response: $AUTH_RESPONSE"
    read -p "Press Enter to continue anyway or Ctrl+C to abort..." 
fi

# Run the meta-ads-mcp package
echo "Running Meta Ads MCP..."
python -m meta_ads_mcp

echo "Meta Ads MCP server is now running."
echo "If you had to manually authenticate, the token should be cached now."
