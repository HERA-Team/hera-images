#! /bin/bash
# Copyright 2016-2018 the HERA Collaboration
# Licensed under the BSD License.

for f in /opt/conda/etc/conda/activate.d/* ; do
    source "$f"
done

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
  },
  "cm_csv_path": "/cmcsv"
}
EOF

ln -s /var/run/postgresql/.s.PGSQL.5432 /tmp/
cd /hera/hera_mc
alembic upgrade head
echo y |cm_init.py --maindb=pw4maindb
rm -f /tmp/.s.PGSQL.5432
