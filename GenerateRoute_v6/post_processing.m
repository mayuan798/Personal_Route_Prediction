clc, clear all; close all;
[Data, Header, Raw]   =  xlsread('tripdata.csv');
Header = Header(1, :);
origin_data = Data;
[~, index]  = ismember('Road Name', Header);
road_data = char(Raw(2:end, index));
abnormal_index = zeros(length(road_data), 1);


previous = road_data(1, :);
for i = 2:length(road_data) - 1
    if (~strcmp(road_data(i-1, :), road_data(i, :))) && ...
            (strcmp(road_data(i-1, :), road_data(i+1, :)))
        abnormal_index(i) = true;
    end
end
abnormal_index = [0; abnormal_index];
Modified = Raw(~abnormal_index, :);

%% elimate the redundancy
[~, linkID_index]  = ismember('Permanent ID', Header);
linkID_data = cell2mat(Modified(2:end, linkID_index));

linkID_index = zeros(length(linkID_data), 1);
linkID_index(1) = 1;
for i = 2:length(Modified) - 1
    if linkID_data(i-1, :) == linkID_data(i, :)
        continue;
    else
        linkID_index(i) = true;
    end
end

linkID_index = [0; linkID_index];
Final = Modified(logical(linkID_index), :);

pointformat  = '(-)?[0-9]{2,}:(-)?[0-9]{2,}[^:;]';
shape_points = regexp(char(Final(1,15)), pointformat, 'match');