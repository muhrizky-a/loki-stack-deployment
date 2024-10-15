#!/bin/bash

echo "
#!/bin/bash
for i in $(cat /run/openvswitch/*.pid)
do
    sudo kill -HUP $i
done
" | sudo tee /etc/systemd/system/kill-pid-ovs.sh

sudo chmod +x /etc/systemd/system/kill-pid-ovs.sh

echo "
[Unit]
Description=Kill PID or openvswitch_vswitch and openvswitch_db
After=docker.service

[Service]
User=loki
#WorkingDirectory=/etc/systemd/system
ExecStart=/bin/bash /etc/systemd/system/kill-pid-ovs.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/kolla-kill-pid-ovs.service

sudo systemctl enable kolla-kill-pid-ovs.service