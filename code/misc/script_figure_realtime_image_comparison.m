%% Setup In and Output

dataDir = '/Volumes/jvanamerom/fetal_spiral_ssfp_055t/vol385/data/';

dataFiles = {   'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms480_armshared00_ttv0p000_stv0p0020_fov560',...
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms13_armshared00_ttv0p020_stv0p0020_fov560.mat',...
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms08_armshared00_ttv0p020_stv0p002.mat',...
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms05_armshared00_ttv0p020_stv0p0020_fov560.mat',...
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms03_armshared00_ttv0p020_stv0p0020_fov560.mat',...
            };
%{  
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms82_armshared00_ttv0p020_stv0p0020_fov560.mat',...
                'usc_disc_yt_2022_07_08_142402_multi_slice_golden_angle_spiral_ssfp_slice_30_fov_240_n63_tread3_slice15_realtime_arms21_armshared00_ttv0p020_stv0p0020_fov560.mat',...
%}
        
gifFilePath = '~/Desktop/ismrm2023/fig_realtime_comparison_fullres.gif';

%% Load Data

clear R
for iR = 1:numel(dataFiles)
    M = matfile(fullfile(dataDir,dataFiles{iR}));
    Rtemp = M.R;
    if isfield(Rtemp,'rawDataFileName')
        Rtemp = rmfield(Rtemp,'rawDataFileName');
    end
    Rtemp.SI95pct = prctile(Rtemp.imageFrames(:),95);
    Rtemp.dtFrame = median(diff(Rtemp.frameTimes));
    Rtemp.titleStr = sprintf('\\Deltat=%ims', round(Rtemp.dtFrame));
    if isnan(Rtemp.dtFrame)
        Rtemp.titleStr = 'time-avg.';
    end
    R(iR) = Rtemp;
end

%% Setup Figure

cropSize = 70;
cropInd  = -round(cropSize/2):(round(cropSize/2)-1);
indRow   = 182 + cropInd;
indCol   = 192 + cropInd;

dtFrame = 7;
frameTimes = min([R.frameTimes]):dtFrame:max([R.frameTimes]);

%% Create Figure

hFig = figure;
hFig.Position(3) = 550;
hFig.Position(4) = 100;
isGifExist = false;
for iF = circshift(1:numel(frameTimes),round(numel(frameTimes)/2))
    for iR = 1:numel(R)   
        subplot(1,numel(R),iR)
        [~,indFrm] = min(abs(R(iR).frameTimes-frameTimes(iF)));
        imshow( R(iR).imageFrames(indRow,indCol,indFrm) / R(iR).SI95pct, [0,1] )
        title(R(iR).titleStr)
    end
    if ~isGifExist
        gif(gifFilePath,'DelayTime',dtFrame/1000,'Overwrite',true,'frame',hFig)
        isGifExist = true;
    else
        gif('DelayTime',dtFrame/1000,'frame',hFig)
    end
end
fprintf('%s creation complete\n',gifFilePath)


%% 

gif('clear')


%%
function gif(varargin)
% gif is the simplest way to make gifs. Simply call
% 
%   gif('myfile.gif') 
% 
% to write the first frame, and then call 
% 
%   gif
% 
% to write each subsequent frame. That's it. 
% 
%% Syntax
% 
%  gif('filename.gif') 
%  gif(...,'DelayTime',DelayTimeValue,...) 
%  gif(...,'LoopCount',LoopCountValue,...) 
%  gif(...,'frame',handle,...) 
%  gif(...,'resolution',res)
%  gif(...,'nodither') 
%  gif(...,'overwrite',true)
%  gif 
%  gif('clear') 
% 
%% Description 
% 
% gif('filename.gif') writes the first frame of a new gif file by the name filename.gif. 
% 
% gif(...,'DelayTime',DelayTimeValue,...) specifies a the delay time in seconds between
% frames. Default delay time is 1/15. 
% 
% gif(...,'LoopCount',LoopCountValue,...) specifies the number of times the gif animation 
% will play. Default loop count is Inf. 
% 
% gif(...,'frame',handle,...) uses the frame of the given figure or set of axes. The default 
% frame handle is gcf, meaning the current figure. To turn just one set of axes into a gif, 
% use 'frame',gca. This behavior changed in Jan 2021, as the default option changed from
% gca to gcf.
% 
% gif(...,'resolution',res) specifies the resolution (in dpi) of each frame. This option
% requires export_fig (https://www.mathworks.com/matlabcentral/fileexchange/23629).
%
% gif(...,'nodither') maps each color in the original image to the closest color in the new 
% without dithering. Dithering is performed by default to achieve better color resolution, 
% albeit at the expense of spatial resolution.
% 
% gif(...,'overwrite',true) bypasses a dialoge box that would otherwise verify 
% that you want to overwrite an existing file by the specified name. 
%
% gif adds a frame to the current gif file. 
% 
% gif('clear') clears the persistent variables associated with the most recent gif. 
% 
%% Example 
% For examples, type 
% 
%   cdt gif
% 
%% Author Information 
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG), June 2017. 
% 
% See also: imwrite, getframe, and rgb2ind. 

% source: https://www.mathworks.com/matlabcentral/fileexchange/63239-gif

%% Define persistent variables: 
persistent gif_filename firstframe DelayTime DitherOption LoopCount frame resolution
%% Parse Inputs
if nargin>0 
   
   % The user may want to clear things and start over: 
   if any(strcmpi(varargin,'clear'))
            
      % Clear persistent variables associated with this function: 
      clear gif_filename firstframe DelayTime DitherOption LoopCount frame resolution
   end
   
   % If the first input ends in .gif, assume this is the first frame:
   if strcmpi(varargin{1}(end-3:end),'.gif')
      
      % This is what the user wants to call the new .gif file: 
      gif_filename = varargin{1}; 
      
      % Check for an existing .gif file by the same name: 
      if exist(gif_filename,'file')==2
         OverWrite = false; % By default, do NOT overwrite an existing file by the input name. 
         if nargin>1
            tmp = strncmpi(varargin,'overwrite',4); 
            if any(tmp)
               OverWrite = varargin{find(tmp)+1}; 
               assert(islogical(OverWrite),'Error: Overwrite input must be either true or false.')
            end
         end
         
         if ~OverWrite
         
            % Ask the user if (s)he wants to overwrite the existing file: 
            choice = questdlg(['The file  ',gif_filename,' already exists. Overwrite it?'], ...
               'The file already exists.','Overwrite','Cancel','Cancel');
            if strcmp(choice,'Overwrite')
               OverWrite = true; 
            end
         end
         
         % Overwriting basically means deleting and starting from scratch: 
         if OverWrite
            delete(gif_filename) 
         else 
            clear gif_filename firstframe DelayTime DitherOption LoopCount frame
            error('The giffing has been canceled.') 
         end
         
      end
      
      firstframe = true; 
      
      % Set defaults: 
      DelayTime = 1/15; 
      DitherOption = 'dither'; 
      LoopCount = Inf; 
      frame = gcf; 
      resolution = 0; % When 0, it's used as a boolean to say "don't use export_fig". If greater than zero, the boolean says "use export_fig and use the specified resolution."  
   end
   
   tmp = strcmpi(varargin,'DelayTime'); 
   if any(tmp) 
      DelayTime = varargin{find(tmp)+1}; 
      assert(isscalar(DelayTime),'Error: DelayTime must be a scalar value.') 
   end
   
   if any(strcmpi(varargin,'nodither'))
      DitherOption = 'nodither'; 
   end
   
   tmp = strcmpi(varargin,'LoopCount'); 
   if any(tmp) 
      LoopCount = varargin{find(tmp)+1}; 
      assert(isscalar(LoopCount),'Error: LoopCount must be a scalar value.') 
   end
   
   tmp = strncmpi(varargin,'resolution',3); 
   if any(tmp) 
      resolution = varargin{find(tmp)+1}; 
      assert(isscalar(resolution),'Error: resolution must be a scalar value.') 
      assert(exist('export_fig.m','file')==2,'export_fig not found. If you wish to specify the image resolution, get export_fig here :https://www.mathworks.com/matlabcentral/fileexchange/23629. Otherwise remove the resolution from the gif inputs to use the default (lower quality) built-in getframe functionality.')  
      warning off export_fig:exportgraphics
   end
   
   tmp = strcmpi(varargin,'frame'); 
   if any(tmp) 
      frame = varargin{find(tmp)+1}; 
      assert(ishandle(frame)==1,'Error: frame must be a figure handle or axis handle.') 
   end
   
else
   assert(isempty(gif_filename)==0,'Error: The first call of the gif function requires a filename ending in .gif.') 
end
%% Perform work: 
if resolution % If resolution is >0, it means use export_fig
   
   if isgraphics(frame,'figure')
      f = export_fig('-nocrop',['-r',num2str(resolution)]);
   else
      % If the frame is a set of axes instead of a figure, use default cropping: 
      f = export_fig(['-r',num2str(resolution)]);
   end
      
else
   % Get frame: 
   fr = getframe(frame); 
   f =  fr.cdata; 
end
% Convert the frame to a colormap and corresponding indices: 
[imind,cmap] = rgb2ind(f,256,DitherOption);    
% Write the file:     
if firstframe
   imwrite(imind,cmap,gif_filename,'gif','LoopCount',LoopCount,'DelayTime',DelayTime)
   firstframe = false;
else
   imwrite(imind,cmap,gif_filename,'gif','WriteMode','append','DelayTime',DelayTime)
end
end


