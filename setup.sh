scriptPath="$(dirname "${BASH_SOURCE[0]}")"
if [[ -z "${BOSS_StarterKit}" ]]; then
  echo -e "\e[31;1mFATAL ERROR in loading \"${scriptPath}\": BOSS Starter Kit has not been set up\e[0m"
  exit 1
fi

currentPath="$(pwd)"
cd "${scriptPath}"

repoName=$(basename $(git config --get remote.origin.url))
repoName=${repoName/.git/}
export ${repoName}="$(pwd)"
alias cdjobs="cd ${BOSS_JobSubmitter}"
alias reloadjobsubmitter="source ${BOSS_JobSubmitter}/setup.sh"

export templateFile_ana="${BOSS_JobSubmitter}/templates/analysis.job"
export templateFile_rec="${BOSS_JobSubmitter}/templates/reconstruction.job"
export templateFile_sim="${BOSS_JobSubmitter}/templates/simulation.job"

source "utilities/Aliases.sh"
source "utilities/CreateAnaJobFiles.sh"
source "utilities/CreateSimJobFiles.sh"
source "utilities/CleanupJobs.sh"

cd "${currentPath}"
