function [FocusIMAGE, DepthMap] = DFF_CUR(parameters)
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 14 February 2012
% FILE NAME: DFF_LocalAnalysis.m
% 
% To obtain the final in-focus 2-D image, starting from a stack of slices
% where only small areas of each slices are in focus. The algorithm is
% based on a Curvelet analysis of each input image. 
%
% This implementation is inspired to the article:
% Linda Tessens, Alessandro Ledda, Aleksandra Pizurica and Wilfried 
% Philips, "Extending The Depth Of Field In Microscopy Through 
% Curvelet-Based Frequency-Adaptive Image Fusion For the high frequency".
% IEEE International Conference on Acoustics, Speech and Signal Processing 
% (ICASSP), 15-20 April 2007, Honolulu, HI.
%
% For the high frequency is used a absolute value's maximum selection rule 
% of the coefficients among the slices that compose the z-vector of the 
% stack. For the low-pass image is used the slice of the z-vector stack 
% from which are taken most of the coefficients for high frequency 
% subbands. Finally, the composite image is built using the inverse 
% Curvelet transform. The algorithm works with both GRAY or RGB images and 
% the output image is of the same type of the input ones.
%
% The functions to achieve the Curvelt transform and the inverse Curvelet
% trasform must be downloaded from the website www.curvelet.org. 
%
% USAGE: 
% [FocusIMAGE, DepthMap] = DFF_CUR;
%
% INPUT PARAMETERS:
% 	parameters              All the input parameters are set and explained 
%                           in the file named: DFF_CUR_Parameters.m
%
% OUTPUT:
%   FocusIMAGE              Final composite image where all the regions
%                           should be in-focus.
%   DepthMap                2D mask reporting for each x-y pixel position
%                           the index of the original image that has the
%                           pixel value nearest at the pixel value of
%                           FocusIMAGE.
%
% See also DFF_CUR_Parameters

% Depth From Focus Toolbox
% Copyright © 2012 Filippo Piccinini, Alessandro Bevilacqua, 
% Advanced Research Center on Electronic Systems (ARCES), 
% University of Bologna, Italy. All rights reserved.
%
% This program is free software; you can redistribute it and/or modify it 
% under the terms of the GNU General Public License version 2 (or higher) 
% as published by the Free Software Foundation. This program is 
% distributed WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
% General Public License for more details.

% PARAMETERS READING
if nargin<1
    parameters = DFF_CUR_Parameters();
end
parameters
stop_index = length(parameters.ImageIndexes);

% OTHER PARAMETERS
flag_rgb2gray_pca = 1;

% GRAY CONVERSION PARAMETERS SET UP
strnum = sprintf('%.3d',parameters.ImageIndexes(1));
name = strcat(parameters.ImageFolder,parameters.ImageBaseName,strnum,parameters.ImageFormat);
OrigImg = imread(name);
if size(OrigImg,3) == 3
    flag_3channels = 1;
else
    flag_3channels = 0;
end
clear OrigImg name strnum
if flag_rgb2gray_pca == 1
    if flag_3channels == 1
        for nf=1:stop_index
            strnum = sprintf('%.3d',parameters.ImageIndexes(nf));
            name = strcat(parameters.ImageFolder,parameters.ImageBaseName,strnum,parameters.ImageFormat);
            OrigImg = imread(name);
            R = double(OrigImg(:,:,1));
            G = double(OrigImg(:,:,2));
            B = double(OrigImg(:,:,3));
            [NI1, NI2, LR] = princomp(double(R));
            [NI1, NI2, LG] = princomp(double(G));
            [NI1, NI2, LB] = princomp(double(B));
            L_R(nf) = max(LR);
            L_G(nf) = max(LG);
            L_B(nf) = max(LB);
            clear NI1 NI2 LB LG LR B G R OrigImg name strnum
        end
        L_Rmean = mean(L_R);
        L_Gmean = mean(L_G);
        L_Bmean = mean(L_B);
        clear L_R L_G L_B
        FatNorm = L_Rmean + L_Gmean + L_Bmean;
        L_Rw = L_Rmean/FatNorm;
        L_Gw = L_Gmean/FatNorm;
        L_Bw = L_Bmean/FatNorm;
        clear FatNorm L_Rmean L_Gmean L_Bmean
    end      
end

% IMAGES STACK CREATION
for nf=1:stop_index
    strnum = sprintf('%.3d',parameters.ImageIndexes(nf));
    name = strcat(parameters.ImageFolder,parameters.ImageBaseName,strnum,parameters.ImageFormat);
    OrigImg = imread(name);
    if flag_3channels == 1
        StackRGB{nf} = OrigImg;
        if flag_rgb2gray_pca == 1
            R = double(OrigImg(:,:,1));
            G = double(OrigImg(:,:,2));
            B = double(OrigImg(:,:,3));
            StackGRAY(:,:,nf) = L_Rw*R + L_Gw*G + L_Bw*B; 
            clear R G B
        else
            StackGRAY(:,:,nf) = double(rgb2gray(OrigImg));
        end
    else
        StackGRAY(:,:,nf) = double(OrigImg);%_img);
    end
    clear OrigImg name strnum
end

[rows columns channels] = size(StackGRAY);

% From the help of the function "mefcv2" (www.curvelet.org):
% numscale is the number of levels, including the coarsest level. 
% numscale = ceil(log2(min(rows,columns)) - 3) is commonly used.
numscale = ceil(log2(min(rows,columns))-3);

% From the help of the function "mefcv2" (www.curvelet.org):
% 2*pi/nag is the size of the spanning angle of each wedge.
% nag is required to be a multiple of 8 and nag = 16 is often used.
nag = 16;

% CURVELET TRANSFORM OF STACK
StackCUR = cell(channels,1);
for nf=1:channels
    % the function "mefcv2" must be downloaded from: www.curvelet.org
    StackCUR{nf} = mefcv2(StackGRAY(:,:,nf),rows,columns,numscale,nag);
end

% IMAGE FUSION, PROCESSING OF THE HIGH FREQUENCY SUB-BANDS: 
% MAXIMUM ABSOLUTE VALUE SELECTION RULE
Icounter = zeros(channels,1);
FocusCUR = cell(numscale,1);
for j=2:numscale % The first scale is analyzed in follow
    for l=1:length(StackCUR{1}{j})
        
        % Stack for one scale for one direction
        StackImCur(:,:,channels) = zeros(size(StackCUR{1}{j}{l}));
        for nf=1:channels
            StackImCur(:,:,nf) = StackCUR{nf}{j}{l};
        end
        
        % Maximum z-selection across the stack        
        [SICmax, SICind] = max(abs(StackImCur),[],3);
        [rowsC columnsC channelsC] = size(StackImCur);
        for k=1:rowsC
            for m=1:columnsC
                FocusCUR{j}{l,1}(k,m) = StackImCur(k,m,SICind(k,m));
            end
        end
        
        % Counter updating
        for nf=1:channels
            Icounter(nf) = Icounter(nf) + length(find(SICind==nf));
        end  
        clear rowsC columnsC channelsC StackImCur SICmax SICind
    end
end

% IMAGE FUSION, PROCESSING THE LOW-PASS IMAGE:
% SELECTION OF THE SLICE FROM WHICH THE MAJORITY OF 
% CORRISPONDING COEFFICIENTS WAS SELECTED
slice = Icounter==max(Icounter);
FocusCUR{1} = StackCUR{slice}{1};

% INVERSE CURVELET TRASFORM 
% the function "mefcv2" must be downloaded from: www.curvelet.org
FocusIMAGE = meicv2(FocusCUR,rows,columns,numscale,nag); % function from www.curvelet.org
clear FocusCUR Icounter StackCUR

% CREATION OF THE APPROSSIMATION OF THE DepthMap:
% for each x-y pixel position is set the index of the original image with the x-y value more similar to the FocusIMAGE's one. 
RFocus = repmat(FocusIMAGE,[1 1 channels]);
[DMmin, DepthMap] = min(abs(StackGRAY - RFocus),[],3);
clear RFocus DMmin

% CREATION OF THE FINAL 2D FOCUS IMAGE
if flag_3channels == 0
    % POST-PROCESSING FOR GRAY FOCUS IMAGE:
    % the values out of the original range are replaced
    StackGRAY = sort(StackGRAY,3);
    qmin2D = StackGRAY(:,:,1);
    qmax2D = StackGRAY(:,:,end);
    FocusIMAGE(FocusIMAGE>qmax2D) = qmax2D(FocusIMAGE>qmax2D);
    FocusIMAGE(FocusIMAGE<qmin2D) = qmin2D(FocusIMAGE<qmin2D);
elseif flag_3channels == 1
    % CREATION OF RGB FOCUS IMAGE
    FocusIMAGE = uint8(zeros(rows,columns,3));
    for i = 1:rows
        for j = 1:columns
            ind = DepthMap(i,j);
            FocusIMAGE(i,j,:) = StackRGB{ind}(i,j,:);
        end
    end
end