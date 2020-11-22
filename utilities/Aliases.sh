#!/bin/bash -
# echo "Loading \"${BASH_SOURCE[0]/$(dirname ${BOSS_JobSubmitter})\/}\""

# * ========================= * #
# * ------- FUNCTIONS ------- * #
# * ========================= * #

function cdjobs() {
  local subfolder="${1:-}"
  cd "${BOSS_JobSubmitter}/${subfolder}"
}
export cdjobs

# * ======================= * #
# * ------- ALIASES ------- * #
# * ======================= * #

alias myjobs="hep_q -u ${USER}"
alias alljobs="hep_q | less"
