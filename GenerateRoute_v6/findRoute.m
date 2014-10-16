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
         
%% not be used right now
% [tempIdx,tempValue] = min(find(trip.Accuracy.Accuracy(tempIdx) == 0));
% tripTrace = [tripTrace(1,:);tripTrace(tempIdx:end,:)];

% debug code
%tripTrace(1:30,:) = [];
%

%% Generate the coRoute
Origin = [tripTrace(1,1),tripTrace(1,2)];      % Geoposition of Origin
Dest = [tripTrace(end,1),tripTrace(end,2)];    % Geoposition of Destination         

for i = 1:length(tripTrace)
    i
    Trip_Point = [tripTrace(i,1),tripTrace(i,2)];
   
    flag = callADASRP(Trip_Point);          % call ADASRP and get r
    try
        [shapePoints, TMCname, LinkInfo] = routeXMLparser(XmlFileName);
    catch
        return;
    end

    if ( isempty(Link_Info_List) || ~isequal(Link_Info_List(end,:), LinkInfo) )
        LinkInfo
        Link_Info_List = [Link_Info_List; LinkInfo];
        TMC_name_List = [TMC_name_List; TMCname];
        coRoute = [coRoute; shapePoints];
    end
end