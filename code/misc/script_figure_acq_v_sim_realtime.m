%% Load Data

clear V F titleStr

V{1,1} = VideoReader('~/Desktop/ismrm2023/vol474/rescaledstack000slice008.mp4');
V{2,1} = VideoReader('~/Desktop/ismrm2023/vol474/simstack000slice008.mp4');
V{1,2} = VideoReader('~/Desktop/ismrm2023/vol474/rescaledstack001slice011.mp4');
V{2,2} = VideoReader('~/Desktop/ismrm2023/vol474/simstack001slice011.mp4');
V{1,3} = VideoReader('~/Desktop/ismrm2023/vol474/rescaledstack003slice013.mp4');
V{2,3} = VideoReader('~/Desktop/ismrm2023/vol474/simstack003slice013.mp4');


F = cell(size(V));
for iF = 1:numel(V)
    F{iF} = read(V{iF},[1,Inf]);
end

titleStr{1,1} = 'acquired real-time';
titleStr{2,1} = 'simulated real-time';
titleStr{1,2} = '';
titleStr{2,2} = '';
titleStr{1,3} = '';
titleStr{2,3} = '';


%% Setup

gifFilePath = '~/Desktop/ismrm2023/fig_acq_v_sim_realtime_fullres.gif';

dtFrame = 0.033;


%% Create Figure

hFig = figure;
hFig.Position(3) = 350;
hFig.Position(4) = 550;
isGifExist = false;
for iI = 1:size(F{1},4)
    for iF = 1:numel(F)
        subplot(3,2,iF)
        imshow(rgb2gray(F{iF}(:,:,:,iI)),[],'Border','tight')
        title(titleStr{iF})
    end
     if iI == 1
        gif(gifFilePath,'DelayTime',dtFrame,'Overwrite',true,'frame',hFig)
        isGifExist = true;
    else
        gif('DelayTime',dtFrame,'frame',hFig)
    end
end
fprintf('%s creation complete\n',gifFilePath)


%% 

gif('clear')