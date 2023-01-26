#!/usr/bin/env sh

#--- prerequisites ---#
# doctl
# DO_PK_FIREWALL_ID env var in ~/.envrc file
# jq

# [ -f ~/.envrc ] && . ~/.envrc

# doctl compute firewall list -o json | jq -r '.[0]["inbound_rules"][] | select (.ports == "22") | .sources.addresses[]' | while read ip ; do doctl compute firewall remove-rules $DO_PK_FIREWALL_ID --inbound-rules protocol:tcp,ports:22,address:$ip ; done

firewallName=currentIP

firewallID=$(doctl compute firewall list --format Name,ID --no-header | grep $firewallName | awk '{print $2}')

doctl compute firewall delete $firewallID
