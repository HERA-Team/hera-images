#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the BSD License.

python <<'EOF'
import os
from hera_mc import mc

password = os.environ['POSTGRES_PASSWORD']
db = mc.DB_declarative ('postgresql://postgres:%s@/hera_mc?host=/var/run/postgresql' % password)
db.create_tables ()
EOF
