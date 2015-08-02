function paq_Obj = rebuildPath(paq_Obj,bacePath)

%Allows you to change where the paq object looks for the .paq file by
%starting with a bacePath and then looking for a .paq file that matches
%the current .paq file. 
%if it can't find one then it looks for the .paq files in the subfolders 
%that it previously existed in off of the new bacepath


if ~exist(bacePath,'dir')
    error('the specified bace path does not exist or is not a directory')
end
    
oldpath = paq_Obj.fullpath;

%different slashes depending on computer system
if isunix
    folderIndx = strfind(oldpath,'/');
else
    folderIndx = strfind(oldpath,'\');
end

%find the index of the pathstring where new folders are denoted
folderIndx = sort(folderIndx,'descend');


ifolder = length(folderIndx);
while ifolder > 0

    RemainingPath = oldpath(folderIndx(ifolder):end);
    
    if exist([bacePath,RemainingPath],'file')
        ifolder = 0;
    elseif ifolder == 1
        error('could not find path')
    else
        ifolder = ifolder - 1;
    end

end

paq_Obj.fullpath = [bacePath,RemainingPath];
