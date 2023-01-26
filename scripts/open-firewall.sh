#!/usr/bin/env sh

#--- prerequisites ---#

doctl compute firewall create --name currentIP --inbound-rules=protocol:tcp,ports:22,address:$(curl -s http://whatismyip.akamai.com && echo) --tag-names live,prod
