%Final year project - Through Focal combination section
%Wavelet Method
%Perform coomplex base Wavelet transform on each image and identify which
%image has the greatest contribution at each base. These parts are combined
%to form the final image. Based on method by Forster et al

%Load image stack

load('camera_00/imdata.mat');
images = [];
stackheightint = 75;
StackNum = 16;
for i = 1:StackNum
    imstring = strcat('phoenix3/mars',num2str(i));%camera_00/sim_',num2str(i));
    imstring = strcat(imstring,'.png');
    images = [images Image((i-1)*stackheightint,double(imread(imstring)))];%(StackNum-1)*stackheightint - (i-1)*stackheightint
end

%Complex Wavelet transform

%df = dbaux(3);
wname = 'db3';
[Lo_D,Hi_D,Lo_R,Hi_R] = wfilters(wname);
WavNum = 1;
af = [Lo_D; Hi_D]';
sf = [Lo_R; Hi_R]';

WaveletTransformedImages = [];

for i = 1:StackNum
    WaveletTransformedImages = [WaveletTransformedImages Image(images(i).height, dwt2D(images(i).Im,WavNum,af))];%dddtree2('cplxdddt',images(i).Im,WavNum,df))];%'self1'))];
  
end

Xpixel = 256;
Ypixel = 512;

SelectedImWAV = [];
SelectedImNum = [];
SelectedWav = [];
tempval = zeros(1,4);

for i = 1:Xpixel/2
    for j = 1:Ypixel/2
        for k = 1:StackNum
            if abs(WaveletTransformedImages(k).Im{1,2}(j,i)) > tempval(1)
                SelectedImWAV{1,2}(j,i) = WaveletTransformedImages(k).Im{1,2}(j,i);
                SelectedImNum{1,2}(j,i) = k;
                tempval(1) = WaveletTransformedImages(k).Im{1,2}(j,i);
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,1}(j,i)) > tempval(2)
                SelectedImWAV{1,1}{1,1}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,1}(j,i);
                SelectedImNum{1,1}{1,1}(j,i) = k;
                tempval(2) = WaveletTransformedImages(k).Im{1,1}{1,1}(j,i);
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,2}(j,i)) > tempval(3)
                SelectedImWAV{1,1}{1,2}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,2}(j,i);
                SelectedImNum{1,1}{1,2}(j,i) = k;
                tempval(3) = WaveletTransformedImages(k).Im{1,1}{1,2}(j,i);
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,3}(j,i)) > tempval(4)
                SelectedImWAV{1,1}{1,3}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,3}(j,i);
                SelectedImNum{1,1}{1,3}(j,i) = k;
                tempval(4) = WaveletTransformedImages(k).Im{1,1}{1,3}(j,i);
            end
        end
        tempval = zeros(1,4);
    end
end

SelectedImTexture = idwt2D(SelectedImWAV,WavNum,sf);
SelectedNum = idwt2D(SelectedImNum,WavNum,sf);

        