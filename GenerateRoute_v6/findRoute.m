function findRoute(trip)
%%Description: This function is find the coRoute and linkList from a 
%             recorded trips
%
%%Input:
%       tirp: Ford recorded trip, .mat file
%       desktopPath: The desktop path of the user, who open the ADASRP
%       software.

%%Output:
%       coRoute:
%       -------------------------------------------------------------------
%       1:Longitude | 2:Latitude | 3:Numerical link ID | 4:road type | 5:?
%       6:ExpectedSpeed(mph) | 7:lane number | 8:Traffic light(0:NO 1:Yes)
%       9:Permenant link ID | 10:FC
%       -------------------------------------------------------------------
%
%       linkList:
%       -------------------------------------------------------------------
%       1:linkID | 2:linkID(Hex) | 3:RoadName
%       4:FC(0~4)(function class,4 is local;0 is major intercity highways;)
%       5:ExpectedSpeed(kmh) | 6:lane number | 7:Height | 8:Length
%       9:Traffic light
%       -------------------------------------------------------------------
%       
%       TMCnames: TMC code of each link in the linkList.
%       
%       indicator:
%       -------------------------------------------------------------------
%       0:Trip is too short or ..., can not be used
%       1:find the co-route successfully.
%       2: calling ADASRP fordPluin has problem
%       3: Cannot find match route


%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Date: 08/20/2014
%#########################################################################

%% Initialize globle variables
global XmlFileName
global coRoute TMC_name_List Link_Info_List

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
type tripdata.dat
%%