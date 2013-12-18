function [FocusIMAGE, DepthMap] = DFF_LocalAnalysis(parameters)
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 14 February 2012
% FILE NAME: DFF_LocalAnalysis.m
% 
% To obtain the final in-focus 2-D image, starting from a stack of slices
% where only small areas of each slices are in focus. The algorithm is
% based on a local analysis of the first x-y derivatives of each input
% image, and a following maximum analysis of the z-vector of the stack. The
% final composite image is built copying for each x-y position the pixel
% value from the image point out be the "depth map" built during the
% maximum analysis. The algorithm works with both GRAY or RGB images and
% the output image is of the same type of the input ones.
%
% USAGE: 
% [FocusIMAGE, DepthMap] = DFF_LocalAnalysis;
%
% INPUT PARAMETERS:
% 	parameters              All the input parameters are set and explained 
%                           in the file named: DFF_Parameters.m
%
% OUTPUT:
%   FocusIMAGE              Final composite image where all the regions
%                           should be in-focus.
%   DepthMap                2D mask reporting for each x-y pixel position
%                           the index of the original image from which is 
%                           copyed the value reported in the output 
%                           FocusIMAGE. 
%
% See also DFF_Parameters, FirstDerivativeXY

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
    parameters = DFF_Parameters();
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

% IMAGEs STACK CREATION
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
        StackGRAY(:,:,nf) = double(OrigImg);
    end
    clear OrigImg name strnum
end

% DERIVATIVE MASKS CREATION
for nf=1:stop_index
    Derivatives(:,:,nf) = FirstDerivativeXY(StackGRAY(:,:,nf));
    
    % FILTERING APPLIED TO THE DERIVATIVE
    h = fspecial('average', parameters.MeanFilterSize);
    Derivatives(:,:,nf) = imfilter(Derivatives(:,:,nf), h, 'replicate', 'same', 'conv');
    
end

% CREATION OF THE MAP OF MAXIMUM OF DERIVATIVES ALONG THE Z-STACK
[rows, columns, channels] = size(Derivatives);
DepthMap = zeros(rows, columns);
for i = 1:rows
    for j = 1:columns
        [NI1, D_index] = max(Derivatives(i,j,:));
        DepthMap(i,j) = D_index;
        clear NI1 D_index
    end
end

% MAJORITY FILTER
if ~isempty(parameters.MajorityFilterSize)
    MajoritySize = parameters.MajorityFilterSize;
    if mod(MajoritySize,2)~=0
        MajoritySize = MajoritySize-1;
    end
    pad = MajoritySize/2;
    DepthMap_pad = padarray(DepthMap,[pad pad],'replicate','both');
    for i = pad+1:rows+pad
        for j = pad+1:columns+pad
            CounterV = zeros(1,channels);
            ROI = DepthMap_pad(i-pad:i+pad,j-pad:j+pad);
            ROI = ROI(:);
            for k =1:length(ROI)
                CounterV(ROI(k)) = CounterV(ROI(k))+1;
            end
            if max(CounterV) >= ceil(length(ROI)/2)
                M_index = find(CounterV==max(CounterV));
                DepthMap(i-pad,j-pad) = M_index;
            end
            clear CounterV ROI M_index
        end
    end
end

% CREATION OF THE FINAL 2D FOCUS IMAGE
if flag_3channels == 0
    % CREATION OF THE GRAY FUSED IMAGE
    FocusIMAGE = zeros(size(DepthMap));
    for i = 1:rows
        for j = 1:columns
            FocusIMAGE(i,j) = StackGRAY(i,j,DepthMap(i,j));
        end
    end
elseif flag_3channels == 1
    % CREATION OF THE RGB FUSED IMAGE
    FocusIMAGE = uint8(zeros(rows, columns, 3));
    for i = 1:rows
        for j = 1:columns
            ind = DepthMap(i,j);
            FocusIMAGE(i,j,:) = StackRGB{ind}(i,j,:);
        end
    end
end



function DerivativeXY = FirstDerivativeXY(Input)
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 18 January 2012
% FILE NAME: DerivativeXY.m
% 
% To perform the x-y first derivative on the input image.
%
% USAGE: 
% derivativeXY = FirstDerivativeXY(InputImage)
%
% INPUT PARAMETERS:
% 	InputImage        Input image that should be derived 
%
% OUTPUT:
%   derivativeXY      2D derivatives mask

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

% EVENTUAL GRAY-LEVELS CONVERSION
if size(Input,3)>1
    PositionNaN = isnan(Input(:,:,1));
    Input = double(rgb2gray(uint8(Input)));
    Input(PositionNaN) = NaN;
end

Input = double(Input);

% DERIVATIVE X
kernel = [-1 0 +1];
kernel_mirror = [kernel(3), kernel(2), kernel(1)];
DerivativeX = imfilter(Input, kernel_mirror, 'replicate', 'same', 'conv');
clear kernel kernel_mirror

% DERIVATIVE Y
kernel = [-1 0 +1]';
kernel_mirror = [kernel(3), kernel(2), kernel(1)]';
DerivativeY = imfilter(Input, kernel_mirror, 'replicate', 'same', 'conv');
clear kernel kernel_mirror

% DERIVATIVE XY
%DerivativeXY = sqrt(DerivativeX^2+DerivativeY^2);
DerivativeXY = abs(DerivativeX) + abs(DerivativeY); % formula approximated