#!/usr/bin/env bash

set -euo pipefail

echo "  -> Initializing PostgreSQL..."

# Initialize the database cluster if it hasn't been already
if [[ ! -d /var/lib/postgres/data ]] || [[ -z "$(ls -A /var/lib/postgres/data 2>/dev/null)" ]]; then
  sudo -u postgres initdb -D /var/lib/postgres/data
else
  echo "  -> Data directory already initialized, skipping initdb"
fi

# Enable and start the service
sudo systemctl enable --now postgresql

# Create a superuser role matching the current user (idempotent)
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$(whoami)'" | grep -q 1; then
  echo "  -> PostgreSQL role '$(whoami)' already exists"
else
  sudo -u postgres createuser --superuser "$(whoami)"
  echo "  -> Created PostgreSQL superuser role '$(whoami)'"
fi

# Create a default database matching the current user (idempotent)
if psql -lqt | cut -d \| -f 1 | grep -qw "$(whoami)"; then
  echo "  -> Default database '$(whoami)' already exists"
else
  createdb "$(whoami)"
  echo "  -> Created default database '$(whoami)'"
fi

echo "  -> PostgreSQL is ready"
