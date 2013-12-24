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
%[af, sf] = farras;

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
%tempval(1)=1000;

for i = 1:Xpixel/2
    for j = 1:Ypixel/2
        for k = 1:StackNum
            if abs(WaveletTransformedImages(k).Im{1,2}(j,i)) > tempval(1)
                SelectedImWAV{1,2}(j,i) = WaveletTransformedImages(k).Im{1,2}(j,i);
                SelectedImNum{1,2}(j,i) = k;
                tempval(1) = abs(WaveletTransformedImages(k).Im{1,2}(j,i));
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,1}(j,i)) > tempval(2)
                SelectedImWAV{1,1}{1,1}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,1}(j,i);
                SelectedImNum{1,1}{1,1}(j,i) = k;
                tempval(2) = abs(WaveletTransformedImages(k).Im{1,1}{1,1}(j,i));
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,2}(j,i)) > tempval(3)
                SelectedImWAV{1,1}{1,2}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,2}(j,i);
                SelectedImNum{1,1}{1,2}(j,i) = k;
                tempval(3) = abs(WaveletTransformedImages(k).Im{1,1}{1,2}(j,i));
            end
            if abs(WaveletTransformedImages(k).Im{1,1}{1,3}(j,i)) > tempval(4)
                SelectedImWAV{1,1}{1,3}(j,i) = WaveletTransformedImages(k).Im{1,1}{1,3}(j,i);
                SelectedImNum{1,1}{1,3}(j,i) = k;
                tempval(4) = abs(WaveletTransformedImages(k).Im{1,1}{1,3}(j,i));
            end
        end
        tempval = zeros(1,4);
       % tempval(1) = 1000;
    end
end

%Median filter

 MedSize = 4;
 med = zeros(1,4);
 SelectedImWAVMed = [];
 SelectedNumMed = [];

for i = 1:Xpixel/2
    for j = 1:Ypixel/2
        med(1) = SelectedImNum{1,2}(j,i);%-MedSize:j+MedSize,i-MedSize:i+MedSize);
        med(2) = SelectedImNum{1,1}{1,1}(j,i);
        med(3) = SelectedImNum{1,1}{1,2}(j,i);
        med(4) = SelectedImNum{1,1}{1,3}(j,i);
        
        MedVal = median(med);
        %MedVal = median(MedVal);
        MedVal = round(MedVal);
         SelectedImWAVMed{1,2}(j,i) = WaveletTransformedImages(MedVal).Im{1,2}(j,i);
         SelectedImWAVMed{1,1}{1,1}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,1}(j,i);
         SelectedImWAVMed{1,1}{1,2}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,2}(j,i);
         SelectedImWAVMed{1,1}{1,3}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,3}(j,i);
        SelectedNumMed(j,i) = MedVal;    
    end
end

MedSize = 4;
med = [];
SelectedImNumMed = SelectedNumMed;


for i = MedSize+1:Xpixel/2-MedSize
    for j = MedSize+1:Ypixel/2-MedSize
        med = SelectedNumMed(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
        MedVal = median(med);
        MedVal = median(MedVal);
        MedVal = round(MedVal);
        SelectedImNumMed(j,i) = MedVal;
        SelectedImWAVMed{1,2}(j,i) = WaveletTransformedImages(MedVal).Im{1,2}(j,i);
        SelectedImWAVMed{1,1}{1,1}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,1}(j,i);
        SelectedImWAVMed{1,1}{1,2}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,2}(j,i);
        SelectedImWAVMed{1,1}{1,3}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,3}(j,i);

%         if MedVal > 0
%             SelectedImNumMed(j,i) = MedVal;
%         else
%             SelectedImNumMed(j,i) = 1;
    end
end

% for i = 1:Xpixel
%     SelectedImWAVMed{1,2}(Ypixel-MedSize:Ypixel,i) = WaveletTransformedImages(MedVal).Im{1,2}(j,i);
%     SelectedImWAVMed{1,1}{1,1}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,1}(j,i);
%     SelectedImWAVMed{1,1}{1,2}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,2}(j,i);
%     SelectedImWAVMed{1,1}{1,3}(j,i) = WaveletTransformedImages(MedVal).Im{1,1}{1,3}(j,i);


SelectedHeight = [];

for i = 1:Xpixel/2
    for j = 1:Ypixel/2
        SelectedHeight(2*j:2*j+1,2*i:2*i+1) = SelectedImNumMed(j,i);
    end
end
% for i = MedSize+1:Xpixel/2-MedSize
%     for j = MedSize+1:Ypixel/2-MedSize
%         med = SelectedImWAV{1,2}(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
%         MedVal = median(med);
%         MedVal = median(MedVal);
%         MedVal = round(MedVal);
%         SelectedImWAVMed{1,2}(j,i) = MedVal;
%        
%         med = SelectedImWAV{1,1}{1,1}(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
%         MedVal = median(med);
%         MedVal = median(MedVal);
%         MedVal = round(MedVal);
%         SelectedImWAVMed{1,1}{1,1}(j,i) = MedVal;
%         
%         med = SelectedImWAV{1,1}{1,2}(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
%         MedVal = median(med);
%         MedVal = median(MedVal);
%         MedVal = round(MedVal);
%         SelectedImWAVMed{1,1}{1,2}(j,i) = MedVal;
%         
%         med = SelectedImWAV{1,1}{1,3}(j-MedSize:j+MedSize,i-MedSize:i+MedSize);
%         MedVal = median(med);
%         MedVal = median(MedVal);
%         MedVal = round(MedVal);
%         SelectedImWAVMed{1,1}{1,3}(j,i) = MedVal;
%         
% %         if MedVal > 0
% %             SelectedImNumMed(j,i) = MedVal;
% %         else
% %             SelectedImNumMed(j,i) = 1;
%     end
% end

%SelectedImWAV{1,2} = zeros(Xpixel/2,Ypixel/2);

SelectedImTexture = idwt2D(SelectedImWAVMed,WavNum,sf);
SelectedNum = idwt2D(SelectedImNum,WavNum,sf);
testIm = idwt2D(WaveletTransformedImages(15).Im,WavNum,sf);
subplot(1,2,1)
imagesc(SelectedImTexture);
subplot(1,2,2)
mesh(SelectedHeight,SelectedImTexture)
%imagesc(images(15).Im)
colormap(gray)
