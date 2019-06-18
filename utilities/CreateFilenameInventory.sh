#!/bin/bash -
source "${BOSS_StarterKit}/setup/Functions.sh"

function DeleteAllEmptyLines()
# Delete all empty lines in a file, including files that only contain whitespace characters
{
  # * Import function arguments
  local fileName=${1}
  # * Main function: delete all empty lines of the file
  sed -i '/^\s*$/d' ${fileName} # delete all empty lines of the file
}
export DeleteAllEmptyLines


function FormatTextFileToCppVectorArguments()
# Feed this function a text file, and it will prepend a `\t"` and append a `",` to each line. The comma is ommited for the last line.
{
  # * Import function arguments
  local fileName=${1}
  # * Execute function if lines 
  local numCorrect=$(grep "^\s*\"[^\"]*\",\s*$" "${fileName}" | wc -l) # does not include last line
  local numLines=$(cat "${fileName}" | sed '/^\s*$/d' | wc -l)
  if [ $numLines != $(($numCorrect+1)) ]; then
    DeleteAllEmptyLines ${fileName}
    sed -i -e "s/.*/\t\"&\",/" ${fileName} # convert lines to C++ vector arguments
    sed -i "$ s/.$//"          ${fileName} # remove last comma
  fi
}
export FormatTextFileToCppVectorArguments


function SplitTextFile()
# Feed this function a path to a text file ($1) and it will split up this file into separate files each with a maximum number of lines ($2 -- default value is 10).
{
  # * Import function arguments
    local fileToSplit="${1}"
    local maxNLines=${2:-10}
  # * Check arguments
    CheckIfFileExists "${fileToSplit}"
  # * Extract path, filename, and extension for prefix * #
    local path=$(dirname "${fileToSplit}")
    local filename=$(basename "${fileToSplit}")
    local extension="${filename/*.}"
    local filename="${filename%.*}"
    local prefix="${path}/${filename}_"
  # * Split input file * #
    rm -f "${prefix}"???".${extension}" #! remove existing files
    if [[ ! $maxNLines -gt 1 ]]; then
      mv "${fileToSplit}" "${prefix}000.${extension}"
      return 0
    fi
    echo "Splitting text file \"$(basename ${outputFile})\" to max $maxNLines lines each"
    split -d -a3 -l${maxNLines} "${fileToSplit}" "${prefix}"
  # * Append extension again (if original file has one) * #
  # shopt -s extglob # for regex
  for file in $(ls ${prefix}???); do #! number of ? should match the -a3 argument above
    DeleteAllEmptyLines "${file}"
    if [ "${filename}" != "${extension}" ]; then
      mv -f "${file}" "${file}.${extension}"
    fi
  done
  # ! REMOVE ORIGINAL FILE ! #
    rm "${fileToSplit}"
  PrintSuccess "Created $(ls ${prefix}???.${extension} | wc -l) text files that list input DST files"
}
export SplitTextFile


function CreateFilenameInventoryFromDirectory()
# Feed this function a path to a directory ($1) and it will list all files within that directory including their absolute paths. This list will be written to text files ($2) with a maximum number of paths per file ($3 -- default is 0, namely no max). If you wish, you can only list files of a certain extension ($4).
{
  # * Import function arguments * #
    local inputDirectory="${1:-directories/incl/Jpsi2009}"
    CheckIfFolderExists "${inputDirectory}"
    local outputFile="${inputDirectory//\//_}"
    if [[ "${outputFile:0:1}" == "_" ]]; then
      outputFile="${outputFile:1}"
    fi
    outputFile="${BOSS_JobSubmitter}/filenames/${outputFile}.txt"
    outputFile="${2:-outputFile}"
    CreateBaseDir "${outputFile}"
    local maxNLines=${3:-8}
    local extension="${4:-*}" # does not look for extensions by default
  # * Get absolute path of the input directory so that `find` lists absolute paths as well
    cd "${inputDirectory}"
    inputDirectory="$(pwd)"
    cd - > /dev/null
  # * Make an inventory and write to file
    find "${inputDirectory}" -iname "*.${extension}" | sort --version-sort > "${outputFile}"
    DeleteAllEmptyLines "${outputFile}"
  # * Split the output file if required
    if [[ $maxNLines -gt 0 ]]; then
      SplitTextFile "${outputFile}" ${maxNLines}
    fi
}
export CreateFilenameInventoryFromDirectory


function CreateFilenameInventoryFromFile()
# Feed this function a path ($1) to a file containing directories and/or file names and it will list all files within those directories including their absolute paths.  This list will be written to text files ($2) with a maximum number of paths per file ($3 -- default is 0, namely no max). If you wish, you can only list files of a certain extension ($4).
{
  # * Import function arguments * #
    local inputFile="${1}"
    local outputFile="${2}"
    local maxNLines=${3:-0}
    local extension="${4-*}"
  # * Check arguments * #
    CheckIfFileExists   "${inputFile}"
    DeleteAllEmptyLines "${inputFile}"
    CreateBaseDir "${outputFile}"
    local currentPath="$(pwd)"
  # * Get absolute path of input file * #
    CdToBaseDir "${inputFile}"
    inputFile="$(pwd)/$(basename "${inputFile}")"
    cd - > /dev/null
  # * Get absolute path of output file * #
    CdToBaseDir "${outputFile}"
    outputFile="$(pwd)/$(basename "${outputFile}")"
    cd - > /dev/null
  # * Make an inventory and write to file * #
    CdToBaseDir "${inputFile}" # in case of relative paths
    echo > "${outputFile}" # empty output file
    { cat "${inputFile}"; echo; } | while read line; do
      # * Check if empty line *
      if [ "${line}" != "" ]; then
        # * If line is a file, just add it to the output file
        if [ -f "${line}" ]; then
          echo "Added file \"$(basename ${line}\")"
          echo "${line}" >> "${outputFile}"
        # * Otherwise, presume line is a directory and add its contents
        elif [ -d "${line}" ]; then # check if directory exists
          CreateFilenameInventoryFromDirectory "${line}" "temp.txt" 0 "${extension}"
          cat "temp.txt" >> "${outputFile}"
          echo "Added directory \"$(basename ${line}\") ($(cat temp.txt | wc -l) files)"
          rm "temp.txt"
        # * Error moessage if nothing
        else
          PrintError "WARNING: \"${line}\" does not exist"
        fi
      fi
    done
  # * Finalise output file * #
    DeleteAllEmptyLines "${outputFile}"
    PrintSuccess "\nRead $(cat "${outputFile}" | wc -l) files and directories from file \""${inputFile}"\""
    PrintSuccess "--> output written to \"$(basename "${outputFile}")\"\n"
  # * Split the output file if required
    SplitTextFile "${outputFile}" ${maxNLines}
  # * Go back to starting directory * #
    cd "${currentPath}"
}
export CreateFilenameInventoryFromFile