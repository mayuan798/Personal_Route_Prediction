%#########################################################################
%Description: This program is used to generate route information from a
%             recorded trip. Route information includes link and shape 
%             point info
%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Version: 6
%Copyright: University of Michigan Dearborn
%Date: 8/20/2014
%#########################################################################

%% Read the configuration file and Initialize parameters
clear all; clc;
ini = IniConfig();
ini.ReadFile('configuration.ini');
% The folder path wehre store the temp data

global Folder_Path Desktop_Path XmlFileName CsvFileName
global coRoute TMC_name_List Link_Info_List

Folder_Path = ini.GetValues('Path Setting', 'FOLDER_PATH');
Desktop_Path = ini.GetValues('Path Setting', 'DESKTOP_PATH');
DirF = dir(Folder_Path); % List all the files and folders (structure)
len=length(DirF);   % Calcluate how many files/folders are there in total
XmlFileName = [Desktop_Path 'route.xml'];
CsvFileName = [Desktop_Path 'route.csv'];

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
    
    coRoute = [];
    TMC_name_List = [];
    Link_Info_List = [];
    trip
    findRoute(trip);
    %save(['./saveData/' filename(1:end-12) '.mat'],'coRoute','Link_Info_List','TMC_name_List','trip');
end

%delete(XmlFileName, CsvFileName);