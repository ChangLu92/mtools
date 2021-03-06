function [pixId imageName] = getPixIdFromROIFile(imageName, omeroUser, omeroServer)
%Pass in a filename and return the matching pixelsId as read from the
%roiFileMap.xml system file.
%
%Author Michael Porter

% Copyright (C) 2009-2014 University of Dundee.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

%[imageName, remain] = strtok(imageName, '.');

%On Windows systems...
if ispc;
    sysUserHome = getenv('userprofile');
    sysUser = getenv('username');
    defaultUserPath = userpath;
if strcmp(defaultUserPath(1), 'H')
    %This is a really horrible hack to get around working on this Domain.
    %Sorry!!!!
    mapPath = 'H:\omero\roiFileMap.xml';
else
    mapPath = [sysUserHome '\omero\roiFileMap.xml'];
end
    mapStruct = xml2struct(mapPath);

    for thisServer = 1:length(mapStruct.children)
        if strcmp(mapStruct.children(thisServer).name, '#text')
            continue;
        end
        if strcmpi(mapStruct.children(thisServer).attributes(1).value, omeroServer)
            for thisUser = 1:length(mapStruct.children(thisServer).children)
                if strcmp(mapStruct.children(thisServer).children(thisUser).name, '#text')
                    continue;
                end
                if strcmpi(mapStruct.children(thisServer).children(thisUser).attributes(1).value, omeroUser)
                    for thisImage = 1:length(mapStruct.children(thisServer).children(thisUser).children)
                        if strcmp(mapStruct.children(thisServer).children(thisUser).children(thisImage).name, '#text')
                            continue;
                        end
                        for thisFile = 1:length(mapStruct.children(thisServer).children(thisUser).children(thisImage).children)
                            if strcmp(mapStruct.children(thisServer).children(thisUser).children(thisImage).children(thisFile).name, '#text')
                                continue;
                            end
                            partName = mapStruct.children(thisServer).children(thisUser).children(thisImage).children(thisFile).attributes(1).value;
                            %                     while ~isempty(partName)
                            %                         [nameProc, partName] = strtok(partName, '\');
                            %                     end
                            %[imageNameFromStruct, remain] =
                            %strtok(nameProc, '.');
%                             imageNameScanned = textscan(imageName, '%s', 'Delimiter', '/');
%                             imageNameNoPaths = imageNameScanned{1}{end};
                            if strcmp(partName, imageName)
                                pixId = mapStruct.children(thisServer).children(thisUser).children(thisImage).attributes(1).value;
                                return;
                            else
                                pixId = [];
                            end
                        end
                    end
                end
            end
        end
    end
    clear mapStruct;
else
    %On Mac and Unix systems...
    sysUser = getenv('HOME');
    mapPath = [sysUser, '/omero/roiFileMap.xml'];
    mapStruct = xml2struct(mapPath);

    for thisServer = 1:length(mapStruct.children)
        if strcmpi(mapStruct.children(thisServer).attributes(1).value, omeroServer)
            for thisUser = 1:length(mapStruct.children(thisServer).children)
                if strcmpi(mapStruct.children(thisServer).children(thisUser).attributes(1).value, omeroUser)
                    for thisImage = 1:length(mapStruct.children(thisServer).children(thisUser).children)
                        [nameProc, partName] = strtok(mapStruct.children(thisServer).children(thisUser).children(thisImage).children.attributes(1).value, '/');
                        while ~isempty(partName)
                            [nameProc, partName] = strtok(partName, '/');
                        end
                        [imageNameFromStruct, remain] = strtok(nameProc, '.');
                        if strcmp(imageNameFromStruct, imageName)
                            pixId = mapStruct.children(thisServer).children(thisUser).children(thisImage).attributes(1).value;
                            return;
                        end
                    end
                end
            end
        end
    end
    clear mapStruct;
end




end
