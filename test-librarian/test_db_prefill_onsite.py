#! /usr/bin/env python
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# This is a script that's run when a test rig's Librarian server is first
# started. It's meant to set up the database. It's run from the librarian
# server directory after the configuration is set up, so it can import the
# librarian_server module.
#
# This particular incarnation is for the "onsite" Librarian server.

from __future__ import absolute_import, division, print_function, unicode_literals

import sys

from librarian_server import db, file, store
db.session.add (store.Store ('onsitepot', '/data', 'onsitepot'))
db.session.commit ()
