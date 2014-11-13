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

tic;
% The folder path wehre store the temp data
Folder_Path = ini.GetValues('Path Setting', 'FOLDER_PATH');
DirF = dir(Folder_Path);

len = length(DirF);   % Calcluate how many files/folders are there in total

%% Traverse all files in the folder and process each trip file
for i=3:len                     % ignore './' and '../'
    folder_name = DirF(i).name;
    fprintf(['Processing folder:' folder_name '\n']);
    Data_Processing(Folder_Path, folder_name);
end

toc;