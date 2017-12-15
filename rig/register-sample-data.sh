#! /bin/bash
#
# This little script runs canned commands that register sample files from
# 2458101 with the M&C system and the Librarian.

if [ -z "$DB_PASSWORD" ] ; then
    echo >&2 "error: you must set the \$DB_PASSWORD environment variable"
    exit 1
fi

set +e
is_running=$(docker inspect --format='{{ .State.Running }}' rig_db_1 2>/dev/null)
ec=$?
set -e

if [ $ec -ne 0 ] ; then
    echo >&2 "error: you must start up the servers and wait for the DB to initialize"
    echo >&2 "  something like 'docker-compose up -d', then monitor with 'docker-compose logs -f'"
    exit 1
fi

docker exec rig_onsitepot_1 bash -c "mc_add_observation.py /data/2458101/*.uv"
docker exec rig_onsitepot_1 bash -c "add_obs_librarian.py local-correlator onsitepot /data/2458101/*.uv"
docker exec rig_onsitelibrarian_1 librarian_assign_sessions.py local-correlator
