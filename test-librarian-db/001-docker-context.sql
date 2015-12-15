/* Copyright 2015 the HERA Collaboration
   This file is licensed under the MIT License.

   This sets up the HERA Librarian backing database for testing purposes.
*/

use hera_lib;

insert into source (name, authenticator, create_time) values ("RTP", "9876543210", NOW());
insert into source (name, authenticator, create_time) values ("Correlator", "9876543211", NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  /* 100 GiB capacity */
  "liblocal", NOW(), 107374182400, 0, "", "", "/hera/localstore", "", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  /* 100 GiB capacity */
  "rsync0", NOW(), 107374182400, 0, "rsync0", "rsync0", "", "", 0
);
