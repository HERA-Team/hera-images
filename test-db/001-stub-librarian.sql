/* Copyright 2015-2016 the HERA Collaboration
   This file is licensed under the MIT License.

   This sets up the HERA Librarian backing database for testing purposes.
*/

use hera_lib_onsite;

insert into source (name, authenticator, create_time) values ("RTP", "9876543210", NOW());
insert into source (name, authenticator, create_time) values ("Correlator", "9876543211", NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  /* 100 GiB capacity; rsync pots do not run httpd but set http_prefix anyway */
  "onsitepot", NOW(), 107374182400, 0, "onsitepot", "http://onsitepot/data", "/data", "root@onsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "offsitepot", NOW(), 107374182400, 0, "offsitepot", "http://offsitepot/data", "/data", "root@offsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "liblocal", NOW(), 107374182400, 0, "", "", "/data", "", 0
);


use hera_lib_offsite;

insert into source (name, authenticator, create_time) values ("RTP", "9876543210", NOW());
insert into source (name, authenticator, create_time) values ("Correlator", "9876543211", NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "onsitepot", NOW(), 107374182400, 0, "onsitepot", "http://onsitepot/data", "/data", "root@onsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "offsitepot", NOW(), 107374182400, 0, "offsitepot", "http://offsitepot/data", "/data", "root@offsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "liblocal", NOW(), 107374182400, 0, "", "", "/data", "", 0
);
