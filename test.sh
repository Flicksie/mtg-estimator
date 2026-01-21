#!/bin/bash
# Test script for MTG Card Estimator

echo "======================================"
echo "MTG Card Estimator - Test Suite"
echo "======================================"
echo ""

# Set up environment
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"

echo "1. Testing CLI - Search command..."
bundle exec ruby mtg_estimator.rb search "Lightning Bolt"
echo ""

echo "2. Testing CLI - Estimate command..."
bundle exec ruby mtg_estimator.rb estimate "Lightning Bolt" "Counterspell"
echo ""

echo "3. Starting web server for API tests..."
bundle exec ruby app.rb &
SERVER_PID=$!
sleep 5

echo "4. Testing API - Search endpoint..."
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"query":"Lightning Bolt"}' \
  http://localhost:5000/api/search | python3 -m json.tool | head -10
echo ""

echo "5. Testing API - Home page..."
curl -s http://localhost:5000/ | grep -o "<title>.*</title>"
echo ""

echo "6. Stopping server..."
kill $SERVER_PID
wait $SERVER_PID 2>/dev/null

echo ""
echo "======================================"
echo "All tests completed!"
echo "======================================"
