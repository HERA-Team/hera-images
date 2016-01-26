#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.
#
# Containers should run this on startup to set up the still.cfg needed to
# perform actions relating to the real time pipe. See the files in
# still_workflow:etc/*.cfg for descriptions of the parameters.
#
# Right now all we do is fill in the DB password from the environment. I know
# that more modern Docker setups discourage this approach; I don't know what
# the encouraged method is now, though.

cat <<EOF >$(dirname $0)/etc/still.cfg
[dbinfo]
dbuser = root
dbpasswd = $HERA_DB_PASSWORD
dbhost = db
dbport = 3306
dbtype = mysql
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
actions = UV_POT, UV, UVC, CLEAN_UV, UVCR, CLEAN_UVC, ACQUIRE_NEIGHBORS, UVCRE, NPZ, UVCRR, NPZ_POT, CLEAN_UVCRE, UVCRRE, CLEAN_UVCRR, CLEAN_NPZ, CLEAN_NEIGHBORS, UVCRRE_POT, CLEAN_UVCRRE, CLEAN_UVCR, COMPLETE
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

[NPZ_POT]
args = [basename+'cRE.npz', '%s:%s' % (pot, path)]

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

[UVCRRE_POT]
args = [basename+'cRRE', '%s:%s' % (pot, path)]

[CLEAN_UVCRRE]
args = [basename+'cRRE']

[CLEAN_UVCR]
args = [basename+'cR']
prereqs = UVCRRE
EOF
