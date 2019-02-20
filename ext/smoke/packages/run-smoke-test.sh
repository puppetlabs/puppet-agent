#!/bin/bash

set -e
source "$(dirname $0)/../helpers.sh"

USAGE="USAGE: $0 <master-vm> <agent-vm> <agent-version> <server-version> <puppetdb-version> [<collection>]"

master_vm="$1"
agent_vm="$2"
agent_version="$3"
server_version="$4"
puppetdb_version="$5"

if [[ -z "${master_vm}" || -z "${agent_vm}" || -z "${agent_version}" || \
      -z "${server_version}" || -z "${puppetdb_version}" ]]; then
  echo "${USAGE}"
  exit 1
fi

master_vm=$(hostname_with_domain $master_vm)
agent_vm=$(hostname_with_domain $agent_vm)
collection="${6:-$(guess_puppet_collection_for $agent_version)}"

echo "#### Setting up master [$master_vm]"
$(dirname $0)/steps/setup-master.sh ${master_vm} ${agent_version} ${server_version} ${puppetdb_version} ${collection}

echo "#### Setting up agent [$agent_vm]"
$(dirname $0)/../steps/setup-agent.sh ${master_vm} ${agent_vm} ${agent_version} "package" ${collection}

echo "#### Running validation"
$(dirname $0)/../steps/run-validation-tests.sh ${master_vm} ${agent_vm}

echo "All done!"
