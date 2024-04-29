#!/usr/bin/env bash

tcpdump -i any -l '(portrange 8000-8020 or port 8899 or port 8900)' | while read -r line; do
  direction=""
  if [[ $(echo "$line" | awk '{print $3}') =~ ^labs-staked-node-ld7\. ]]; then
      direction="OUT"
  elif [[ $(echo "$line" | awk '{print $5}') =~ ^labs-staked-node-ld7\. ]]; then
      direction="IN"
  fi
  if [[ -z $direction ]]; then
    echo >&2 "couldn't parse 'direction' from line: $line"
    continue
  fi
  direction=${direction^^}

  protocol=$(echo "$line" | awk '{print $6}' | tr -d ',')
  if [[ -z $protocol ]]; then
    echo >&2 "couldn't parse 'protocol' from line: $line"
    continue
  fi

  length=$(echo "$line" | awk '{print $NF}')
  if [[ -z $length ]]; then
    echo >&2 "couldn't parse 'length' from line: $line"
    continue
  fi

  if [[ $direction == "IN" ]]; then
    port=$(echo "$line" | awk '{print $5}' | sed -E 's/.*\.([0-9]+):.*/\1/')
  elif [[ $direction == "OUT" ]]; then
    port=$(echo "$line" | awk '{print $3}' | sed -E 's/.*\.([0-9]+).*/\1/')
  fi
  if [[ -z $port ]]; then
    echo >&2 "couldn't parse 'port' from line: $line"
    continue
  fi

  echo "tcpdump,port=${port}u direction=\"$direction\",protocol=\"$protocol\",length=${length}u"
done
