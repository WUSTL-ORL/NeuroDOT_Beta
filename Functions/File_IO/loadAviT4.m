function [t4,scale,header]=loadAviT4(filepath,filename)

% this function loads in the t4 file which transforms an mpr to the atlas
% space.


fid=fopen([filepath,filename]);
tline = fgetl(fid);
header={};
while ischar(tline)
    if tline(1) ~='t' && tline(1)~='s' && tline(1)~=' ' 
        header=cat(1,header,tline(1:end));
    end
    if tline(1:2)=='t4'
        for i=1:4
            tline = fgetl(fid);
            t4(i,:)=str2num(tline);
        end
    end
    if tline(1:5)=='scale'
        scale=str2num(tline(7:end));
    else scale=[];
    end
    tline = fgetl(fid);
end
fclose(fid);