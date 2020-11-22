datDir="/scratchfs/bes/$USER/data/$ext"
scrDir="/besfs/users/$USER/BOSS_StarterKit/jobs/sub"
subDir="${1:-JpsiToDPV/directories/incl/Jpsi2012}"
ext="${2:-root}"
type="${3:-ana}"

max=$(ls ${scrDir}/${subDir} | grep -E "sub\_JpsiToDPV\_${type}\_[0-9]+\.sh$" | wc -l)
max=$(expr $max - 1)

for i in $(seq 0 $max); do
  [[ -f "${datDir}/${subDir}/JpsiToDPV_$i.$ext" ]] && continue
  hep_sub -g physics "${scrDir}/${subDir}/sub_JpsiToDPV_${type}_$i.sh"
done
