#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the BSD License.

mkdir -p /root/.hera_mc
cat <<EOF >/root/.hera_mc/mc_config.json
{
  "default_db_name": "production",
  "databases": {
    "production": {
      "url": "postgresql://postgres:$HERA_DB_PASSWORD@:5432/hera_mc",
      "mode": "testing"
    },
    "testing": {
      "url": "postgresql://postgres:$HERA_DB_PASSWORD@:5432/hera_mc_test",
      "mode": "testing"
    }
  }
}
EOF

ln -s /var/run/postgresql/.s.PGSQL.5432 /tmp/
cd /hera/hera_mc
alembic upgrade head
rm -f /tmp/.s.PGSQL.5432
