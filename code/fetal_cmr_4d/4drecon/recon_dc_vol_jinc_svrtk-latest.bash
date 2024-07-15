#!/usr/bin/env bash


# RECON DC VOLUME

# e.g., bash recon_dc_vol.bash ~/path/to/top/level/recon/directory/ dc_vol

# Set bash strict mode (see:https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/)
set -Eeuo pipefail

# Input 

RECONDIR=$1
VOLDESC=$2


# Check that Recon Directory Exists

if [ ! -d "$RECONDIR" ]; then
  echo directory $RECONDIR does not exist
  exit 1
else


# Manage Paths to Allow Queueing of Jobs using TaskSpooler

ORIG_PATH=$(pwd)
SCRIPT_PATH=$(dirname `which $0`)

RECONVOLDIR=$RECONDIR/$VOLDESC
mkdir -p $RECONVOLDIR
cd $RECONVOLDIR

echo RECON DC VOLUME
echo $RECONVOLDIR


# Variables 

RECON=$VOLDESC.nii.gz
STACKS="../data/s*_dc_ab.nii.gz"
THICKNESS=$(cat ../data/slice_thickness.txt)
MASKDCVOL="../mask/mask_chest.nii.gz"
TGTSTACKNO=$(cat ../data/tgt_stack_no.txt)
EXCLUDESTACKFILE="../data/force_exclude_stack.txt"
EXCLUDESLICEFILE="../data/force_exclude_slice.txt"
RESOLUTION=1
NMC=6
NSR=10
NSRLAST=20
NUMCARDPHASE=1
STACKDOFDIR="stack_transformations"
DOFOUTDIR="slice_transformations"

echo reconstructing DC volume: $RECONVOLDIR/$RECON


# Setup

ITER=$(($NMC+1))
NUMSTACK=$(ls -1 ../data/s*_dc_ab.nii.gz | wc -l);
EXCLUDESTACK=$(cat $EXCLUDESTACKFILE)
NUMEXCLUDESTACK=$(eval "wc -w $EXCLUDESTACKFILE | awk -F' ' '{print \$1}'" )
EXCLUDESLICE=$(cat $EXCLUDESLICEFILE)
NUMEXCLUDESLICE=$(eval "wc -w $EXCLUDESLICEFILE | awk -F' ' '{print \$1}'" )
echo "   target stack no.: "$TGTSTACKNO


# TODO: add optional flag strings if force_exclude is used
# -force_exclude_stack $EXCLUDESTACK 
# -force_exclude_sliceloc $EXCLUDESLICE

# Reconstruct DC Volume

CMD="mirtk reconstructCardiac $RECON $NUMSTACK $STACKS --spatialpsfjinc --thickness $THICKNESS --stack_registration --target_stack $TGTSTACKNO -mask $MASKDCVOL -iterations $ITER -rec_iterations $NSR -rec_iterations_last $NSRLAST -resolution $RESOLUTION  -numcardphase $NUMCARDPHASE -no_robust_statistics --debug > log-main.txt"
echo reconstructing DC volume: $CMD
echo $CMD > recon.bash
eval $CMD


# Clean Up

CMD="mkdir -p $STACKDOFDIR; mv stack-transformation0*.dof $STACKDOFDIR;"
echo $CMD >> recon.bash
eval $CMD

CMD="mkdir -p $DOFOUTDIR; mv transformation0*.dof $DOFOUTDIR;"
echo $CMD >> recon.bash
eval $CMD

CMD="mkdir -p sr_iterations; mv *_mc0${NMC}sr$(($NSRLAST-1))* sr_iterations; rm *_mc*sr*;"
echo $CMD >> recon.bash
eval $CMD


# Finish

echo "volume reconstruction complete"

cd $ORIG_PATH


fi

