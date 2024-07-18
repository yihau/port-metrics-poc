#!/usr/bin/env bash

MY_IP=

tcpdump -n -t -i bond0 -l \
  "((src host $MY_IP and src portrange 8000-10000) or \
  (dst host $MY_IP and dst portrange 8000-10000)) and (tcp or udp)" | while read -r line; do

  maybe_protocol=$(echo "$line" | awk '{print $5}')
  protocol=""
  if [[ "$maybe_protocol" =~ UDP ]]; then
    protocol="UDP"
  elif [[ "$maybe_protocol" =~ Flags ]]; then
    protocol="TCP"
  fi
  if [[ -z $protocol ]]; then
    echo >&2 "unexpected package: $line"
    continue
  fi

  length=0
  if [[ "$line" =~ length\ ([0-9]+) ]]; then
    length="${BASH_REMATCH[1]}"
  fi

  src=$(echo "$line" | awk '{print $2}')
  dst=$(echo "$line" | awk '{print $4}')
  direction=""
  port=""
  if [[ $dst =~ $MY_IP ]]; then
    direction="IN"
    port=$(echo "$dst" | awk -F'[.]' '{print $NF}' | tr -d ':')
  elif [[ $src =~ $MY_IP ]]; then
    direction="OUT"
    port=$(echo "$src" | awk -F'[.]' '{print $NF}' | tr -d ':')
  fi

  if [[ -z $port ]]; then
    echo >&2 "couldn't parse 'port' from the line: $line"
    continue
  fi

  if [[ -z $direction ]]; then
    echo >&2 "couldn't parse 'direction' from the line: $line"
    continue
  fi

  echo "tcpdump,port=${port}u direction=\"$direction\",protocol=\"$protocol\",length=${length}u"
done
