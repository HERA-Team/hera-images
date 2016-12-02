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
path_to_do_scripts = /hera/rtp/scripts/paper
actions_per_still = 2
timeout = 14400
sleep_time = 5
block_size = 10
cluster_scheduler = 0

[WorkFlow]
prioritize_obs = 1
neighbors = 1
lock_all_neighbors_to_same_still = 1
actions = UV_POT, UV, UVC, CLEAN_UV, UVCR, CLEAN_UVC, ACQUIRE_NEIGHBORS, UVCRE, NPZ, UVCRR, NPZ_LIBRARIAN, CLEAN_UVCRE, UVCRRE, CLEAN_UVCRR, CLEAN_NPZ, CLEAN_NEIGHBORS, UVCRRE_LIBRARIAN, LIBRARIAN_MARK_FINISHED, CLEAN_UVCRRE, CLEAN_UVCR, COMPLETE
actions_endfile = UV_POT, UV, UVC, CLEAN_UV, UVCR, CLEAN_UVC, CLEAN_UVCR, COMPLETE

[UV]
args = [basename, '%s:%s/%s' % (pot,path,basename)]

[UVC]
args = [basename]

[CLEAN_UV]
args = [basename]

[UVCR]
args = [basename+'c']

[CLEAN_UVC]
args = [basename+'c']

[ACQUIRE_NEIGHBORS]
prereqs = UVCR, CLEAN_UVCR
args = ['%s:%s/%s' % (n[0], n[1], n[-1] + 'cR') for n in neighbors if n[0] != stillhost or n[1] != stillpath]

[UVCRE]
args = interleave(basename+'cR')

[NPZ]
args = [basename+'cRE']

[UVCRR]
args = [basename+'cR']

[NPZ_LIBRARIAN]
args = ['onsite-rtp', '%s/%scRE.npz' % (parent_dirs, basename)]

[CLEAN_UVCRE]
args = [basename+'cRE']

[UVCRRE]
args = interleave(basename+'cRR')

[CLEAN_UVCRR]
args = [basename+'cRR']

[CLEAN_NPZ]
args = [basename+'cRE.npz']

[CLEAN_NEIGHBORS]
args =  [n[-1] + 'cR' for n in neighbors if n[0] != stillhost]

[UVCRRE_LIBRARIAN]
args = ['onsite-rtp', '%s/%scRRE' % (parent_dirs, basename)]

[LIBRARIAN_MARK_FINISHED]
args = ['onsite-rtp', basename]

[CLEAN_UVCRRE]
args = [basename+'cRRE']

[CLEAN_UVCR]
args = [basename+'cR']
prereqs = UVCRRE
EOF
