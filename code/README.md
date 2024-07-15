

## Data 

NOTE: refer to vol*_recon_commands.bash notes for each case for most up to date info

### Raw Data and Dicoms 

Available from lauterbur.usc.edu::disc_fetal.

To list files:
```shell
# in general
rsync --list-only jvanamerom@lauterbur.usc.edu::disc_fetal/

# all raw files available
rsync --list-only --relative jvanamerom@lauterbur.usc.edu::disc_fetal/vol*/raw_hawk/usc_disc_yt_*_multi_slice_golden_angle_spiral_ssfp_slice_*_raw.dat

# all processed raw data .mat files with at least 15 slices available
rsync --list-only --relative jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol*/raw_hawk/usc_disc_yt_*_multi_slice_golden_angle_spiral_ssfp_slice_*_slice_15.mat
```

rsync most important files, e.g., on data.ccm.sickkids.ca:
```shell
cd /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t

# create case directory if it doesn't already exist
cp -r volTemplate vol572

# get dicom files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*.IMA' --include '*/*.dcm' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0572_20230223/dicom_hawk/*/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/ref_dcm/

# get raw data .mat files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.mat' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.mat' --exclude '*' jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0572_20230223/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/raw/

# or, get raw .dat files
rsync -avz --progress --itemize-changes --prune-empty-dirs --include '*/' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n30_*.dat' --include '*_multi_slice_golden_angle_spiral_ssfp_slice_*_n48_*.dat' --exclude '*' jvanamerom@lauterbur.usc.edu::disc_fetal/vol0572_20230223/raw_hawk/ /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/raw/

# get video files
rsync -avz --progress --itemize-changes --prune-empty-dirs jvanamerom@lauterbur.usc.edu::ytian_disc_fetal/vol0572_20230223/video_data/* /hpf/projects/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/videos/usc/
```

### Working Directory

located on //carbon14.ccm.sickkids.ca/cmacgowan/jvanamerom/fetal_spiral_ssfp_055t

to mount 
```
sudo mount -t cifs //carbon14.ccm.sickkids.ca/cmacgowan/jvanamerom /mnt/hpc-cmacgowan -o username=jvanamerom
```

## Steps

### demodulation delay correction 

Apply demodulation delay using GIRF-corrected gradient waveforms. 

NOTE: script will save raw data .mat files in place, replacing uncorrected raw data. 

e.g.,
```
sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); rawDataDirPath = '/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572/data/raw'; script_demodulation_delay_correction;"
```

### 2d recon

e.g., in matlab,
```matlab
reconName = 'rlt';  % can also be 'dc'
volId = 'vol370';
script_all_stacks_realtime_recon
```
e.g., from bash
```
sudo matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal-spiral-ssfp-2d')); volId='vol572'; reconName='dc'; script_all_stacks_realtime_recon; reconName='rlt'; script_all_stacks_realtime_recon;"
```

save reconstructed 2D images to NIfTI

e.g., in matlab,
```matlab
reconMatFiles = dir('/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526/data/usc_disc_yt_*_rlt_arms07_*.mat');
for iRMF = 1:numel(reconMatFiles), 
    reconMatFilePath = fullfile(reconMatFiles(iRMF).folder,reconMatFiles(iRMF).name); 
    script_save_stack_to_file; 
end
```

review figures to verify orientation of images match reference

scripts/functions in fetal_cmr_4d expect input certani files in data directory
* copy all sXX_dc_ab.nii.gz and sXX_rlt_ab.nii.gz files to be used in 4d recon from data/nii to data/
* create copy of real-time recon .mat files used for 4d recon in data directory as sXX_rlt_recon.mat; to reduce size the `imageFrames` field can be removed from the `R` structure

e.g., in matlab,
```matlab
reconDir = '/mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol526';
dataDir = fullfile(reconDir,'data');
niiFiles = dir(fullfile(dataDir,'s*_rlt_ab.nii.gz'));
matFiles = dir(fullfile(dataDir,'usc_disc_yt_*_rlt_arms*_*.mat'));
assert(numel(niiFiles)==numel(matFiles),'number of mat files does not match number of reference nifti files')
for iF = 1:numel(matFiles)
    load(fullfile(matFiles(iF).folder,matFiles(iF).name))
    R = rmfield(R,'imageFrames');
    save(fullfile(dataDir,strcat(niiFiles(iF).name(1:4),'rlt_recon.mat')), 'R', '-v7.3' );
end
```

### fetal heart masks

- manually draw fetal heart masks for each `sXX_dc_ab.nii.gz` file (e.g., using the [Medical Imaging ToolKit (MITK) Workbench](http://mitk.org/wiki/Downloads#MITK_Workbench))
    - draw ROI containing fetal heart and great vessels for each slice
    - save segmentation as `sXX_mask_heart.nii.gz` segmentation in 'mask' directory

### preprocess

- run `preproc_fetal_spiral_ssfp` in Matlab,
    ```matlab
    reconDir = '~/path/to/recon/directory';
    S = preproc_fetal_spiral_ssfp( reconDir );
    save( fullfile( reconDir, 'data', 'results.mat' ), 'S', '-v7.3' );
    ```
    - optionally, manually specify
        - target stack by changing value in 'data/tgt_stack_no.txt' (stacks are index 1,2,...)
        - excluded stacks/slices/frames by specifying in 'data/force_exclude_*.txt' 
            - stacks/slices/frames are zero-indexed
            - slice numbers in force_exclude_slice.txt files are consecutive across stacks (you can use the info.tsv file created by `mirtk reconstructCardiac`, as generated during reference volume recon, as in next step, to identify correct slice numbers)
- create realtime image series with 2x dt so that SVR temporal PSF is wider
    ```
    $ # on imaging-lab workstation
    $ sudo singularity shell --bind /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t container/svrtk_w_jinc_psf.sif
    Singularity> for s in 57 70 79 80; do mirtk edit-image s${s}_rlt_ab.nii.gz s${s}_rlt_ab_wider_tpsf.nii.gz -dt 0.07392; done
    ```

### fetal chest mask

- create 3D mask of fetal chest
       - recon reference volume, \
       e.g., in shell on imaging-lab workstations: 
        ```
        sudo singularity exec --bind /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/container/svrtk_w_jinc_psf.sif /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal_cmr_4d/4drecon/recon_ref_vol_jinc.bash /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol474 ref_vol_jinc
        ```       
     - draw fetal chest ROI using 'ref_vol.nii.gz' as a reference (e.g., using MITK)
     - save segmentation to 'mask' directory as  'mask_chest.nii.gz'
         - _note:_ the orientation of all later 3D/4D reconstructions is determined by this mask file; the orientation can be changed by applying a transformation to 'mask_chest.nii.gz' prior to further reconstructions

### dc (time-avg) recon

e.g., time-average on imaging-lab workstations: 
```
 sudo singularity exec --bind /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/container/svrtk_w_jinc_psf.sif /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal_cmr_4d/4drecon/recon_dc_vol_jinc.bash /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol572 dc_vol
```

### Cardiac Intraslice Synchronisation

    - heart-rate estimation
        - run `cardsync_intraslice`, in Matlab:
            ```matlab
            reconDir    = '~/path/to/recon/directory';
            dataDir     = fullfile( reconDir, 'data' );
            cardsyncDir = fullfile( reconDir, 'cardsync' );
            M = matfile( fullfile( dataDir, 'results.mat' ) );
            S = cardsync_intraslice( M.S, 'resultsDir', cardsyncDir, 'verbose', true );
            ```

### Reconstruct Slice Cine Volumes
    - recon cine volume for each slice, \
        e.g., in shell: 
            ```
            sudo singularity exec --bind /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/container/svrtk_w_jinc_psf.sif /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal_cmr_4d/4drecon/recon_slice_cine_jinc.bash /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol549
            ```
    NOTE: maybe use recon_slice_cine_jinc_wider_tpsf_... .bash instead?

### Cardiac Interslice Synchronisation

    - optionally, specify target slice by creating file 'data/tgt_slice_no.txt' containing target slice number (indexed starting at 1)
    - run `cardsync_interslice`, in Matlab:
		```matlab
		% setup
		reconDir    = '~/path/to/recon/directory';
		dataDir     = fullfile( reconDir, 'data' );
		cardsyncDir = fullfile( reconDir, 'cardsync' );
		cineDir     = fullfile( reconDir, 'slice_cine_vol' );    
		M = matfile( fullfile( cardsyncDir, 'results_cardsync_intraslice.mat' ) );

		% target slice
		tgtLoc = NaN;
		tgtLocFile = fullfile( dataDir, 'tgt_slice_no.txt' );
		if exist( tgtLocFile , 'file' )
		  fid = fopen( tgtLocFile, 'r' );
		  fclose( fid );
		  tgtLoc = fscanf( fid, '%f' );
		end

		% excluded slices
		excludeSlice = [];
		excludeSliceFile = fullfile( dataDir, 'force_exclude_slice.txt' );
		if exist( excludeSliceFile , 'file' )
		  fid = fopen( excludeSliceFile, 'r' );
		  excludeSlice = fscanf( fid, '%f' ) + 1;  % NOTE: slice locations in input file are zero-indexed
		  fclose( fid );
		end

		% slice-slice cardiac synchronisation
		S = cardsync_interslice( M.S, 'recondir', cineDir, 'resultsdir', cardsyncDir, 'tgtloc', tgtLoc, 'excludeloc', excludeSlice );
		```

### 4d recon

```
sudo singularity exec --bind /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/container/svrtk_w_jinc_psf.sif /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/code/fetal_cmr_4d/4drecon/recon_cine_vol_jinc_lastIterLambda.bash /mnt/hpc-cmacgowan/jvanamerom/fetal_spiral_ssfp_055t/vol474 cine_vol_jinc_lastiterlambda0p02 0.02
```

### summarize svr results

e.g., in Matlab:  
```matlab
reconDir = '/Volumes/jvanamerom/fetal_spiral_ssfp_055t/vol474';
cineDir = fullfile(reconDir,'cine_vol_jinc_wider_tpsf_lastiterlambda0p02_motionsmoothing');
cardsyncDir = fullfile(reconDir,'cardsync');
S = summarise_recon( cineDir, cardsyncDir, 'verbose', true, 'irtkPath', '/Users/joshuavanamerom/Documents/SW/irtk/build/bin/' );
save( fullfile(cineDir,'summary.mat'), 'S', '-v7.3' );
[~,hFigs] = plot_info( fullfile(cineDir,'info.tsv') );
save_figs( fullfile(cineDir,'figs','png'), findall(groot,'Type','figure'), fullfile(cineDir,'figs','fig') );
```

### visualize cine volume in cvi42

Convert cine_vol stack from nifti to dicom using Horos plug-in, export to dicom, then run script to fix timing information.

e.g., in Matlab:
```matlab
% script_fix_dicom_timing

inDir  = 'cine_hires_0p3mm_5000';
outDir = 'cine_hires_0p3mm_5000_fix_timing';

D = dir( fullfile( inDir, '*.dcm' ) ); 
nSlice = 160;
dt = 17.1015; %ms

for iD = 1:numel(D)
    triggerTime = dt * (1+floor((iD-1)/nSlice));
    inDcmFile = fullfile(inDir,sprintf('IM-0001-%04i.dcm',iD));
    outDcmFile = fullfile(outDir,sprintf('IM-0001-%04i.dcm',iD));
    im = dicomread(inDcmFile);
    info = dicominfo( inDcmFile );
    info.Filename = outDcmFile;
    info.TriggerTime = triggerTime;
    dicomwrite(im,outDcmFile,info,'CreateMode','copy');
end
```

---

**NOTE** Code is not well version controlled as of 2022-11-04.
 
dicm2nii downloaded as [https://github.com/xiangruili/dicm2nii/commit/4d42e9bfa870df85bf23a6b16e2ce4a5df3302330](https://github.com/xiangruili/dicm2nii/commit/4d42e9bfa870df85bf23a6b16e2ce4a5df330233) without further changes

fetal_cmr_4d initially downloaded as https://github.com/mriphysics/fetal_cmr_4d/commit/1d47e75128e55e3556906f1aae791708150b4b05 but has changes

fetal-spiral-ssfp-2d is https://github.com/sickkids-mri/fetal-spiral-ssfp-2d with subsequent changes

misc is other test scripts

svrtk container definition based on https://github.com/SVRTK/SVRTK/blob/master/docker/Dockerfile with versions of SVRTK and MIRTK to match https://hub.docker.com/r/fetalsvrtk/svrtk latest from October 2020

---