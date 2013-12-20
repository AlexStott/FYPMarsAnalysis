%Final year project - Through Focal combination section
%Variance based method
%This method relies on calculating the areas of greatest variance (either using a Sobel operator or first derivative function 
%created by Piccinini) and selecting them for the final image merge

%Load image stack

load('camera_00/imdata.mat');
images = [];
stackheightint = 75;
StackNum = 16;
for i = 1:StackNum
    imstring = strcat('phoenix3/mars',num2str(i));%camera_00/sim_',num2str(i));
    imstring = strcat(imstring,'.png');
    images = [images Image((i-1)*stackheightint,imread(imstring))];%(StackNum-1)*stackheightint - (i-1)*stackheightint
end

%initialise Sobel operator and arrays

Sobel = [-1 -2 -1; 0 0 0;1 2 1];
imagesfilt1 = [];
imagesfilt2 = [];
imfilt1 = [];
imfilt2 = [];

%Calculate the variance of the images in the stack

for i=1:StackNum
    imagesfilt1 = [imagesfilt1 Image(images(i).height,FirstDerivativeXY(images(i).Im))];%abs(filter2(Sobel,images(i).Im))+abs(filter2(Sobel',images(i).Im)))];
%    imagesfilt2 = [imagesfilt2 Image(images(i).height,filter2(Sobel',images(i).Im))];
%    imfilt1 = [imfilt1 Image(images(i).height,imfilter(images(i).Im,Sobel))];
%    imfilt2 = [imfilt2 Image(images(i).height,imfilter(images(i).Im,Sobel'))];
end

%Smooth the calculated values
mean = ones(5,5)./25;%[1 1 1;1 1 1;1 1 1]./9;

imagesfiltsmooth1 = [];

for i=1:StackNum
    imagesfiltsmooth1 = [imagesfiltsmooth1 Image(images(i).height,filter2(mean,imagesfilt1(i).Im))];
%    imagesfiltsmooth2 = [imagesfiltsmooth2 Image(images(i).height,filter2(mean,imagesfilt2(i).Im))];
end


%Calculate the image in the stack with the greatest variance at each point
Xpixel = 256;
Ypixel = 512;


SelectedImTexture = zeros(Ypixel,Xpixel);
SelectedImHeight = zeros(Ypixel,Xpixel);
SelectedImNum = zeros(Ypixel,Xpixel);
tempval = 0;


for i = 1:Xpixel
    for j = 1:Ypixel
        for k = 1:StackNum
            if imagesfiltsmooth1(k).Im(j,i) > tempval
%                SelectedImTexture(j,i) = imagesfiltsmooth1(k).Im(j,i);
%                SelectedImHeight(j,i) = imagesfiltsmooth1(k).height;
                if k > 0
                    SelectedImNum(j,i) = k;
                else
                    SelectedImNum(j,i) = 1;
                end
                tempval = imagesfiltsmooth1(k).Im(j,i);
            end     
        end 
        tempval = 0;
    end
end

%Median filter

MedSize = 4;
med = [];
SelectedImNumMed = [];

for i = MedSize+1:Xpixel-MedSize
    for j = MedSize+1:Ypixel-MedSize
        med = SelectedImNum(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
        MedVal = median(med);
        MedVal = median(MedVal);
        MedVal = round(MedVal);
        SelectedImNumMed(j,i) = MedVal;
%         if MedVal > 0
%             SelectedImNumMed(j,i) = MedVal;
%         else
%             SelectedImNumMed(j,i) = 1;
    end
end

%Select final image heights and texture from original image

for i = 1+MedSize:Xpixel-MedSize
    for j = 1+MedSize:Ypixel-MedSize
        if SelectedImNumMed(j,i) > 0
            SelectedImTexture(j,i) = images(SelectedImNumMed(j,i)).Im(j,i);
            SelectedImHeight(j,i) = images(SelectedImNumMed(j,i)).height;
        else
            SelectedImTexture(j,i) = images(1).Im(j,i);
            SelectedImHeight(j,i) = images(1).height;
        end
    end
end

%smooth resultant image

SelectedImHeight2 = filter2(mean,SelectedImHeight);
SelectedImTexture2 = filter2(mean,SelectedImTexture);
% subplot(1,2,1)
% imagesc(SelectedImHeight)%Texture)
% colormap(gray);
% subplot(1,2,2)
% imagesc(SelectedImHeight2)

%Plot image with the texture imposed on the surface
mesh(SelectedImHeight2',SelectedImTexture2')
colormap(gray)
imwrite(SelectedImTexture2,'textureOut.jpg')
imwrite(SelectedImHeight2,'Height.jpg')

