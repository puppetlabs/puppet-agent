#!/bin/bash

set -e

USAGE="USAGE: $0 <master-vm> <agent-vm> <agent-version> <server-version> <puppetdb-version>"
domain=".delivery.puppetlabs.net"

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

# Append domains after validation.
master_vm="$1$domain"
agent_vm="$2$domain"

echo "#### Setting up master..."
$(dirname $0)/steps/setup-master.sh ${master_vm} ${agent_version} ${server_version} ${puppetdb_version}

echo "#### Setting up agent..."
$(dirname $0)/../steps/setup-agent.sh ${master_vm} ${agent_vm} ${agent_version} "package"

echo "#### Running validation..."
$(dirname $0)/../steps/run-validation-tests.sh ${master_vm} ${agent_vm}

echo "All done!"
