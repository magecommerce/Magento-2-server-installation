#!/usr/bin/perl
###############################################################################
# Copyright 2006-2018, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################

sub custom_line {
        my $line = shift;
        my $lgfile = shift;

# Do not edit before this point
###############################################################################
#
# Custom regex matching can be added to this file without it being overwritten
# by csf upgrades. The format is slightly different to regex.pm to cater for
# additional parameters. You need to specify the log file that needs to be
# scanned for log line matches in csf.conf under CUSTOMx_LOG. You can scan up
# to 9 custom logs (CUSTOM1_LOG .. CUSTOM9_LOG)
#
# The regex matches in this file will supercede the matches in regex.pm
#
# Example:
#       if (($globlogs{CUSTOM1_LOG}{$lgfile}) and ($line =~ /^\S+\s+\d+\s+\S+ \S+ pure-ftpd: \(\?\@(\d+\.\d+\.\d+\.\d+)\) \[WARNING\] Authentication failed for user/)) {
#               return ("Failed myftpmatch login from",$1,"myftpmatch","5","20,21","1","0");
#       }
#
# The return values from this example are as follows:
#
# "Failed myftpmatch login from" = text for custom failure message
# $1 = the offending IP address
# "myftpmatch" = a unique identifier for this custom rule, must be alphanumeric and have no spaces
# "5" = the trigger level for blocking
# "20,21" = the ports to block the IP from in a comma separated list, only used if LF_SELECT enabled. To specify the protocol use 53;udp,53;tcp
# "1" = n/temporary (n = number of seconds to temporarily block) or 1/permanant IP block, only used if LF_TRIGGER is disabled
# "0" = whether to trigger Cloudflare block if CF_ENABLE is set. "0" = disable, "1" = enable

# /var/log/nginx/access.log
# Nginx 444  (Default: 5 errors bans for 24 hours)
if (($globlogs{CUSTOM1_LOG}{$lgfile}) and ($line =~ /(\S+) -.*[GET|POST|HEAD].*(\s444\s)/)) {
    return ("Nginx 444",$1,"nginx_444","5","443","86400","0");
}

# /var/log/nginx/access.log
# Trying to open private files  (Default: 1 error bans for 24 hours)
if (($globlogs{CUSTOM1_LOG}{$lgfile}) and ($line =~ /.*(env.php|local.xml).*client: (\S+),.*GET/)) {
    return ("Trying to download private files",$1,"nginx_private","1","443","86400","0");
}

# /var/log/nginx/access.log
# Trying to download htaccess or htpasswd  (Default: 1 error bans for 24 hours)
if (($globlogs{CUSTOM1_LOG}{$lgfile}) and ($line =~ /.*\.(htpasswd|htaccess).*client: (\S+),.*GET/)) {
    return ("Trying to download private files",$1,"nginx_htaccess","1","443","86400","0");
}

# /var/log/nginx/error.log
# NginX security rules trigger (Default: 5 errors bans for 24 hours)
if (($globlogs{CUSTOM2_LOG}{$lgfile}) and ($line =~ /.*access forbidden by rule, client: (\S+).*/)) {
    return ("NGINX Security rule triggered from",$1,"nginx_403","5","443","86400","0");
}

# /var/log/nginx/error.log
# NginX security rules trigger (Default: 5 errors bans for 24 hours)
if (($globlogs{CUSTOM2_LOG}{$lgfile}) and ($line =~ /.*user.*was not found in.*, client: (\S+).*/)) {
    return ("NGINX Security rule triggered from",$1,"nginx_401","5","443","86400","0");
}

# /var/log/nginx/error.log
# Nginx connection limit rule trigger (Default: 30 errors bans for 60mins)
if (($globlogs{CUSTOM2_LOG}{$lgfile}) and ($line =~ /.*limiting connections by zone .*, client: (\S+),(.*)/)) {
    return ("NGINX Security rule triggered from",$1,"nginx_conn_limit","30","443","3600","0");
}

# If the matches in this file are not syntactically correct for perl then lfd
# will fail with an error. You are responsible for the security of any regex
# expressions you use. Remember that log file spoofing can exploit poorly
# constructed regex's
###############################################################################
# Do not edit beyond this point

        return 0;
}

1;
