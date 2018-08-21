function SaveGCF_to_PNG(fn,kill)
%
% This function outputs a figure to the filename fn as a png, and 
% closes it

if ~exist('kill','var'),kill=1;end


pause(1)
set(gcf, 'InvertHardCopy', 'off');
set(gcf,'PaperPositionMode','auto')
print(fn,'-dpng','-r600','-cmyk')

if kill, close; end
pause(1)