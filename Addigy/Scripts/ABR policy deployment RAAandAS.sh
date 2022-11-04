#!/bin/sh

LOGGEDINUSER=$(ls -l /dev/console | awk '{print $3}')
POLICYPATH="/Library/Application Support/Admin By Request/adminbyrequest.policy"

if [ -f "$POLICYPATH" ]; then
    echo "Clearing ABR folder"
rm -Rf /Library/Application\ Support/Admin\ By\ Request/*
fi

cat > "$POLICYPATH" <<EOF
{
      "UserGroups": {
          "$LOGGEDINUSER": ["ABR-Local-RAAandAS-Addigy"],
        }
} 
EOF
