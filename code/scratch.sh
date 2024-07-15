
recon file           - /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol591/data/usc_disc_yt_2023_03_31_091814_multi_slice_golden_angle_spiral_ssfp_slice_24_fov_240_n30_rlt_arms07_armshared00_ttv0p0200_stv0p0020_fov560.mat
recon file           - /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol591/data/usc_disc_yt_2023_03_31_093945_multi_slice_golden_angle_spiral_ssfp_slice_20_fov_240_n30_rlt_arms07_armshared00_ttv0p0200_stv0p0020_fov560.mat


sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    volId='vol592'; reconName='rlt'; script_all_stacks_realtime_recon; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal_cmr_4d')); \
    reconDir = '/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol591'; \
    dataDir = fullfile(reconDir,'data'); \
    niiFiles = dir(fullfile(dataDir,'s*_rlt_ab.nii.gz')); \
    matFiles = dir(fullfile(dataDir,'usc_disc_yt_*_rlt_arms*_*.mat')); \
    assert(numel(niiFiles)==numel(matFiles),'number of mat files does not match number of reference nifti files'); \
    for iF = 1:numel(matFiles), \
        load(fullfile(matFiles(iF).folder,matFiles(iF).name)); \
        R = rmfield(R,'imageFrames'); \
        save(fullfile(dataDir,strcat(niiFiles(iF).name(1:4),'rlt_recon.mat')), 'R', '-v7.3' ); \
    end; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    volId='vol590_120um'; reconName='dc'; script_all_stacks_realtime_recon; \
    volId='vol522_120um'; reconName='dc'; script_all_stacks_realtime_recon; \
    volId='vol547_120um'; reconName='dc'; script_all_stacks_realtime_recon; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol591/data/usc_disc_yt_*_dc_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); try, script_save_stack_to_file; catch, end,; end; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca


sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol590_120um/data/usc_disc_yt_*_dc_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/usc_disc_yt_*_dc_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/usc_disc_yt_*_dc_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    volId='vol830'; \
    reconName='rlt'; \
    script_all_stacks_realtime_recon; \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol830/data/usc_disc_yt_*_rlt_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); \
    volId='vol522_120um'; \
    reconName='rlt'; \
    script_all_stacks_realtime_recon; \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/usc_disc_yt_*_rlt_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    volId='vol547_120um'; \
    reconName='rlt'; \
    script_all_stacks_realtime_recon; \
    reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/usc_disc_yt_*_rlt_*.mat'); \
    for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; \
    exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca


reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526/data/usc_disc_yt_*_dc_*.mat');
for iRMF = 1:numel(reconMatFiles), 
    reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); 
    script_save_stack_to_file; 
end

reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/usc_disc_yt_*_rlt_arms_07_*.mat');
for iRMF = 1:numel(reconMatFiles), 
    reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); 
    script_save_stack_to_file; 
end

matlab -nodisplay -nosplash -nodesktop -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); volId='vol526'; reconName='dc'; script_all_stacks_realtime_recon; reconName='rlt'; script_all_stacks_realtime_recon; reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/usc_disc_yt_*_rlt_arms07_*.mat'); for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); volId='vol526'; reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/usc_disc_yt_*_dc_*.mat'); for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); script_save_stack_to_file; end; exit" -c 27000@imaginglab-mgt.ccm.sickkids.ca

sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); volId='vol572'; reconName='dc'; script_all_stacks_realtime_recon; reconName='rlt'; script_all_stacks_realtime_recon; reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/usc_disc_yt_*_rlt_arms07_*.mat'); for iRMF = 1:numel(reconMatFiles), reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name);     script_save_stack_to_file; end" -c 27000@imaginglab-mgt.ccm.sickkids.ca

# get dicom files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*.IMA' --include '*/*/*.dcm' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0830_20240320/dicom_hawk/*/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol830/data/ref_dcm/

mv vol830/data/ref_dcm/*/* vol830/data/ref_dcm/
find vol830/data/ref_dcm/ -empty -type d -delete

# get raw data .mat files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.mat' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0526_20221214/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526/data/raw/

# get video files
rsync -avz --progress --itemize-changes --prune-empty-dirs jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0526_20221214/video_data/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526/videos/usc/


rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.mat' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0522_20221209/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/raw/

rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*.IMA' --include '*/*/*.dcm' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0522_20221209/dicom_hawk/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/ref_dcm/

rsync -avz --progress --itemize-changes --prune-empty-dirs jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0522_20221209/video_data/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/videos/usc/

# organize dicom files
mv vol572/data/ref_dcm/*/* vol572/data/ref_dcm/
find vol572/data/ref_dcm/ -empty -type d -delete

# get raw data .mat files

# or, get raw .dat files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.dat' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.dat' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0572_20230223/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/raw/

# get video files
rsync -avz --progress --itemize-changes --prune-empty-dirs jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0572_20230223/video_data/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/videos/usc/



rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0547_20230202/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/raw/

rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*.IMA' --include '*/*/*.dcm' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0547_20230202/dicom_hawk/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/ref_dcm/

mv /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/ref_dcm/*/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/ref_dcm/
find /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol547_120um/data/ref_dcm/ -empty -type d -delete

mv /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/ref_dcm/*/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/ref_dcm/
find /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol522_120um/data/ref_dcm/ -empty -type d -delete

rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*.IMA' --include '*/*/*.dcm' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0526_20221214/dicom_hawk/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526/data/ref_dcm/

mv vol572/data/ref_dcm/*/* vol572/data/ref_dcm/
find vol572/data/ref_dcm/ -empty -type d -delete


rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0590_20230330/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol590_120um/data/raw/




rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0591_20230331/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol591/data/raw/

rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0592_20230331/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol592/data/raw/




      

sudo singularity exec --bind /mnt/hpc-cmacgowan/fetal_spiral_ssfp_055t /mnt/hpc-cmacgowan/fetal_spiral_ssfp_055t/container/svrtk_w_jinc_psf.sif /mnt/hpc-cmacgowan/fetal_spiral_ssfp_055t/code/fetal_cmr_4d/4drecon/recon_ref_vol.bash /mnt/hpc-cmacgowan/fetal_spiral_ssfp_055t/vol572


sudo docker run --rm --mount type=bind,source=/home/imaginglab/data/transit/2007,target=/home/data fetalsvrtk/svrtk /bin/bash -c "source ~/.bashrc && cd /home/data/svr_trunk_02_all-brain-and-trunk-stacks_dockerhub && mirtk recon

sudo docker run --rm --mount type=bind,source=/home/imaginglab/data/transit/2007,target=/home/data fetalsvrtk/svrtk /bin/bash -c "source ~/.bashrc && cd /home/data/svr_trunk_02_all-brain-and-trunk-stacks_dockerhub && mirtk reconstruct rec-SVR_T2w.nii.gz 18 ../data/HASTE_FetalBrainCor_TCHD_s006.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s007.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s012.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s013.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s004.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s005.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s010.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s011.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s027.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s028.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s033.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s034.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s029.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s030.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s035.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s036.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s032.nii.gz -mask ../data/s031_mask.nii.gz -template ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz -thickness 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 -svr_only -resolution 0.66 -iterations 3 -remote > log-main.txt"


sudo singularity exec --bind /home/imaginglab/data/transit/2007:/data /home/imaginglab/data/transit/containers/svrtk-latest.sif "source ~/.bashrc && cd /home/data/svr_trunk_03_all-brain-and-trunk-stacks_svrtk-latest-singularity && mirtk reconstruct rec-SVR_T2w.nii.gz 18 ../data/HASTE_FetalBrainCor_TCHD_s006.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s007.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s012.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s013.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s004.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s005.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s010.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s011.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s027.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s028.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s033.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s034.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s029.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s030.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s035.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s036.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s032.nii.gz -mask ../data/s031_mask.nii.gz -template ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz -thickness 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 -svr_only -resolution 0.66 -iterations 3 -remote > log-main.txt"



mirtk reconstruct ../outputSVR.nii.gz  5 ../stack1.nii.gz ../stack2.nii.gz ../stack3.nii.gz ../stack4.nii.gz ../stack5.nii.gz -mask ../mask.nii.gz  -template ../stack3.nii.gz -thickness 2.5 2.5 2.5 2.5 2.5 -svr_only -resolution 0.75 -iterations 3 

mirtk reconstructFFD ../outputDSVR.nii.gz 6 ../stack1.nii.gz ../stack2.nii.gz ../stack3.nii.gz ../stack4.nii.gz ../stack5.nii.gz ../stack6.nii.gz -mask ../mask.nii.gz -template ../template-stack.nii.gz -thickness 2.5 2.5 2.5 2.5 2.5 2.5 -default -resolution 0.85

sudo singularity exec --bind /home/imaginglab/data/transit/2007:/data /home/imaginglab/data/transit/containers/svrtk-latest.sif 

#!/usr/bin/env bash
#
# e.g., run as 
#   $ sudo singularity exec --bind /home/imaginglab/data/transit/2007:/data /home/imaginglab/data/transit/containers/svrtk-latest.sif 

ORIG_PATH=$(pwd)

cd /data/svr_trunk_04_all-brain-and-trunk-stacks_svrtk-latest-singularity_dsvr

mirtk reconstructFFD rec-SVR_T2w.nii.gz 18 ../data/HASTE_FetalBrainCor_TCHD_s006.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s007.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s012.nii.gz ../data/HASTE_FetalBrainCor_TCHD_s013.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s004.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s005.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s010.nii.gz ../data/HASTE_FetalBrainSag_TCHD_s011.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s027.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s028.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s033.nii.gz ../data/HASTE_FetalTrunkAx_TCHD_s034.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s029.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s030.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s035.nii.gz ../data/HASTE_FetalTrunkCor_TCHD_s036.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz ../data/HASTE_FetalTrunkSag_TCHD_s032.nii.gz -mask ../data/s031_mask.nii.gz -template ../data/HASTE_FetalTrunkSag_TCHD_s031.nii.gz -thickness 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 -default -resolution 0.66 -iterations 3 > log-main.txt

cd $ORIG_PATH






reconDir = '/hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data'; S = preproc_fetal_spiral_ssfp( reconDir ); save( fullfile( reconDir, 'data', 'results.mat' ), 'S', '-v7.3' ); clear S;