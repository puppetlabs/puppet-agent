#!/bin/bash

set -e

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i "$(dirname $0)/../puppet-agent-${3}-smoke-test-packages-output.txt")

# Include stderr
exec 2>&1

USAGE="USAGE: $0 <master-vm> <agent-vm> <agent-version> <server-version> <puppetdb-version> [<collection>]"
domain=".delivery.puppetlabs.net"

master_vm="$1"
agent_vm="$2"
agent_version="$3"
server_version="$4"
puppetdb_version="$5"
collection="${6:-puppet5}"

if [[ -z "${master_vm}" || -z "${agent_vm}" || -z "${agent_version}" || \
      -z "${server_version}" || -z "${puppetdb_version}" ]]; then
  echo "${USAGE}"
  exit 1
fi

# Append domains after validation.
master_vm="$1$domain"
agent_vm="$2$domain"

echo "##### master_vm = ${master_vm}"
echo "##### agent_vm = ${agent_vm}"
echo "##### agent_version = ${agent_version}"
echo "##### server_version = ${server_version}"
echo "##### puppetdb_version = ${puppetdb_version}"
echo "##### collection = ${collection}"
echo ""
echo "#### Setting up master..."
$(dirname $0)/steps/setup-master.sh ${master_vm} ${agent_version} ${server_version} ${puppetdb_version} ${collection}

echo "#### Setting up agent..."
$(dirname $0)/../steps/setup-agent.sh ${master_vm} ${agent_vm} ${agent_version} "package" ${collection}

echo "#### Running validation..."
$(dirname $0)/../steps/run-validation-tests.sh ${master_vm} ${agent_vm}

echo "All done!"
