% Test for detecting and tracking droplets in time-lapse photos
% 
% Instructions:
% 1. Make raw data into image stack in imageJ.
% 2. Run this, set params...
%

clear
% ADD PATH FOR TRACKING FUNCTIONS WRITTEN BY JCC/DLB
addpath([pwd,'/tracking']);

% 1. INPUT: Specify the location of the flame and centre line position
% Dimesions are pixel positions 
[filename, pathname] = uigetfile({'*.tif'},'Select input image',...
	'D:\EJR_GIT\droplets\stack.tif' );

% Set input parameters:
frame_start          = 15; % In raw data before differentation
frame_end            = 40;
bg_subt_lag_initial  = 5;
bg_subt_lag_increase_rate = 0.5;
radius_range_lo = 6; % 
radius_range_hi = 17; % 
sensitivity_hough    = 0.92;

% Prompt user to confirm parameters
prompt = {'frame_start', ...
	        'frame_end', ...
	        'bg_subt_lag_initial', ...
					'bg_subt_lag_increase_rate', ...
					'radius_range_lo', ...
					'radius_range_hi', ...
					'sensitivity_hough'};
dlg_title = 'Please confirm analysis parameters';
num_lines = 1;
defaultans = {num2str(frame_start ), num2str(frame_end), ...
	            num2str(bg_subt_lag_initial), num2str(bg_subt_lag_increase_rate), ...
							num2str(radius_range_lo), num2str(radius_range_hi) , num2str(sensitivity_hough)  };
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
% Update input parameters:
frame_start          = str2double( answer{1} ); % 
frame_end            = str2double( answer{2} ); % 
bg_subt_lag_initial  = str2double( answer{3} ); % 
bg_subt_lag_increase_rate = str2double( answer{4} ); % 
radius_range_lo = str2double( answer{5} ); % 
radius_range_hi = str2double( answer{6} ); % 
sensitivity_hough    = str2double( answer{7} ); % 
		

% 2. ANALYSIS
% Something...
pos = []; % x,y,t coordinates
for lp = frame_start:frame_end
	
	time = lp+1-frame_start;
	lag = bg_subt_lag_initial + floor(bg_subt_lag_increase_rate*(lp-frame_start));
	
	im_now = imread([pathname,filename],lp);
	im_prev= imread([pathname,filename],lp-lag);
	
	myDiffIm = imsubtract(im_now,im_prev);
	

	[centers, radii] = imfindcircles(myDiffIm, [6 17], 'sensitivity', sensitivity_hough);
	areas = radii.^2;
	newpos = [centers, time*(ones(size(centers,1),1)) ];
	pos = [pos; newpos ]; 
	
	figure(1)
	imagesc(myDiffIm )
	colormap(gray)
	
	hold on
	 scatter(centers(:,1), centers(:,2), areas)
	hold off
	drawnow

	% pause
end

% Tracking

maxdisp = 10;
res = track(pos,maxdisp);

% plot one track
track_number = 167;
figure(1)
hold on
plot(res((res(:,4)==track_number),1), res((res(:,4)==track_number),2),'r') ;
hold off
