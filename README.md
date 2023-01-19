# DigitalOcean Automation

Snippets to automate DigitalOcean workflows

Create Personal Access Token at https://cloud.digitalocean.com/account/api/tokens

// Install doctl (on macOS, if you receive an error, checkout the blog post…)

[Official documentation](https://docs.digitalocean.com/reference/doctl/)

[Official doctl repo](https://github.com/digitalocean/doctl)

## Authentication

Ref: [https://docs.digitalocean.com/reference/doctl/how-to/install/](https://docs.digitalocean.com/reference/doctl/how-to/install/)

```
# you will be asked the access token
# <NAME> could be "team-name"
doctl auth init --context <NAME>

# Authentication contexts let you switch between multiple authenticated accounts.
doctl auth list
doctl auth switch --context <NAME>

# validate doctl
doctl account get

```

## Monitoring

Ref: [https://docs.digitalocean.com/reference/doctl/reference/monitoring/](https://docs.digitalocean.com/reference/doctl/reference/monitoring/)

```

ADMIN_EMAIL=$(doctl account get --format "Email" --no-header)

doctl monitoring alert create --compare "GreaterThan" --value "90" --emails $ADMIN_EMAIL --type "v1/insights/droplet/cpu" --description "CPU is running high"
doctl monitoring alert create --compare "GreaterThan" --value "75" --emails $ADMIN_EMAIL --type "v1/insights/droplet/disk_utilization_percent" --description "Disk Usage is high"
doctl monitoring alert create --compare "GreaterThan" --value "90" --emails $ADMIN_EMAIL --type "v1/insights/droplet/memory_utilization_percent" --description "Memory Usage is high"

```

## Compute

Let's create tags that can be used to link firewall with servers (droplets).

### Tags
```

# DO limits number of tags to five on certain resources such as firewall.
declare -a tags
tags=(live prod test beta dev)
for tag in $tags; do; doctl compute tag create $tag; done

```

### Firewall

```
Firewall_Name=Basics
# create a firewall using minimal outbound rules
Outbound_Rules="protocol:icmp,address:0.0.0.0/0,address:::/0 protocol:tcp,ports:0,address:0.0.0.0/0,address:::/0 protocol:udp,ports:0,address:0.0.0.0/0,address:::/0"
doctl compute firewall create --name $Firewall_Name --outbound-rules "$Outbound_Rules"

# Get FirewallID using FirewallName
Firewall_ID=$(doctl compute firewall ls --format ID,Name --no-header | grep $Firewall_Name | awk '{print $1}')

# Add tags, standard inbound rules and any custom inbound rules
doctl compute firewall add-tags $Firewall_ID --tag-names live,prod
Inbound_ICMP="protocol:icmp,address:0.0.0.0/0,address:::/0"
Inbound_HTTP="protocol:tcp,ports:80,address:0.0.0.0/0,address:::/0"
Inbound_HTTPS="protocol:tcp,ports:443,address:0.0.0.0/0,address:::/0"
Inbound_SSH="protocol:tcp,ports:22,address:0.0.0.0/0,address:::/0"
doctl compute firewall add-rules $Firewall_ID --inbound-rules $Inbound_ICMP
doctl compute firewall add-rules $Firewall_ID --inbound-rules $Inbound_HTTP
doctl compute firewall add-rules $Firewall_ID --inbound-rules $Inbound_HTTPS
doctl compute firewall add-rules $Firewall_ID --inbound-rules $Inbound_SSH

# Internal Firewall
Firewall_Name=InternalNetwork
Internal_10="protocol:tcp,ports:0,address:10.0.0.0/8"
Internal_10_udp="protocol:udp,ports:0,address:10.0.0.0/8"
Internal_172="protocol:tcp,ports:0,address:172.16.0.0/12"
Internal_172_udp="protocol:udp,ports:0,address:172.16.0.0/12"
Internal_192="protocol:tcp,ports:0,address:192.168.0.0/16"
Internal_192_udp="protocol:udp,ports:0,address:192.168.0.0/16"

doctl compute firewall create --name $Firewall_Name --inbound-rules "$Internal_10 $Internal_10_udp $Internal_172 $Internal_172_udp $Internal_192 $Internal_192_udp"

for tag in $tags; do; doctl compute firewall add-tags $Firewall_ID --tag-names $tag; done

# delete a firewall rule
doctl compute firewall remove-rules $Firewall_ID --inbound-rules=$Inbound_SSH

```

TODO: Allow internal networks. IPv4 and IPv6


### Droplets

To add firewall to existing droplet/s...

```
doctl compute droplet list -c ~/doctl/format.yaml
doctl compute droplet tag droplet_id --tag-name actual_tag
# alternative
# doctl compute droplet tag droplet_name --tag-name actual_tag

```

To add firewall while creating a droplet...
```
doctl compute - TODO
```

Useful commands before creating a droplet...

```
doctl compute image list --public | more
doctl compute image list --public | grep 'debian'

doctl compute region list

doctl compute size list

doctl compute ssh-key list

```

### Monitoring

To add alerts... - TODO

