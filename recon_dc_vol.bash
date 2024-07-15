#!/usr/bin/env bash

# Set bash strict mode (see: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/)
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# Usage
usage() {
  cat << EOF

Usage: $(basename "${BASH_SOURCE[0]}") [options] recondir voldesc

Create (and run) command to perform slice-to-volume reconstrution (SVR) on stacks of time-averaged images 
using SVRTK application reconstructCardiac.

Expects directory structure with input stacks and masks as follows: 

    recondir
    ├── data
    │   ├── s*_dc_ab.nii.gz
    │   ├── force_exclude_frame.txt
    │   ├── force_exclude_slice.txt
    │   ├── force_exclude_stack.txt
    │   ├── slice_thickness.txt
    │   └── tgt_stack_no.txt
    └── mask
        └── mask_chest.nii.gz

This helper script creates a reconstruction command script in output directory recondir/voldesc/recon.bash 
and (optionally) runs the reconstruction.

Available options:

  parameters
    --resolution [res]  Isotropic resolution of reconstructed volume
    --nmc [n]           Number of motion-correction iterations
    --nsr [n]           Number of super-resolution reconstruction iterations
    --nsrlast [n]       Number of super-resolution reconstruction iterations following last motion-correction iteration
    --lambda [l]        Smoothing parameter for super-resolution reconstruction
    --lambdalast [l]    Smoothing parameter for super-resolution reconstruction following last motion-correction iteration

  
  flags
    --robuststatistics  Use robust statistics outlier rejection
    --nodebug           Don't save intermediate results
    --noscript          Output recon command, but don't create reconstruction script
    --noeval            Do not evaluate the reconstruction commands
    --help              Print this usage text and exit

EOF
  exit
}

# Parse Input Parameters
parse_params() {
  
  ORIG_PATH=$(pwd)

  # default values
  RESOLUTION=1.25
  NMC=6
  NSR=10
  NSRLAST=20
  LAMBDAFLAG=0
  LAMBDALASTFLAG=0
  NUMCARDPHASE=1
  ROBUSTSTATISTICSFLAG=0
  DEBUGFLAG=1
  SCRIPTFLAG=1
  EVALFLAG=1

  # if no arguments, show usage and exit
  if [ $# -eq 0 ] ; then
    usage
  fi

  # parse flags and parameter inputs 
  while :; do
    case "${1-}" in
    --help) usage ;;
    --resolution)
      RESOLUTION="${2-}"
      shift
      ;;
    --nmc)
      NMC="${2-}"
      shift
      ;;
    --nsr)
      NSR="${2-}"
      shift
      ;;
    --nsrlast)
      NSRLAST="${2-}"
      shift
      ;;
    --lambda)
      LAMBDAFLAG=1
      LAMBDA="${2-}"
      shift
      ;;
    --lambdalast)
      LAMBDALASTFLAG=1
      LAMBDALAST="${2-}"
      shift
      ;;    
    --robuststatistics) ROBUSTSTATISTICSFLAG=1 ;;
    --nodebug) DEBUGFLAG=0 ;;
    --noscript) SCRIPTFLAG=0 ;;
    --noeval) EVALFLAG=0 ;;
    -?*) echo "Unknown option: $1" && exit;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required arguments and parameters
  [[ ${#args[@]} -ne 2 ]] && echo "Missing script argument(s); expected two arguments" && exit

  # assign positional arguments to variables
  RECONDIR=$1
  VOLDESC=$2

  return 0
}

# Cleanup
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  
  # reset working directory
  cd "$ORIG_PATH"

}

# ================================= MAIN SCRIPT =================================


# Parse Parameters

parse_params "$@"


# Check that Recon Directory Exists

if [[ ! -d "$RECONDIR" ]]; then
  echo directory "$RECONDIR" does not exist
  exit 1
else


# Manage Paths

RECONVOLDIR=$RECONDIR/$VOLDESC
mkdir -p "$RECONVOLDIR"
cd "$RECONVOLDIR"

echo
echo RECON DC VOLUME


# Variables 

RECON=$VOLDESC.nii.gz
STACKS="../data/s*_dc_ab.nii.gz"
THICKNESS=$(cat ../data/slice_thickness.txt)
MASKDCVOL="../mask/mask_chest.nii.gz"
TGTSTACKNO=$(cat ../data/tgt_stack_no.txt)
EXCLUDESTACKFILE="../data/force_exclude_stack.txt"
EXCLUDESLICEFILE="../data/force_exclude_slice.txt"
STACKDOFDIR="stack_transformations"
DOFOUTDIR="slice_transformations"

echo reconstructing DC volume: "$RECONVOLDIR"/"$RECON"


# Setup

ITER=$(($NMC+1))
NUMSTACK=$(ls ../data/s*_dc_ab.nii.gz | wc -w);
if [[ ! -f "$EXCLUDESTACKFILE" ]]; then
  EXCLUDESTACK=""
  NUMEXCLUDESTACK=0
else
  EXCLUDESTACK=$(cat $EXCLUDESTACKFILE)
  NUMEXCLUDESTACK=$(eval "wc -w $EXCLUDESTACKFILE | awk -F' ' '{print \$1}'" )
fi
if [[ ! -f "$EXCLUDESLICEFILE" ]]; then
  EXCLUDESLICE=""
  NUMEXCLUDESLICE=0
else
  EXCLUDESLICE=$(cat $EXCLUDESLICEFILE)
  NUMEXCLUDESLICE=$(eval "wc -w $EXCLUDESLICEFILE | awk -F' ' '{print \$1}'" )
fi
if [[ "$SCRIPTFLAG" -eq 0 ]]; then
  EVALFLAG=0
fi

# Reconstruct DC Volume Command

CMD="mirtk reconstructCardiac $RECON $NUMSTACK $STACKS "
CMD+=$'\\\n'"    -thickness $THICKNESS "
CMD+=$'\\\n'"    -stack_registration "
CMD+=$'\\\n'"    -target_stack $TGTSTACKNO "
CMD+=$'\\\n'"    -mask $MASKDCVOL "
CMD+=$'\\\n'"    -iterations $ITER "
CMD+=$'\\\n'"    -rec_iterations $NSR "
CMD+=$'\\\n'"    -rec_iterations_last $NSRLAST "
CMD+=$'\\\n'"    -resolution $RESOLUTION "
if [[ $LAMBDAFLAG -eq 1 ]]; then
  CMD+=$'\\\n'"    -lamba $LAMBDA "
fi
if [[ $LAMBDALASTFLAG -eq 1 ]]; then
  CMD+=$'\\\n'"    -lastiter $LAMBDALAST "
fi
if [[ $NUMEXCLUDESTACK -ne 0 ]]; then
  CMD+=$'\\\n'"    -force_exclude_stack $NUMEXCLUDESTACK $EXCLUDESTACK "
fi
if [[ $NUMEXCLUDESLICE -ne 0 ]]; then
  CMD+=$'\\\n'"    -force_exclude_sliceloc $NUMEXCLUDESLICE $EXCLUDESLICE "
fi
CMD+=$'\\\n'"    -numcardphase $NUMCARDPHASE "
if [[ $ROBUSTSTATISTICSFLAG -eq 0 ]]; then
  CMD+=$'\\\n'"    -no_robust_statistics "
fi
if [[ $DEBUGFLAG -eq 1 ]]; then
  CMD+=$'\\\n'"    -debug "
fi
CMD+=$'\\\n'"        > log-main.txt " 
echo volume reconstruction command: 
echo "  $CMD"


# Create Reconstruction Script

if [[ $SCRIPTFLAG -eq 1 ]]; then

cat << EOF > recon.bash
#!/usr/bin/env bash

# BASH Strict Mode

set -Eeuo pipefail

# SVR

$CMD

# Move Slice Transformation Files to Subdirectory

mkdir -p $DOFOUTDIR
mv transformation0*.dof $DOFOUTDIR

EOF

if [[ $DEBUGFLAG -eq 1 ]]; then
cat << EOF >> recon.bash
# Rearrange Debug Files

mkdir -p $STACKDOFDIR
mv stack-transformation0*.dof $STACKDOFDIR

mkdir -p sr_iterations
mv *_mc*sr* sr_iterations

EOF
fi

chmod u+x recon.bash  # ensure script is executable by user

else

  # remove empty reconvoldir if no script created 
  if [[ ! "$(ls -A $RECONVOLDIR)" ]]; then  
    cd "$ORIG_PATH"  	
    rm -r "$RECONVOLDIR"
  fi

fi

# Run Recon

if [[ $SCRIPTFLAG -eq 1 && $EVALFLAG -eq 1 ]]; then
  echo "running volume reconstruction: recon.bash"
  ./recon.bash
  echo "volume reconstruction complete"
elif [[ $SCRIPTFLAG -eq 1 && $EVALFLAG -eq 0 ]]; then
  echo "volume reconstruction script (recon.bash) created, but not evaluated"
elif [[ $SCRIPTFLAG -eq 0 && $EVALFLAG -eq 0 ]]; then
  echo "no reconstruction script (recon.bash) created"
fi
echo


# Finish

fi

