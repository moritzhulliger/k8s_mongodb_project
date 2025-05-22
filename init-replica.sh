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

echo "⏳ Waiting for mongo2 and mongo3 to accept connections..."

for host in mongo2 mongo3; do
  echo "⏳ Waiting for $host to accept unauthenticated connections..."
  for i in {1..30}; do
    if mongosh --host $host --eval "db.runCommand({ ping: 1 })" > /dev/null 2>&1; then
      echo "✅ $host is reachable"
      break
    else
      echo "❌ $host not ready yet. Retrying..."
      sleep 2
    fi
  done
done


echo "⚙️ Initiating replica set..."

mongosh --host mongo1 --username root --password example --authenticationDatabase admin <<EOF
try {
  const status = rs.status();
  if (status.ok !== 1) {
    rs.initiate({
      _id: "rs0",
      members: [
        { _id: 0, host: "mongo1:27017" },
        { _id: 1, host: "mongo2:27017" },
        { _id: 2, host: "mongo3:27017" }
      ]
    });
    print("Replica set initiated.");
  } else {
    print("Replica set already initiated.");
  }
} catch (e) {
  print("Replica set not initiated yet, initiating now.");
  rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: "mongo1:27017" },
      { _id: 1, host: "mongo2:27017" },
      { _id: 2, host: "mongo3:27017" }
    ]
  });
}
EOF
