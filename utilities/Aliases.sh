#!/bin/bash -
# echo "Loading \"${BASH_SOURCE[0]/$(dirname ${BOSS_JobSubmitter})\/}\""

# * ========================= * #
# * ------- FUNCTIONS ------- * #
# * ========================= * #

	function cdjobs()
	{
		local subfolder="${1:-}"
		cd "${BOSS_JobSubmitter}/${subfolder}"
	}
	export cdjobs



# * ======================= * #
# * ------- ALIASES ------- * #
# * ======================= * #

	alias myjobs="hep_q -u ${USER}"
	alias nrjobs="echo -e \"You have:\\n$(myjobs | tail -1 | cut -d ";" -f 1):$(myjobs | tail -1 | cut -d ";" -f 2 | cut -d "," -f 3);$(myjobs | tail -1 | cut -d ";" -f 2 | cut -d "," -f 4);$(myjobs | tail -1 | cut -d ";" -f 2 | cut -d "," -f 5)\""
	alias alljobs="hep_q | less"