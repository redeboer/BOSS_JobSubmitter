#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: Batch create jobOption files based on a template
# *        AUTHOR: Remco de Boer <remco.de.boer@ihep.ac.cn>
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 22 October 2018
# *         USAGE: bash CreateJobFiles.sh <package name> <number of jobs> <number of events> <output level>
# *     ARGUMENTS:
# *       1) package name (default is "D0phi_KpiKK")
# *       2) number of job files to be created (default is 25)
# *       3) number of events per job (default is 10,000)
# *       4) terminal output level (default is 4)
# *          2=DEBUG, 3=INFO, 4=WARNING, 5=ERROR, 6=FATAL
# * ===============================================================================

set -e # exit if a command or function exits with a non-zero status
source "${BOSS_StarterPack}/setup/FunctionsPrint.sh"
source "${BOSS_StarterPack}/setup/Functions.sh"


# ! ================================ ! #
# ! ------- Script arguments ------- ! #
# ! ================================ ! #
	# * (1) Package name
	packageName="${1:-RhopiAlg}"
	# * (2) Number of jobOption files and submit scripts that need to be generated
	nJobs=${2:-25}
	# * (3) Number of events per job
	nEventsPerJob=${3:-10000}
	# * (4) Terminal message output level
	outputLevel=${4:-4} # default argument: 4 (MSG::WARNING)
	# * (5) Output subdirectory
	outputSubdir="${5:-packageName}"


# * ================================= * #
# * ------- Script parameters ------- * #
# * ================================= * #
	scriptFolder="${BOSS_StarterPack}/jobs" # contains templates and will write scripts to its subfolders
	decayCardDir="${scriptFolder}/dec"
	templateFile_sim="${scriptFolder}/templates/simulation.txt"
	templateFile_rec="${scriptFolder}/templates/reconstruction.txt"


# * =============================================== * #
# * ------- Check arguments and parameters -------  * #
# * =============================================== * #
	CheckIfFolderExists "${scriptFolder}"
	CheckIfFolderExists "${BOSS_StarterPack_OutputDir}"
	CheckIfFolderExists "${decayCardDir}"
	CheckIfFileExists "${templateFile_sim}"
	CheckIfFileExists "${templateFile_rec}"


# * ============================= * #
# * ------- Main function ------- * #
# * ============================= * #

	# * Output directories
		outputDir_sim="${scriptFolder}/sim/${outputSubdir}"
		outputDir_rec="${scriptFolder}/rec/${outputSubdir}"
		outputDir_sub="${scriptFolder}/sub/${outputSubdir}_mc"
		outputDir_raw="${BOSS_StarterPack_OutputDir}/raw/${outputSubdir}"
		outputDir_dst="${BOSS_StarterPack_OutputDir}/dst/${outputSubdir}"
		outputDir_log="${BOSS_StarterPack_OutputDir}/log/${outputSubdir}"

	# * User input
		echo "This will create ${nJobs} \"${packageName}\" simulation and reconstruction job option files with ${nEventsPerJob} events each in job."
		echo "These files will be written to folder:"
		echo "   \"${outputDir_sim}\""
		echo "   \"${outputDir_rec}\""
		echo "   \"${outputDir_sub}\""
		echo
		echo "  --> Total number of events: $(printf "%'d" $((${nJobs} * ${nEventsPerJob})))"
		echo
		AskForInput "Write ${nJobs} \"${packageName}\" simulation and reconstruction job files?"

	# * Create and EMPTY output directories
		CreateOrEmptyDirectory "${outputDir_sim}"
		CreateOrEmptyDirectory "${outputDir_rec}"
		CreateOrEmptyDirectory "${outputDir_sub}"
		mkdir -p "${outputDir_raw}"
		mkdir -p "${outputDir_dst}"
		mkdir -p "${outputDir_log}"

	# * Loop over jobs
	for jobNo in $(seq 0 $((${nJobs} - 1))); do

		echo -en "\e[0K\rCreating files for job $(($jobNo+1))/${nJobs}..." # overwrite previous line

		# * Generate the simulation files (sim)
			randomSeed=$(($(date +%s%N) % 1000000000)) # random seed based on system time
			outputFile="${outputDir_sim}/sim_${packageName}_${jobNo}.txt"
			awk '{flag = 1}
				{sub(/__RANDSEED__/,'${randomSeed}')}
				{sub(/__OUTPUTLEVEL__/,'${outputLevel}')}
				{sub(/__DECAYCARD__/,"'${decayCardDir}'/'${packageName}'.dec")}
				{sub(/__OUTPUTFILE__/,"'${outputDir_raw}'/'${packageName}'_'${jobNo}'.rtraw")}
				{sub(/__NEVENTS__/,'${nEventsPerJob}')}
				{if(flag == 1) {print $0} else {next} }' \
			${templateFile_sim} > "${outputFile}"
			ChangeLineEndingsFromWindowsToUnix "${outputFile}"
			chmod +x "${outputFile}"

		# * Generate the reconstruction files (rec)
			outputFile="${outputDir_rec}/rec_${packageName}_${jobNo}.txt"
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
			outputFile="${outputDir_sub}/sub_${packageName}_mc_${jobNo}.sh"
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

set +e # exit if a command or function exits with a non-zero status