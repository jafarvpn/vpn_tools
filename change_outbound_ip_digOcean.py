#!/usr/bin/python3

import subprocess
import requests
import yaml

gateway=requests.get("http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/gateway").text

with open("/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg", "w") as f:
    f.write("network: {config: disabled}")

with open("/etc/netplan/50-cloud-init.yaml", "r") as f:
    y = yaml.safe_load(f)
    y["network"]["ethernets"]["eth0"]["routes"][0]["via"] = gateway

with open("/etc/netplan/50-cloud-init.yaml", "w") as f:
    yaml.dump(y, f, default_flow_style=False, sort_keys=False)

with subprocess.Popen(["netplan", "apply"], stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
    output, err = process.communicate()
    if err:
        print("Could not apply netplan")
