/* Copyright 2015-2016 the HERA Collaboration
   This file is licensed under the MIT License.

   This sets up the HERA Librarian backing database for testing purposes.
*/

\connect hera_lib_onsite

insert into source (name, authenticator, create_time) values
  ('RTP', '9876543210', NOW()),
  ('Correlator', '9876543211', NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values
  /* 100 GiB capacity; rsync pots do not run httpd but set http_prefix anyway */
  ('onsitepot', NOW(), 107374182400, 0, 'root@onsitepot:/data', 'http://onsitepot/data',
   '/data', 'root@onsitepot', 0);


\connect hera_lib_offsite

insert into source (name, authenticator, create_time) values
  ('RTP', '9876543210', NOW()),
  ('Correlator', '9876543211', NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values
  ('offsitelibrarian', NOW(), 107374182400, 0, 'root@offsitelibrarian:/data', '',
   '/data', '', 0);
