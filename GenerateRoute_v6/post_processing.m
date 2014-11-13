function [coRoute] = post_processing(csv_file)
[Data, Header, Raw]   =  xlsread(csv_file);
Header = Header(1, :);
[~, index]  = ismember('Road Name', Header);

road_data = char(Raw(2:end, index));
abnormal_index = zeros(length(road_data), 1);
for i = 2:length(road_data) - 1
    if (~strcmp(road_data(i-1, :), road_data(i, :))) && ...
            (strcmp(road_data(i-1, :), road_data(i+1, :)))
        abnormal_index(i) = true;
    end
end
abnormal_index = [0; abnormal_index];
Raw = Raw(~abnormal_index, :);

%% second examination
road_data = char(Raw(2:end, index));
abnormal_index = zeros(length(road_data), 1);
count = 0;
temp = 2;
abnormal_index(1) = 1;
for i = 2:length(road_data)
    if strcmp(road_data(i-1, :), road_data(i, :))
        count = count + 1;
        continue;
    else
        if count > 7
            abnormal_index(temp:i-1) = false;
            temp = i;
        else
            abnormal_index(temp:i-1) = true;
            temp = i;
        end
        count = 1;
    end
end

abnormal_index = [0; abnormal_index];
Raw = Raw(~abnormal_index, :);

%% elimate the redundancy
[~, linkID_index]  = ismember('Permanent ID', Header);
linkID_data = cell2mat(Raw(2:end, linkID_index));

linkID_index = zeros(length(linkID_data), 1);
linkID_index(1) = 1;

for i = 2:length(Raw) - 1
    if linkID_data(i-1, :) == linkID_data(i, :)
        continue;
    else
        linkID_index(i) = true;
        
    end
end

% eliminate again
[~, shape_point_index]  = ismember('Shape Point', Header);

linkID_index = [0; linkID_index];
Final = Raw(logical(linkID_index), :);

[~, index]  = ismember('Road Name', Header);

road_data = char(Final(2:end, index));
abnormal_index = zeros(length(road_data), 1);
for i = 2:length(road_data) - 1
    if (~strcmp(road_data(i-1, :), road_data(i, :))) && ...
            (strcmp(road_data(i-1, :), road_data(i+1, :)))
        abnormal_index(i) = true;
    end
end
abnormal_index = [0; abnormal_index];
Final = Final(~abnormal_index, :);


% this is for one column data
coRoute = [];

for i = 1:size(Final, 1)
    linkID = cell2mat(Final(i, 7));
    pointformat  = '(-)?[0-9]{2,}:(-)?[0-9]{2,}[^:;]';
    shape_points_cell = regexp(char(Final(i, shape_point_index)), pointformat, 'match');
    
    for j = 1:size(shape_points_cell, 2)
        shape_points = strsplit(char(shape_points_cell(1, j)), ':');
        latitude = str2double(char(shape_points(1,1))) / 10^7; % first column
        longitude = str2double(char(shape_points(1,2))) / 10^7; % second column
        shape_point_info = [latitude, longitude, 0, 0, 0, 0, 0, 0, linkID, 0];
        coRoute = [coRoute; shape_point_info];
    end
end






