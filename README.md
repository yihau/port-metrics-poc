# Port Metrics POC

## Requirements

```bash
$ tcpdump --version

# tcpdump version 4.99.1
# libpcap version 1.10.1 (with TPACKET_V3)
# OpenSSL 3.0.2 15 Mar 2022
```

## Get Started

1. Install Telegraf (https://docs.influxdata.com/telegraf/v1/install/)

```bash
# influxdata-archive_compat.key GPG Fingerprint: 9D539D90D3328DC7D6C8D3B9D8FF8E1F7DF8B07E
curl -s https://repos.influxdata.com/influxdata-archive_compat.key >influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg >/dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt-get update && sudo apt-get install telegraf

```

2. Grant Permission

telegraf user need this permission for executing tcpdump

- /etc/systemd/system/telegraf.service.d/override.conf

```conf
[Service]
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_RAW CAP_NET_ADMIN
```

3. Edit telegraf.conf (https://docs.influxdata.com/telegraf/v1/configuration/#set-environment-variables)


_You can either use variables or hard-code it._

telegraf.conf
```toml
[[inputs.execd]]
data_format = "influx"
# /path/to/collect-metrics.sh
command = ["${INPUT_COMMAND}"]

[[outputs.influxdb]]
urls = ["${INFLUX_DB_URL}"]
database = "${INFLUX_DB_DATABASE}"
username = "${INFLUX_DB_USERNAME}"
password = "${INFLUX_DB_PASSWORD}"
```

4. Start telegraf
