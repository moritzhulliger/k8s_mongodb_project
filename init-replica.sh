#!/bin/bash
set -e

echo "⏳ Waiting for mongo1 to accept connections..."

success=0
for i in {1..30}; do
  if mongosh --host mongo1 --username root --password example --authenticationDatabase admin --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "✅ mongo1 is ready"
    success=1
    break
  else
    echo "❌ Attempt $i failed. Retrying..."
    sleep 2
  fi
done

if [[ $success -ne 1 ]]; then
  echo "❌ mongo1 did not become ready in time."
  exit 1
fi

echo "⚙️ Initiating replica set..."

mongosh --host mongo1 --username root --password example --authenticationDatabase admin <<EOF
if (rs.status().ok !== 1) {
  rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: "mongo1:27017" },
      { _id: 1, host: "mongo2:27017" },
      { _id: 2, host: "mongo3:27017" }
    ]
  })
}