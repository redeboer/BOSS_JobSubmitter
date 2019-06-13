#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: Batch submit jobOption files created with CreateJobFiles.sh
# *        AUTHOR: Remco de Boer (@IHEP), EMAIL: remco.de.boer@ihep.ac.cn
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 22 October 2018
# *         USAGE: bash SubmitAll.sh <analysis name>
# *     ARGUMENTS: $1 analysis name (e.g. "RhopiAlg")
# * ===============================================================================

set -e # exit if a command or function exits with a non-zero status
source "${BOSS_StarterPack}/setup/FunctionsPrint.sh"
source "${BOSS_StarterPack}/setup/Functions.sh"

# ! ================================= ! #
# ! ------- Script parameters ------- ! #
# ! ================================= ! #

	outputDir="${1}"
	jobIdentifier="${2}"
	StarterPackPath="${PWD/${PWD/*BOSS_StarterPack}}" # get path of BOSS Afterburner
	scriptFolder="${StarterPackPath}/jobs/sub"



# * ========================= * #
# * ------- FUNCTIONS ------- * #
# * ========================= * #

	function CheckFolder()
	{
		folderToCheck="${1}"
		if [ ! -d ${folderToCheck} ]; then
			PrintError "Folder \"${folderToCheck}\" does not exist. Check this script..."
			exit
		fi
	}



# * ================================ * #
# * ------- Check parameters ------- * #
# * ================================ * #

	CheckFolder ${scriptFolder}
	nJobs=$(ls ${scriptFolder}/${outputDir}/* | grep -E sub_${jobIdentifier}_[0-9]+.sh$ | wc -l)
	if [ ${nJobs} == 0 ]; then
		PrintError "No jobs of type \"${jobIdentifier}\" available in \"${scriptFolder}/${outputDir}\""
		exit
	fi


# * ====================================== * #
# * ------- Run over all job files ------- * #
# * ====================================== * #

	AskForInput "Submit ${nJobs} jobs for \"${jobIdentifier}\"?"
	tempFilename="temp.sh"
	echo > ${tempFilename} # temporary fix due to submit error: "Failed to create new proc id"
	for job in $(ls ${scriptFolder}/${outputDir}/* | grep -E sub_${jobIdentifier}_[0-9]+.sh$); do
		chmod +x "${job}"
		echo "hep_sub -g physics \"${job}\"" >> "${tempFilename}"
		# hep_sub -g physics "${job}"
		# if [ $? != 0 ]; then
		# 	PrintError "Aborted submitting jobs"
		# 	exit 1
		# fi
	done
	bash temp.sh
	# echo "Now run:"
	# echo "  bash ${tempFilename}"
	# echo "and use:"
	# echo "  hep_q -u $USER"
	# echo "to see which jobs you have running."
	# echo "Yes, it's a temporary solution..."
	# exit


# * ===================================== * #
# * ------- Final terminal output ------- * #
# * ===================================== * #

	PrintSuccess "Succesfully submitted ${nJobs} \"${jobIdentifier}\" jobs"
	echo
	echo "These are your jobs:"
	hep_q -u $USER