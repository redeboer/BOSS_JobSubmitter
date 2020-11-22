#!/bin/bash -
source "${BOSS_StarterKit}/setup/FunctionsPrint.sh"

function CleanupJobs() {
  local listsim=$(find sim -type f -iname "sim_*.txt")
  local listrec=$(find rec -type f -iname "rec_*.txt")
  local listana=$(find ana -type f -iname "ana_*.txt")
  local listsub=$(find sub -type f -iname "sub_*.sh")
  local nfiles=$(find filenames -type f | wc -l)
  echo "This will remove all files in:"
  echo "  \"${BOSS_JobSubmitter}/sim\" ($(echo ${listsim} | wc -w) files)"
  echo "  \"${BOSS_JobSubmitter}/rec\" ($(echo ${listrec} | wc -w) files)"
  echo "  \"${BOSS_JobSubmitter}/ana\" ($(echo ${listana} | wc -w) files)"
  echo "  \"${BOSS_JobSubmitter}/sub\" ($(echo ${listsub} | wc -w) files)"
  echo "  \"${BOSS_JobSubmitter}/filenames\" ($nfiles files)"
  AskForInput "Continue?"
  currentPath="$(pwd)"
  cd "${BOSS_JobSubmitter}" \
    && rm -f $(find sim -type f -iname "sim_*.txt") \
    && rm -f $(find rec -type f -iname "rec_*.txt") \
    && rm -f $(find ana -type f -iname "ana_*.txt") \
    && rm -f $(find sub -type f -iname "sub_*.sh") \
    && rm -f filenames/* \
    && find . -empty -type d -delete \
    && cd "${currentPath}"
}
export CleanupJobs
