function [flag] = Link_Info_Extraction(Trip_Point)

global XmlFileName
global coRoute TMC_name_List Link_Info_List

flag = YuanMa_callADASRP(Trip_Point);          % call ADASRP and get r

try
    [shapePoints, TMCname, LinkInfo] = YuanMa_routeXMLparser(XmlFileName);
catch
    return;
end
    
if ( isempty(Link_Info_List) || ~isequal(Link_Info_List(end,:), LinkInfo) )
    LinkInfo
    Link_Info_List = [Link_Info_List; LinkInfo];
    TMC_name_List = [TMC_name_List; TMCname];
    coRoute = [coRoute; shapePoints];
end
%delete(XmlFileName, CsvFileName);