function Data_Proprocessing(Folder_Path, folder_name)

save_folder = strcat('./saveData/', folder_name);
mkdir_if_not_exist(save_folder);

DirF = dir(strcat(Folder_Path, '/', folder_name)); % List all the files and folders (structure)
len = length(DirF);   % Calcluate how many files/folders are there in total

%% Traverse all files in the folder and process each trip file
for i=3:len                     % ignore './' and '../'
    %try
    %[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB code file');
    filename = DirF(i).name;
    fprintf(['Processing file:' filename '\n']);
    load(strcat(Folder_Path, '/', folder_name, '/', DirF(i).name));  % load .mat trip data (structure only contains 'trip')
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
    
    save(strcat(save_folder, '/yuanma_', filename(1:end-12), '.mat'), 'coRoute', 'linkList', 'TMCnames', 'trip');
end