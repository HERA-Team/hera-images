#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.
#
# Containers should run this on startup to set up the configuration files
# needed to access the database, since the database password is an
# environment variable.
#
# As part of this we setup the still.cfg needed to perform actions relating to
# the real time pipe. See the files in still_workflow:etc/*.cfg for
# descriptions of the parameters.

mkdir -p /.hera_mc /root/.hera_mc
cat <<EOF >/.hera_mc/mc_config.json
{
  "default_db_name": "production",
  "databases": {
    "production": {
      "url": "postgresql://postgres:$HERA_DB_PASSWORD@db:5432/hera_mc",
      "mode": "production"
    },
    "testing": {
      "url": "postgresql://postgres:$HERA_DB_PASSWORD@db:5432/hera_mc_test",
      "mode": "testing"
    }
  }
}
EOF
cp /.hera_mc/mc_config.json /root/.hera_mc/

# Derived from rtp/etc/rtp_hera_test1.cfg:

cat <<EOF >$(dirname $0)/rtp/etc/still.cfg
[dbinfo]
dbuser = postgres
dbpasswd = $HERA_DB_PASSWORD
dbhost = db
dbport = 5432
dbtype = postgresql
dbname = hera_rtp

[Still]
hosts = AUTO
port = 14204
data_dir = /data
path_to_do_scripts = /hera/rtp/scripts/hera
actions_per_still = 6
timeout = 14400
sleep_time = 5
block_size = 10
cluster_scheduler = 0

[WorkFlow]
prioritize_obs = 1
neighbors = 0
lock_all_neighbors_to_same_still = 0
actions = UV_POT,UV,UVC,CLEAN_UV,PLOTAUTOS,ADD_LIBRARIAN_PLOTAUTOS,CLEAN_PLOTAUTOS,ANT_FLAG,ADD_LIBRARIAN_BADANTS,PULL_SUBARRAY,ADD_LIBRARIAN_SUBARRAY,FIRST_CAL_HEX,ADD_LIBRARIAN_FIRSTCAL,CLEAN_FIRST_CAL_HEX,CLEAN_SUBARRAY,CLEAN_ANT_FLAG,CLEAN_UVC,DELETE_RAW,COMPLETE
actions_endfile = UV_POT, UV, UVC, CLEAN_UV, COMPLETE

[UV]
args = [basename, '%s:%s/%s' % (pot,path,basename)]

[UVC]
args = [basename]

[CLEAN_UV]
args = [basename]

[PLOTAUTOS]
args = [basename+'c']

[ADD_LIBRARIAN_PLOTAUTOS]
args = ['local-rtp', '%s/%s'%(parent_dirs, basename+'c.autos.png')]

[CLEAN_PLOTAUTOS]
args = [basename+'c.autos.png']

[ANT_FLAG]
args = [basename+'c']

[ADD_LIBRARIAN_BADANTS]
args = ['local-rtp', '%s/%s.bad_ants'%(parent_dirs, basename+'c')]

[CLEAN_ANT_FLAG]
args = [basename+'c.badants']

[PULL_SUBARRAY]
args = [basename+'c']

[ADD_LIBRARIAN_SUBARRAY]
args = ['local-rtp',basename+'c',parent_dirs]

[CLEAN_UVC]
args = [basename+'c']

[FIRST_CAL_HEX]
args = [basename+'c']

[ADD_LIBRARIAN_FIRSTCAL]
args = ['local-rtp',basename+'c',parent_dirs]

[CLEAN_SUBARRAY]
args = [basename+'c']

[CLEAN_FIRST_CAL_HEX]
args = [basename+'c']

[DELETE_RAW]
args = ['local-rtp',basename]
EOF
