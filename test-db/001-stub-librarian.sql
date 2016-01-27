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
  "onsitepot", NOW(), 107374182400, 0, "root@onsitepot:/data", "http://onsitepot/data", "/data", "root@onsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "offsitepot", NOW(), 107374182400, 0, "root@offsitepot:/data", "http://offsitepot/data", "/data", "root@offsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  /* We must blank out `ssh_prefix` for our local store, but not `rsync_prefix`*/
  "onsitelibrarian", NOW(), 107374182400, 0, "root@onsitelibrarian:/data", "", "/data", "", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "offsitelibrarian", NOW(), 107374182400, 0, "root@offsitelibrarian:/data", "", "/data", "root@offsitelibrarian", 0
);


use hera_lib_offsite;

insert into source (name, authenticator, create_time) values ("RTP", "9876543210", NOW());
insert into source (name, authenticator, create_time) values ("Correlator", "9876543211", NOW());

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "onsitepot", NOW(), 107374182400, 0, "root@onsitepot:/data", "http://onsitepot/data", "/data", "root@onsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "offsitepot", NOW(), 107374182400, 0, "root@offsitepot:/data", "http://offsitepot/data", "/data", "root@offsitepot", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  "onsitelibrarian", NOW(), 107374182400, 0, "root@onsitelibrarian:/data", "", "/data", "root@onsitelibrarian", 0
);

insert into store (
  name, create_time, capacity, used, rsync_prefix, http_prefix, path_prefix, ssh_prefix, unavailable
) values (
  /* We must blank out `ssh_prefix` for our local store, but not `rsync_prefix` */
  "offsitelibrarian", NOW(), 107374182400, 0, "root@offsitelibrarian:/data", "", "/data", "", 0
);
