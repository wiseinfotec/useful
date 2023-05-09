#!/bin/sh

# Set the path to the sudoers file
SUDOERS_FILE=/etc/sudoers

# Check if the sudoers file exists
if [ ! -e "$SUDOERS_FILE" ]; then
  # Create a new sudoers file
  cat > "$SUDOERS_FILE" <<EOF
# User privilege specification
root    ALL=(ALL:ALL) ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "@include" directives:
@includedir /etc/sudoers.d
EOF

  # Check the syntax of the new sudoers file
  if visudo -c -f "$SUDOERS_FILE"; then
    echo "Created new sudoers file: $SUDOERS_FILE"
    exit 0
  else
    echo "Failed to create sudoers file: $SUDOERS_FILE"
    rm "$SUDOERS_FILE"
    exit 1
  fi
else
  # Create a backup of the sudoers file
  SUDOERS_BACKUP="$SUDOERS_FILE.bak"
  cp "$SUDOERS_FILE" "$SUDOERS_BACKUP"

  # Check if the sudoers file needs updating
  if grep -q '^@includedir /etc/sudoers.d\|^#includedir /etc/sudoers.d' "$SUDOERS_FILE"; then
    # The sudoers file is up to date
    echo "sudoers file is up to date: $SUDOERS_FILE"
  else
    # Update the sudoers file
    echo '#includedir /etc/sudoers.d' >> "$SUDOERS_FILE"
    echo "Updated sudoers file: $SUDOERS_FILE"
  fi

  # Check the syntax of the sudoers file
  if visudo -c -f "$SUDOERS_FILE"; then
    echo "sudoers file syntax is correct: $SUDOERS_FILE"
    exit 0
  else
    echo "sudoers file syntax is incorrect: $SUDOERS_FILE"
    # Restore the original sudoers file from the backup
    cp "$SUDOERS_BACKUP" "$SUDOERS_FILE"
    rm $SUDOERS_FILE.bak
    exit 1
  fi
fi
