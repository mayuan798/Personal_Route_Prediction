%#########################################################################
%Description: This program is used to generate route information from a
%             recorded trip. Route information includes link and shape 
%             point info
%Author: Yuan Ma
%Contact: myuan@umich.edu
%Version: 0.9
%Copyright: University of Michigan Dearborn
%Date: 11/13/2014
%#########################################################################

%% Read the configuration file and Initialize parameters
clear all; clc; tic;
ini = IniConfig();
ini.ReadFile('configuration.ini');

% The folder path wehre store the temp data
Folder_Path = ini.GetValues('Path Setting', 'FOLDER_PATH');
DirF = dir(Folder_Path); % List all the files and folders (structure)
len = length(DirF);   % Calcluate how many files/folders are there in total

tic;
%% Traverse all files in the folder and process each trip file
for i=3:len                     % ignore './' and '../'
    %try
    %[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB code file');
    filename = DirF(i).name;
    fprintf(['Processing file:' filename '\n']);
    load([Folder_Path DirF(i).name]);            % load .mat trip data (structure only contains 'trip')
    log = trip.Location.Longitude;                  % get a list of points' lognitude
    lat = trip.Location.Latitude;                   % get a list of points' latitude
    if(length(log)~=length(lat))                    % ignore the trip data where the size of lognitude is not equal to that of latitude
        continue;
    end
    
    TMCnames = [];
    linkList = [];
    coRoute  = [];
    
    %% Check trip data
    % check and filter out the trip data whose data point is less than 500
    if(length(trip.Location.Time)<500)
        return;
    end
    % check and filter out the point whose recorded time less than 10 minutes
    if((trip.Location.Time(end))<10*60)
        return;
    end

    %% Pre-process trip, filter our low speed point
    speedThrehold = 3;
    tempIdx = (trip.Movement.GPSSpeed > speedThrehold);
    % tripTrace is the list contains all points that will be used in this trip
    % data
    tripTrace = [trip.Location.Latitude(tempIdx), ...
                 trip.Location.Longitude(tempIdx)];

    fileID = fopen('tripdata.dat','w');
    formatSpec = '%2.6f \t %2.6f\n';

    [nrows, ncols] = size(tripTrace);
    for row = 1:nrows
        fprintf(fileID,formatSpec, tripTrace(row,:));
    end
    fclose(fileID);
    
    try
        system('run.bat');
    catch me
        disp('Can not call ADASRP');
        flag = 0;
        return;
    end 
    
    coRoute = post_processing('tripdata.csv');
    save(['./saveData/yuanma_' filename(1:end-12) '.mat'],'coRoute','linkList','TMCnames', 'trip');
end
toc;