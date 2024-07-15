function [ S, thetaOffset, overlap, noOverlap, searchFailed, isExcludeLoc, hFig ] = cardsync_interslice( S, varargin )
%CARDSYNC_INTERSLICE  Synchcronise cardiac cycles between slice-locations.
%
%   S = CARDSYNC_INTERSLICE( S ) takes structure S returned by CARDSYNC_INTERSLICE 
%   and adds heart rate estimation fields. 
%
%   CARDSYNC_INTERSLICE( ..., 'name', value ) specifies optional input argument. 
%   See code for name-value pairs.
%
%   See also PREPROC, CARDSYNC_INTERSLICE.
%

%   jfpva (joshua.vanamerom@kcl.ac.uk)


%% Optional Input Argument Default Values

default.reconDir        = pwd;      % path of parent directory of cine reconstructions for each slice in loc00000 directories
default.resultsDir      = pwd;      % path of directory to save results
default.tgtLoc          = NaN;      % initial slice-location target
default.tgtThetaOffset  = 0;        % cardiac phase offset of initial slice-location target
default.excludeLoc      = [];       % excluded specified slice locations from synchronisation
default.overlapTol      = 0.1;      % minimum overlap tolerance, as fraction of maximum overlap, slices with lower overlap will not be considered to be overlapping
default.niftiPath       = fullfile(fileparts(mfilename('fullpath')),'lib','nifti');  % path of NIfTI I/O toolbox
default.isVerbose       = true;


%% Parse Input

p = inputParser;

if  verLessThan('matlab','8.2')
    add_param_fn = @( parseobj, argname, defaultval, validator ) addParamValue( parseobj, argname, defaultval, validator );
else
    add_param_fn = @( parseobj, argname, defaultval, validator ) addParameter( parseobj, argname, defaultval, validator );
end

addRequired(   p, 'S', ... 
    @(x) validateattributes( x, {'struct'}, {'vector'}, mfilename) );

add_param_fn(   p, 'recondir', default.reconDir, ...
    @(x) validateattributes( x, {'char'}, {'vector'}, mfilename) );

add_param_fn(   p, 'resultsdir', default.resultsDir, ...
    @(x) validateattributes( x, {'char'}, {'vector'}, mfilename) );

add_param_fn(   p, 'tgtloc', default.tgtLoc, ...
    @(x) validateattributes( x, {'numeric'}, {'positive','scalar'}, mfilename) );

add_param_fn(   p, 'tgtthetaoffset', default.tgtThetaOffset, ...
    @(x) validateattributes( x, {'numeric'}, {'scalar'}, mfilename) );

add_param_fn(   p, 'excludeloc', default.excludeLoc, ...
    @(x) validateattributes( x, {'numeric'}, {'positive','integer'}, mfilename) );

add_param_fn(   p, 'overlaptol', default.overlapTol, ...
    @(x) validateattributes( x, {'numeric'}, {'positive','scalar','<=',1}, mfilename) );

add_param_fn(   p, 'niftipath', default.niftiPath, ...
    @(x) validateattributes( x, {'char'}, {'vector'}, mfilename) );

add_param_fn(   p, 'verbose', default.isVerbose, ...
    @(x) validateattributes( x, {'logical'}, {'scalar'}, mfilename) );

parse( p, S, varargin{:} );

reconDir        = p.Results.recondir;
resultsDir      = p.Results.resultsdir;
tgtLoc          = p.Results.tgtloc;
tgtThetaOffset  = p.Results.tgtthetaoffset;
excludeLoc      = p.Results.excludeloc(:).';
overlapTol      = p.Results.overlaptol;
niftiPath       = p.Results.niftipath;
isVerbose       = p.Results.verbose;


%% Dependencies

addpath( genpath( niftiPath ) )


%% Load Slice-Location Cine Data

D = dir( fullfile( reconDir, 'slice0*' ) );

nLoc = numel(D);

X = cell(1,nLoc);  % Cines
W = cell(1,nLoc);  % Volume Weights
M = cell(1,nLoc);  % Masks


% Load Cines and Volume Weights
isExcludeLoc = false(1,numel(D));
isLocMissing = true(1,numel(D));
for iLoc = 1:nLoc
    
    locDir = fullfile( D(iLoc).folder, D(iLoc).name );
    
    if any( iLoc == excludeLoc )
        
        isExcludeLoc(iLoc) = true;
    
    else
       
        if ~exist( fullfile( locDir, 'cine.nii.gz' ), 'file' )

            X{iLoc} = [];
            W{iLoc} = [];
            M{iLoc} = [];
            isLocMissing(iLoc) = true;

        else

            fprintf( 'loading files from %s\n', locDir )

            N = load_untouch_nii( fullfile( locDir, 'cine.nii.gz' ) );
            X{iLoc} = N.img;

            N = load_untouch_nii( fullfile( locDir, 'volumeweights_mc00.nii.gz' ) );
            W{iLoc} = N.img;

            N = load_untouch_nii( fullfile( locDir, 'mask_cardsync.nii.gz' ) );
            M{iLoc} = repmat( ( sum( N.img, 4 ) > 0 ), 1, 1, 1, size( X{iLoc}, 4 ) );

            isLocMissing(iLoc) = false;

        end

    end
    
end

% Default Values
X0 = zeros( size( X{find(~isLocMissing,1,'first')} ), 'like', X{find(~isLocMissing,1,'first')} );
W0 = X0;
M0 = M{find(~isLocMissing,1,'first')};

% Replace Missing Values
for iLoc = find( isLocMissing )
    X{iLoc} = X0;
    W{iLoc} = W0;
    M{iLoc} = M0;
end
for iLoc = excludeLoc
    X{iLoc} = X0;
    W{iLoc} = W0;
    M{iLoc} = M0;
end


%% Calculate Volume Weight Overlap 

% Calculate Product of Volume Weights Between Pairs of Slice-Locations
volWgtOverlap = zeros( nLoc, nLoc ); 
for iLoc1 = 1:nLoc
    for iLoc2 = 1:nLoc
        volWgtOverlap(iLoc1,iLoc2) = sum( W{iLoc1}(M0(:)>0) .* W{iLoc2}(M0(:)>0) );
    end
end

% Display as Heat Map
if (isVerbose)
    hFig(1) = figure( 'Name', 'pairwise_slicelocation_volume_weight_product' );
    imshow(volWgtOverlap,[],'InitialMagnification',2000),
    colormap(gca,'parula'),
    colorbar,
    xlabel( 'slice-location' )
    ylabel( 'slice-location' )
    axis on
end


%% Find Overlapping Slice-Locations

% Apply Threshold 
volWgtThresh = overlapTol * max( max( triu( volWgtOverlap, 1 ) + tril( volWgtOverlap, -1 ) ) );
isOverlap    = volWgtOverlap > volWgtThresh;  % overlapping slice-locations

% Display as Heat Map
if (isVerbose)
    hFig(2) = figure( 'Name', 'pairwise_slicelocation_volume_weight_product_overlap' );
    imshow(volWgtOverlap.*isOverlap,[],'InitialMagnification',2000),
    colormap(gca,'parula'),
    colorbar,
    xlabel( 'slice-location' )
    ylabel( 'slice-location' )
    axis on
end


%% Sum Overlap Between Slice-Location and All Other Slice-Locations

v = volWgtOverlap; 
v = triu( v, 1 ) + tril( v, -1 );

overlap   = sum( v, 2 );
noOverlap = false( size( overlap ) );

% Display
if (isVerbose)
    hFig(3) = figure('Name','overlap_v_loc', 'Position', [170 350 918 322] );
    plot( overlap, '.-', 'LineWidth', 1.5, 'MarkerSize', 12 )
    set(gca,'XLim',[0,nLoc+1])
    xlabel( 'slice-location' )
    ylabel( '\Sigma overlap(slice,slice'''')' )
end
grid on


%% Initialise Before Starting Search

thetaOffset = zeros(size(X));

srcLocOrder = nan(size(X));

tgtLocNum   = cell(size(X));


%% Log

if ~exist( resultsDir, 'dir' )
    system( sprintf( 'mkdir -p %s', resultsDir ) );
end

diary( fullfile( resultsDir, 'log_cardsync_interslice.txt' ) )


%% Setup Target Slice-Location

if isnan( tgtLoc )
    v = volWgtOverlap .* isOverlap; 
    v = triu( v, 1 ) + tril( v, -1 );
    [~,i] = max( mean(v,2) );
    tgtLoc = i;
end

thetaOffset(tgtLoc) = tgtThetaOffset;

if (thetaOffset(tgtLoc)~=0)
    X{tgtLoc} = fouriershift( X{tgtLoc}, thetaOffset(tgtLoc)/(2*pi), 4 );
end


%% Setup Search Order

inLoc  = tgtLoc;
outLoc = setdiff( 1:nLoc, inLoc );

srcLocOrder(1)  = inLoc;
tgtLocNum{1}    = [];

fprintf( '\nBootstrap Search Slice-Locations\n\n' )

for iLoc = 2:nLoc

	isOverlapTmp = isOverlap;  % overlapping slice-locations
    v = volWgtOverlap .* isOverlapTmp; 
    v = triu( v, 1 ) + tril( v, -1 );
    v( inLoc, : ) = 0;  
    v( :, outLoc ) = 0;
    [m,i] = max( mean(v,2) );
    tolTmp = overlapTol;
    while (m==0)
        if ( tolTmp < 0.01 )
            i = outLoc(1);
            break;
        else
            tolTmp = 0.95 * tolTmp;
            volWgtThresh = tolTmp * max( max( triu( volWgtOverlap, 1 ) ) );
            isOverlapTmp = volWgtOverlap > volWgtThresh;  % overlapping slice-locations
            v = volWgtOverlap .* isOverlapTmp; 
            v = triu( v, 1 ) + tril( v, -1 );
            v( inLoc, : ) = 0;  
            v( :, outLoc ) = 0;
            [m,i] = max( mean(v,2) );
        end
    end
    srcLoc = i(1); 
    srcLocOrder(iLoc) = srcLoc;

    ind     = [ srcLoc, inLoc ];
       
    isOverlapSub = isOverlapTmp(ind,:); isOverlapSub = isOverlapSub(:,ind);
    [ loc1, loc2 ] = find( triu( isOverlapSub(1,:), 1 ) );
    tgtLocNum{iLoc} = ind(loc2);
    
    fprintf( 'srcLoc %2i / tgtLoc', srcLocOrder(iLoc) )
    fprintf( ' %2i', tgtLocNum{iLoc} )
    fprintf( '\n' )
    
    inLoc  = ind;
    outLoc = setdiff( 1:nLoc, inLoc );
    
end


%% Perform Search

% Plot Results

if (isVerbose)
    h = figure( 'Name', 'thetaoffset_v_loc', 'Position', [174 7 918 322] );
    plot([0,nLoc+1],[0,0],'k:')
    xlabel('loc')
    ylabel('\theta_{offest}')
    set(gca,'YLim',2*pi*[-1,+1])
    set(gca,'XLim',[0,nLoc+1])
    hold on
    hLine(tgtLoc) = plot( srcLocOrder(1), thetaOffset(srcLocOrder(1)), 'cs', 'MarkerSize', 10 );
    hLine(tgtLoc).DisplayName = 'target';
end


% Search

searchFailed = false( size( overlap ) );

for iLoc = 2:nLoc

    srcLoc = srcLocOrder(iLoc); 

    fprintf( '\n\n----------------------------------------------------------------\n\n' )
    
    theta = 0;
    
    fprintf( 'fmincon iter %i, srcLoc %i\n\n', iLoc, srcLoc )
    
    if isExcludeLoc(srcLoc)
        
        fprintf( 'slice location excluded\n\n' )
        
    else

        fprintf( 'srcLoc %2i / tgtLoc', srcLocOrder(iLoc) )
        fprintf( ' %2i', tgtLocNum{iLoc} )
        fprintf( '\n\n' )

        if ( ~isempty( tgtLocNum{iLoc} ) )

            ind     = [ srcLoc, tgtLocNum{iLoc} ];

            theta0  = thetaOffset(srcLoc);
            Xsub    = X(ind);
            Wsub    = W(ind);
            Msub    = M(ind);

            loc1 = ones( size( tgtLocNum{iLoc} ) );
            loc2 = 2:numel(ind); 
            locPairsSub = [ loc1(:), loc2(:) ];

            disp( ind( locPairsSub )' )

            lb      = -2*pi;
            ub      = +2*pi;

            opts                = optimoptions('fmincon');
            opts.MaxIterations  = 25;
                %opts.OptimalityTolerance = 5e-6;
            opts.Display        = 'iter-detailed';
            opts.PlotFcn        = {@optimplotfval,@optimplotstepsize};
            opts.OutputFcn      = @outputfn_bootstrap;
                %opts.UseParallel    = true;

            if ~isnan( objectivefn_bootstrap(theta0,Xsub,Wsub,Msub,locPairsSub) )

                tic
                theta = fmincon( @(theta) objectivefn_bootstrap(theta,Xsub,Wsub,Msub,locPairsSub), theta0, [], [], [], [], lb, ub, @(theta) nonlconfn(theta), opts );
                toc
                close

            else

                searchFailed(srcLoc) = true;

            end

        else

            noOverlap(srcLoc) = true;

        end
    
    end
    
    thetaOffset(srcLoc) = theta;
    
    if (isVerbose)
        figure( h )
        if ( isExcludeLoc(srcLoc) )
            hLine(srcLoc) = plot( srcLoc, thetaOffset(srcLoc), 'r+', 'MarkerSize', 8 );
            hLine(srcLoc).DisplayName = 'excluded';
        elseif ( searchFailed(srcLoc) ) 
            hLine(srcLoc) = plot( srcLoc, thetaOffset(srcLoc), 'rx', 'MarkerSize', 8 );
            hLine(srcLoc).DisplayName = 'optimisation failed';
        elseif ( noOverlap(srcLoc) )
            hLine(srcLoc) = plot( srcLoc, thetaOffset(srcLoc), 'rd', 'MarkerSize', 8 );
            hLine(srcLoc).DisplayName = 'no overlap with other slices';
        else
            hLine(srcLoc) = plot( srcLoc, thetaOffset(srcLoc), 'bo', 'MarkerSize', 8 );
            hLine(srcLoc).DisplayName = 'estimated offset';
        end
    end
    
    if ( theta ~= 0 )
        X{srcLoc} = fouriershift( X{srcLoc}, thetaOffset(srcLoc)/(2*pi), 4 );
    end
    
end

legend( hLine( [ tgtLoc find(~isExcludeLoc(:)&~noOverlap(:)&~searchFailed(:),1,'first') find(noOverlap,1,'first') find(searchFailed,1,'first') find(isExcludeLoc,1,'first') ] ) )

if (isVerbose)
    hFig(4) = h;
end


%% End Logging

diary off


%% Save Figures

figDir = fullfile( resultsDir, 'figs' );

pngDir = fullfile( figDir, 'png' );

if ~exist( pngDir, 'dir' )
    system( sprintf( 'mkdir -p %s', pngDir ) );
end

matfigDir = fullfile( figDir, 'fig' ); 

save_figs( pngDir, hFig, matfigDir );


%% Update Timing

angsum = @(v) angle( exp( sqrt(-1) * sum(v(:) ) ) );  % range [-pi,+pi]

locNum = 1;

nStack = length(S);

for iStk = 1:nStack     
   
    for iLoc = 1:S(iStk).nLoc
        
        offset = angsum( thetaOffset(locNum) );
        
        tRTrigger = S(iStk).tRTrigger{iLoc} - offset/(2*pi) * S(iStk).tRR{iLoc};
        if tRTrigger(end) < S(iStk).tFrame{iLoc}(end)
            tRTrigger = [ tRTrigger, tRTrigger(end) + S(iStk).tRR{iLoc} ];
        end
        if tRTrigger(1) > S(iStk).tFrame{iLoc}(1)
            tRTrigger = [ tRTrigger(1) - S(iStk).tRR{iLoc}, tRTrigger ] ;
        end
        while tRTrigger(end-1) > S(iStk).tFrame{iLoc}(end)
            tRTrigger = tRTrigger(1:(end-1));
        end
        while tRTrigger(2) < S(iStk).tFrame{iLoc}(1)
            tRTrigger = tRTrigger(2:end);
        end
        
        tSinceRTrigger = calc_cardiac_timing( S(iStk).tFrame{iLoc}, tRTrigger ); 
        S(iStk).thetaOffset{iLoc} = offset; 
        S(iStk).tRTrigger{iLoc} = tRTrigger;
        [ ~, cardPhaseFraction ] = calc_cardiac_timing( S(iStk).tFrame{iLoc}, S(iStk).tRTrigger{iLoc} );
        S(iStk).thetaFrame{iLoc} = 2 * pi * cardPhaseFraction;
        
        locNum = locNum + 1;

    end
    
end


%% Save Updated Timing to Text File

fid = fopen( fullfile( resultsDir, 'cardphases_interslice_cardsync.txt' ), 'w' );
fprintf( fid, '%.6f ', cell2mat( [ S.thetaFrame ] ) );
fclose( fid );


%% Save Results to .mat File

save( fullfile( resultsDir, 'results_interslice_cardsync.mat' ), 'S', 'thetaOffset', 'overlap', 'noOverlap', 'searchFailed', 'isExcludeLoc', '-v7.3' )


end  % cardsync_interslice(...)


%% Function: calc_cineloc_bootstrap_similarity
function [ sim, cc, wgt ] = calc_cineloc_bootstrap_similarity( X, W, M, locs, thetaOffset )

% Setup

nLoc = numel(X);

for iLoc = 1:nLoc
    if ( size( M{iLoc}, 4 ) == 1 )
        M{iLoc} = repmat( M{iLoc}, 1, 1, 1, nLoc );
    end
end


% Anonymous Functions

cycshift   = @(C,cardPhaseOffset) fouriershift( C, cardPhaseOffset/(2*pi), 4 );
subindex   = @(a,r,c) a(r,c); 
ccoef      = @(a,b,m) subindex(corrcoef(max(a(m),0),max(b(m),0)),2,1);


% Apply Cyclic Shift

if ( thetaOffset{ 1 } ~= 0 )
    X{1} = cycshift( X{1}, thetaOffset{1} );
    W{1} = cycshift( W{1}, thetaOffset{1} );
end


% Calculate Similarity

cc  = zeros(nLoc,nLoc);
wgt = zeros(nLoc,nLoc);

locs1 = reshape( locs(:,1), 1, [] );
locs2 = reshape( locs(:,2), 1, [] );

for iPair = 1:numel(locs1)
    iLoc1 = locs1(iPair);
    iLoc2 = locs2(iPair);
    x1 = X{iLoc1};
    x2 = X{iLoc2};
    w1 = W{iLoc1};
    w2 = W{iLoc2};
    w  = w1 .* w2;
    m  = ( M{iLoc1} .* M{iLoc2} ) > 0;
    cc(iLoc1,iLoc2)  = ccoef( x1, x2, m );
    wgt(iLoc1,iLoc2) = sum( w( m ) );
end

cc(isnan(cc))   = 0;

sim = sum( wgt(:) .* cc(:) ) / sum( wgt(:) );


end  % calc_cineloc_bootstrap_similarity(...)


%% Function: objectivefn_bootstrap
function m = objectivefn_bootstrap( cardphaseOffset, X, W, M, locPairs )

% For bootstrap optimisation, only the one slice-location cardiac phase
% offset is optimised, so cyclic shifts of other slice-locations can be
% pre-computed to save calculations.

m = - calc_cineloc_bootstrap_similarity( X, W, M, locPairs, num2cell(cardphaseOffset) );
 
end  % objectivefn_bootstrap(...)


%% Function: outputfn_bootstrap
function stop = outputfn_bootstrap(x,optimvalues,state)

stop = false;
fprintf( '%75s: ', 'theta' )
fprintf( '%7.4f ', x(1) )
fprintf( '\n' )

end  % outputfn_bootstrap(...)

