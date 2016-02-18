#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the BSD License.

cat <<EOF >/tmp/tempdb.cfg
{
  "location":"tempinit",
  "mc_db":"postgresql://postgres:$POSTGRES_PASSWORD@/hera_mc?host=/var/run/postgresql",
  "test_db":"invalid"
}
EOF

python <<'EOF'
from hera_mc import mc

db = mc.DB_declarative ('/tmp/tempdb.cfg', use_test=False)
db.create_tables ()
EOF

rm -f /tmp/tempdb.cfg
