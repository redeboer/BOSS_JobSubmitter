#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: Batch create jobOption files based on a template
# *        AUTHOR: Remco de Boer <remco.de.boer@ihep.ac.cn>
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 22 October 2018
# * ===============================================================================

source "${BOSS_StarterKit}/setup/FunctionsPrint.sh"
source "${BOSS_StarterKit}/setup/Functions.sh"


function CreateSimJobFiles()
{
	CheckIfFileExists "${templateFile_rec}"
	[[ $? != 0 ]] && return 1
	CheckIfFileExists "${templateFile_sim}"
	[[ $? != 0 ]] && return 1
	CheckIfFolderExists "${BOSS_JobSubmitter}"
	[[ $? != 0 ]] && return 1
	CheckIfFolderExists "${BOSS_StarterKit_OutputDir}"
	[[ $? != 0 ]] && return 1


	# * ================================ * #
	# * ------- Script arguments ------- * #
	# * ================================ * #
		local ofile="${BOSS_JobSubmitter}/${FUNCNAME[0]}.txt"
		rm -f "${ofile}"

		read -p "(+) For which package are you generating job options? (default: RhopiAlg) " input
		echo "${input}" >> "${ofile}"
		local packageName="${input:-RhopiAlg}"

		local packageNameCAP=$(echo ${packageName} | awk '{print toupper($0)}') # to upper case
		if [[ -z "${packageNameCAP}" ]]; then
			PrintWarning "Package \"${packageName}\" seems not to exist (${!packageNameCAP} is empty)"
			AskForInput "Continue?"
			[[ $? != 0 ]] && return 1
			echo "${input}" >> "${ofile}"
		fi

		local packageNameCAP="${packageNameCAP}ROOT"
		local decayCard="${!packageNameCAP}/share/${packageName}.dec"
		if [[ ! -f ${decayCard} ]]; then
			echo "(+) Default decay card \"${decayCard}\" does not exist. Which file to use instead?"
			read -e -p "" -i "$(dirname ${decayCard})/" decayCard
			if [[ ! -f "${decayCard}" ]]; then
				PrintError "Decay card \"${decayCard}\" does not exist"
				rm "${ofile}"
				return 1
			fi
			echo "${decayCard}" >> "${ofile}"
		fi

		read -p "(+) How many MC job option files do you want to generate? (default: 25) " input
		echo "${input}" >> "${ofile}"
		local nJobs=${input:-25}

		read -p "(+) How many events should each job generate? (default: 10000) " input
		echo "${input}" >> "${ofile}"
		local nEventsPerJob=${input:-10000}

		read -p "(+) What should be the message print level? (default: 4 [MSG::WARNING]) " input
		echo "${input}" >> "${ofile}"
		local outputLevel="${input:-4}"

		local totalNevents=$(echo $((${nJobs} * ${nEventsPerJob})))
		local totalNevents_format=$(printf "%'d" ${totalNevents})
		local outputSubdir="${packageName}/${totalNevents_format}_events"


	# * ============================= * #
	# * ------- Main function ------- * #
	# * ============================= * #
		# * Output directories
			local outputDir_sim="${BOSS_JobSubmitter}/sim/${outputSubdir}"
			local outputDir_rec="${BOSS_JobSubmitter}/rec/${outputSubdir}"
			local outputDir_sub="${BOSS_JobSubmitter}/sub/${outputSubdir}"
			local outputDir_raw="${BOSS_StarterKit_OutputDir}/raw/${outputSubdir}"
			local outputDir_dst="${BOSS_StarterKit_OutputDir}/dst/${outputSubdir}"
			local outputDir_log="${BOSS_StarterKit_OutputDir}/log/${outputSubdir}"

		# * User input
			echo "This will create ${nJobs} \"${packageName}\" simulation and reconstruction job option files with ${nEventsPerJob} events each in job."
			echo "These files will be written to folder:"
			echo "   \"${outputDir_sim}\""
			echo "   \"${outputDir_rec}\""
			echo "   \"${outputDir_sub}\""
			echo
			echo "  --> Total number of events: ${totalNevents_format}"
			echo
			AskForInput "Write ${nJobs} \"${packageName}\" simulation and reconstruction job files?"
			[[ $? != 0 ]] && return 1
			echo "${input}" >> "${ofile}"

		# * Create and EMPTY output directories
			CreateOrEmptyDirectory "${outputDir_sim}"
			CreateOrEmptyDirectory "${outputDir_rec}"
			CreateOrEmptyDirectory "${outputDir_sub}"
			mkdir -p "${outputDir_raw}"
			mkdir -p "${outputDir_dst}"
			mkdir -p "${outputDir_log}"

		# * Loop over jobs
			for jobNo in $(seq 0 $((${nJobs} - 1))); do

				echo -en "\e[0K\rCreating files for job $((${jobNo}+1))/${nJobs}..." # overwrite previous line

				# * Generate the simulation files (sim)
					local randomSeed=$(($(date +%s%N) % 1000000000)) # random seed based on system time
					local outputFile="${outputDir_sim}/sim_${packageName}_${jobNo}.txt"
					awk '{flag = 1}
						{sub(/__RANDSEED__/,'${randomSeed}')}
						{sub(/__OUTPUTLEVEL__/,'${outputLevel}')}
						{sub(/__DECAYCARD__/,"'${decayCard}'")}
						{sub(/__OUTPUTFILE__/,"'${outputDir_raw}'/'${packageName}'_'${jobNo}'.rtraw")}
						{sub(/__NEVENTS__/,'${nEventsPerJob}')}
						{if(flag == 1) {print $0} else {next} }' \
					${templateFile_sim} > "${outputFile}"
					ChangeLineEndingsFromWindowsToUnix "${outputFile}"
					chmod +x "${outputFile}"

				# * Generate the reconstruction files (rec)
					local outputFile="${outputDir_rec}/rec_${packageName}_${jobNo}.txt"
					awk '{flag = 1}
						{sub(/__RANDSEED__/,'${randomSeed}')}
						{sub(/__OUTPUTLEVEL__/,'${outputLevel}')}
						{sub(/__INPUTFILE__/,"'${outputDir_raw}'/'${packageName}'_'${jobNo}'.rtraw")}
						{sub(/__OUTPUTFILE__/,"'${outputDir_dst}'/'${packageName}'_'${jobNo}'.dst")}
						{sub(/__NEVENTS__/,'${nEventsPerJob}')}
						{if(flag == 1) {print $0} else {next} }' \
					"${templateFile_rec}" > "${outputFile}"
					ChangeLineEndingsFromWindowsToUnix "${outputFile}"
					chmod +x "${outputFile}"

				# * Generate the submit files (sub)
					local outputFile="${outputDir_sub}/sub_${packageName}_mc_${jobNo}.sh"
					echo "#!/bin/bash" > "${outputFile}" # empty file and write first line
					echo "{ boss.exe \"${outputDir_sim}/sim_${packageName}_${jobNo}.txt\"; } &> \"${outputDir_log}/sim_${packageName}_${jobNo}.log\"" >> "${outputFile}"
					echo "{ boss.exe \"${outputDir_rec}/rec_${packageName}_${jobNo}.txt\"; } &> \"${outputDir_log}/rec_${packageName}_${jobNo}.log\"" >> "${outputFile}"
					ChangeLineEndingsFromWindowsToUnix "${outputFile}"
					chmod +x "${outputFile}"

			done
			echo


	# * ===================================== * #
	# * ------- Final terminal output ------- * #
	# * ===================================== * #
		PrintSuccess "Succesfully created ${nJobs} \"${packageName}\" job files with ${nEventsPerJob} events each\n  in folder \"${outputDir_sub}\""

	SubmitJobs "${outputSubdir}" "${packageName}_mc"
}