#!/bin/bash -
# * ===============================================================================
# *   DESCRIPTION: This example script shows (1) how create inventory files
# *                listing dst files and (2) how to use those to create a job
# *                files for data analysis. It is desinged to illustrate the use
# *                of functions in the CommonFunctions.sh script.
# *        AUTHOR: Remco de Boer <remco.de.boer@ihep.ac.cn>
# *  ORGANIZATION: IHEP, CAS (Beijing, CHINA)
# *       CREATED: 23 November 2018
# *         USAGE: bash ExampleScript_CreateDataJoboptions.sh
# * ===============================================================================

source "${BOSS_StarterPack}/setup/FunctionsPrint.sh"
source "${BOSS_StarterPack}/setup/Functions.sh"

# * Scripts parameters * #
packageName="${1:-RhopiAlg}"
nJobs=${2:-100}
nEventsPerJob=${3:-10000}
outputLevel=4
outputSubdir="${packageName}/$(printf "%'d" $((${nJobs} * ${nEventsPerJob})))_events"

# * Create job from template and submit * #
bash CreateJobFiles_sim.sh "${packageName}" ${nJobs} ${nEventsPerJob} ${outputLevel} "${outputSubdir}" && \
bash SubmitAll.sh "${outputSubdir}_mc" "${packageName}_mc"