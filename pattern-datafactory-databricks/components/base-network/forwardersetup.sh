#!/bin/sh

touch /tmp/forwarderSetup_start

#  Install Bind9
#  https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-caching-or-forwarding-dns-server-on-ubuntu-14-04
yum install bind bind-utils -y

# configure Bind9 for forwarding
cat > named.conf << EndOFNamedConfOptions
acl goodclients {
    10.0.0.0/16;
    localhost;
    localnets;
};

options {
        recursion yes;

        allow-query { goodclients; };

        forwarders {
            168.63.129.16;
        };
        forward only;

        dnssec-validation no;

        auth-nxdomain no;    # conform to RFC1035
        listen-on { any; };
};
EndOFNamedConfOptions

cp named.conf /etc
service named restart

touch /tmp/forwarderSetup_end   