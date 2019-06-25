#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: Batch create jobOption files based on a template
# *        AUTHOR: Remco de Boer (@IHEP), EMAIL: remco.de.boer@ihep.ac.cn
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 8 November 2018
# * ===============================================================================

source "${BOSS_StarterKit}/setup/FunctionsPrint.sh"
source "${BOSS_StarterKit}/setup/Functions.sh"
source "${BOSS_JobSubmitter}/utilities/CreateFilenameInventory.sh"
source "${BOSS_JobSubmitter}/utilities/SubmitJobs.sh"

function CreateAnaJobFiles()
{
	local currentPath="$(pwd)"
	# * ================================ * #
	# * ------- Check parameters ------- * #
	# * ================================ * #
		cd "${BOSS_JobSubmitter}"
		if [[ $? != 0 ]]; then return 1; fi
		CheckIfFolderExists "${BOSS_JobSubmitter}"
		[[ $? != 0 ]] && return 1
		CheckIfFolderExists "${BOSS_StarterKit_OutputDir}"
		[[ $? != 0 ]] && return 1
		CheckIfFileExists "${templateFile_ana}"
		[[ $? != 0 ]] && return 1


	# * =============================== * #
	# * ------- Input arguments ------- * #
	# * =============================== * #
		local input
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
		local inputJobOptions="${!packageNameCAP}/share/${packageName}.job"
		if [[ ! -f ${inputJobOptions} ]]; then
			echo "(+) Default input job options \"${inputJobOptions}\" does not exist. Which input file to use instead?"
			read -e -p "" -i "$(dirname ${inputJobOptions})/" inputJobOptions
			if [[ ! -f "${inputJobOptions}" ]]; then
				PrintError "File \"${inputJobOptions}\" does not exist"
				return 1
			fi
			echo "${inputJobOptions}" >> "${ofile}"
		fi

		read -e -p "(+) From which file or directory should the DST files be loaded? (default: \"directories/incl/Jpsi2009\") " input
		echo "${input}" >> "${ofile}"
		local inputFiles="${input:-directories/incl/Jpsi2009}"
		if [[ ! -e "${inputFiles}" ]]; then
			PrintError "File or directory \"${inputFiles}\" does not exist"
			return 1
		fi

		read -p "(+) What should be the maximum number of DST files per job? (default: 100) " input
		echo "${input}" >> "${ofile}"
		local nFilesPerJob="${input:-100}"

		read -p "(+) How many events per job? (default: -1 [all events]) " input
		echo "${input}" >> "${ofile}"
		local nEventsPerJob="${input:--1}"

		read -p "(+) What should be the message print level? (default: 4 [MSG::WARNING]) " input
		echo "${input}" >> "${ofile}"
		local outputLevel="${input:-4}"



	# * ===================================== * #
	# * ------- Create file inventory -------  * #
	# * ====================================== * #
		local identifier="${inputFiles//\//_}"
		if [[ -d "${inputFiles}" ]]; then
			CreateFilenameInventoryFromDirectory "${inputFiles}" "${BOSS_JobSubmitter}/filenames/${identifier}.txt" ${nFilesPerJob} "dst"
			if [[ $? != 0 ]]; then
				PrintError "Function CreateFilenameInventoryFromDirectory failed"
				return 1
			fi
		elif [[ -f "${inputFiles}" ]]; then
			CreateFilenameInventoryFromFile "${inputFiles}" "${BOSS_JobSubmitter}/filenames/${identifier}.txt" ${nFilesPerJob} "dst"
			if [[ $? != 0 ]]; then
				PrintError "Function CreateFilenameInventoryFromFile failed"
				return 1
			fi
		else
			PrintError "Input \"${inputFiles}\" is neither file nor directory"
			return 1
		fi
		searchTerm="filenames/${identifier}_???.txt"
		{ ls ${searchTerm}; } &> /dev/null
		if [ $? != 0 ]; then
			PrintError "Search string\n  \"${searchTerm}\"\nhas no matches: failed to create file inventory"
			return 1
		fi


	# * ============================= * #
	# * ------- Main function ------- * #
	# * ============================= * #

		# * Output directories
			outputDir_ana="${BOSS_JobSubmitter}/ana/${packageName}/${identifier}"
			outputDir_rec="${BOSS_JobSubmitter}/rec/${packageName}/${identifier}"
			outputDir_sub="${BOSS_JobSubmitter}/sub/${packageName}/${identifier}"
			outputDir_root="${BOSS_StarterKit_OutputDir}/root/${packageName}"
			outputDir_log="${BOSS_StarterKit_OutputDir}/log/${packageName}"

		# * User input * #
			nJobs=$(ls ${searchTerm} | wc -l)
			echo "This will create \"${packageName}_*.txt\" analysis job option files with ${nEventsPerJob} events each."
			echo "These files will be written to folder:"
			echo "   \"${outputDir_ana}\""
			echo "   \"${outputDir_sub}\""
			echo
			echo "DST files will be loaded from the ${nJobs} files matching this search pattern:"
			echo "   \"${searchTerm}\""
			if [ ${nJobs} -lt 0 ]; then
				echo
				echo "  --> Total number of events: $(printf "%'d" $((${nJobs} * ${nEventsPerJob})))"
			fi
			echo
			AskForInput "Write ${nJobs} \"${packageName}\" analysis job files?"
			[[ $? != 0 ]] && return 1
			echo "${input}" >> "${ofile}"

		# * Create and EMPTY scripts directory * #
			CreateOrEmptyDirectory "${outputDir_ana}"
			CreateOrEmptyDirectory "${outputDir_sub}"
		# * Create and EMPTY output directory * #
			mkdir -p "${outputDir_log}"
			mkdir -p "${outputDir_root}"

		# * Loop over input files * #
			jobNo=0 # set counter
			for file in $(ls ${searchTerm}); do
				echo "Adding DST files from \"$(basename "${file}")\" to \"ana_${packageName}_${jobNo}.txt\""

				# * Format file for implementation into vector
					FormatTextFileToCppVectorArguments "${file}"

				# * Generate the analysis files (ana)
					outputFile="${outputDir_ana}/ana_${packageName}_${jobNo}.txt"
					# Replace simple parameters in template
					awk '{flag = 1}
						{sub(/__INPUT_JOB_OPTIONS__/,"'${inputJobOptions}'")}
						{sub(/__PACKAGENAME__/,"'${packageName}'")}
						{sub(/__OUTPUTLEVEL__/,'${outputLevel}')}
						{sub(/__NEVENTS__/,'${nEventsPerJob}')}
						{sub(/__OUTPUTFILE__/,"'${outputDir_root}'/'${packageName}'_'${jobNo}'.root")}
						{if(flag == 1) {print $0} else {next} }' \
					"${templateFile_ana}" > "${outputFile}"
					# Fill in vector of input DST files
					sed -i "/__INPUTFILES__/{
						s/__INPUTFILES__//g
						r ${file}
					}" "${outputFile}"
					ChangeLineEndingsFromWindowsToUnix "${outputFile}"
					chmod +x "${outputFile}"

				# * Generate the submit files (sub)
					outputFile="${outputDir_sub}/sub_${packageName}_ana_${jobNo}.sh"
					echo "#!/bin/bash" > "${outputFile}" # empty file and write first line
					echo "{ boss.exe \"${outputDir_ana}/ana_${packageName}_${jobNo}.txt\"; } &> \"${outputDir_log}/ana_${packageName}_${jobNo}.log\"" >> "${outputFile}"
					ChangeLineEndingsFromWindowsToUnix "${outputFile}"
					chmod +x "${outputFile}"

				# * Increase counter
					jobNo=$((jobNo + 1))

			done
		echo


	# * ===================================== * #
	# * ------- Final terminal output ------- * #
	# * ===================================== * #
		PrintSuccess \
			"Succesfully created ${jobNo} \"${packageName}\" job files with ${nEventsPerJob} events each in folder:\n  \"${outputDir_ana}\""


	SubmitJobs "${packageName}/${identifier}" "${packageName}_ana"
	cd "${currentPath}"
}