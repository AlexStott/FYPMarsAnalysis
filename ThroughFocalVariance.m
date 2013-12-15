%Final year project - Through Focal combination section
%Variance based method
%This method relies on calculating the areas of greatest variance and
%selecting them for the final image merge

%Load image stack

%load('camera_00/imdata.mat');
images = [];
for i = 1:8
    imstring = strcat('phoenix/mars',num2str(i));
    imstring = strcat(imstring,'.img');
    images = [images imread(imstring)];
end
%impla=[];
%for i = 1:215
%   impla = [impla; images(i,1:215)];
%end
%image(impla)