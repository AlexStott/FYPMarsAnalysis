%Final year project - Through Focal combination section
%Variance based method
%This method relies on calculating the areas of greatest variance and
%selecting them for the final image merge

%Load image stack

%load('camera_00/imdata.mat');
images = [];
StackNum = 16;
for i = 1:StackNum
    imstring = strcat('phoenix3/mars',num2str(i));
    imstring = strcat(imstring,'.png');
    images = [images Image(i,imread(imstring))];
end

Sobel = [-1 -2 -1; 0 0 0;1 2 1];
imagesfilt1 = [];
imagesfilt2 = [];
imfilt1 = [];
imfilt2 = [];
for i=1:StackNum
    imagesfilt1 = [imagesfilt1 Image(images(i).height,abs(filter2(Sobel,images(i).Im))+abs(filter2(Sobel',images(i).Im)))];
%    imagesfilt2 = [imagesfilt2 Image(images(i).height,filter2(Sobel',images(i).Im))];
%    imfilt1 = [imfilt1 Image(images(i).height,imfilter(images(i).Im,Sobel))];
%    imfilt2 = [imfilt2 Image(images(i).height,imfilter(images(i).Im,Sobel'))];
end

mean = [1 1 1;1 1 1;1 1 1]./9;

imagesfiltsmooth1 = [];

for i=1:StackNum
    imagesfiltsmooth1 = [imagesfiltsmooth1 Image(images(i).height,filter2(mean,imagesfilt1(i).Im))];
%    imagesfiltsmooth2 = [imagesfiltsmooth2 Image(images(i).height,filter2(mean,imagesfilt2(i).Im))];
end


Xpixel = 256;
Ypixel = 512;


SelectedImTexture = zeros(Xpixel,Ypixel);
SelectedImHeight = zeros(Xpixel,Ypixel);
tempval = 0;

for i = 1:Xpixel
    for j = 1:Ypixel
        for k = 1:StackNum
            if imagesfiltsmooth1(k).Im(j,i) > tempval
                SelectedImTexture(j,i) = tempval;
                SelectedImHeight(j,i) = imagesfiltsmooth1(k).height;
            end     
        end       
    end
end

        