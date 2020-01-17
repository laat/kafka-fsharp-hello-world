#!/usr/bin/env bash
#
# The script I used to create this project
#


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# shellcheck disable=SC1091,SC1090
source "${BASH_SOURCE%/*}/dotnet_lib.sh"

fsharp_project console Producer Confluent.Kafka
fsharp_project console Consumer Confluent.Kafka