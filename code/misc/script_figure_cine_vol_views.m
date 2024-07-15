%% Load Data

clear V F titleStr

V{1,1} = VideoReader('~/Desktop/ismrm2023/vol474/cine_vol_hires_0p3mm_4ch.mp4');
V{2,1} = VideoReader('~/Desktop/ismrm2023/vol474/cine_vol_hires_0p3mm_mid-sa.mp4');
V{1,2} = VideoReader('~/Desktop/ismrm2023/vol474/cine_vol_hires_0p3mm_lv2ch.mp4');
V{2,2} = VideoReader('~/Desktop/ismrm2023/vol474/cine_vol_hires_0p3mm_lvot.mp4');

F = cell(size(V));
for iF = 1:numel(V)
    F{iF} = read(V{iF},[1,Inf]);
end

titleStr{1,1} = '4-chamber';
titleStr{2,1} = 'short-axis';
titleStr{1,2} = '2-chamber';
titleStr{2,2} = 'LV outflow tract';


%% Setup

gifFilePath = '~/Desktop/ismrm2023/fig_cine_vol_views_fullres.gif';

dtFrame = 0.044;


%% Create Figure

hFig = figure;
hFig.Position(3) = 350;
hFig.Position(4) = 350;
for iI = 1:4:size(F{1},4)
    for iF = 1:numel(F)
        subplot(2,2,iF)
        imshow(rgb2gray(F{iF}(:,:,:,iI)),[],'Border','tight')
        title(titleStr{iF})
    end
    if iI == 1
        gif(gifFilePath,'DelayTime',dtFrame,'Overwrite',true,'frame',hFig)
    else
        gif('DelayTime',dtFrame,'frame',hFig)
    end
end
fprintf('%s creation complete\n',gifFilePath)
gif('clear')
