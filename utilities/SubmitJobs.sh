#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: Batch submit jobOption files created with CreateJobFiles.sh
# *        AUTHOR: Remco de Boer (@IHEP), EMAIL: remco.de.boer@ihep.ac.cn
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 22 October 2018
# *         USAGE: SubmitJobs <analysis name>
# *     ARGUMENTS: $1 analysis name (e.g. "RhopiAlg")
# * ===============================================================================

source "${BOSS_StarterKit}/setup/FunctionsPrint.sh"
source "${BOSS_StarterKit}/setup/Functions.sh"

function SubmitJobs()
{
	local currentPath="$(pwd)"
	cd "${BOSS_JobSubmitter}"
	[[ $? != 0 ]] && return 1

	local outputSubDir="${1}"
	local jobIdentifier="${2:-outputSubDir}"
	local scriptFolder="sub"

	CheckDirectory "${scriptFolder}"
	[[ $? != 0 ]] && return 1
	nJobs=$(ls ${scriptFolder}/${outputSubDir}/* | grep -E sub_${jobIdentifier}_[0-9]+.sh$ | wc -l)
	if [ ${nJobs} == 0 ]; then
		PrintError "No jobs of type \"${jobIdentifier}\" available in \"${scriptFolder}/${outputSubDir}\""
		return 1
	fi

	AskForInput "Submit ${nJobs} jobs for \"${jobIdentifier}\"?"
	[[ $? != 0 ]] && return 1

	local tempFilename="temp.sh"
	echo > "${tempFilename}"
	for job in $(ls ${BOSS_JobSubmitter}/${scriptFolder}/${outputSubDir}/* | grep -E sub_${jobIdentifier}_[0-9]+.sh$); do
		chmod +x "${job}"
		echo "hep_sub -g physics \"${job}\"" >> "${tempFilename}"
	done
	bash "${tempFilename}"

	PrintSuccess "Succesfully submitted ${nJobs} \"${jobIdentifier}\" jobs"
	echo
	echo "These are your jobs:"
	hep_q -u

	cd "${currentPath}"
}
export SubmitJobs