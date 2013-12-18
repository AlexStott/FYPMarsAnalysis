function [UQIN_global] = Metric_UQIN(Stack, Fused, version, KernelSize)
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 14 February 2012
% FILE NAME: Metric_UQIN.m
% 
% Extension of the standard metric UQI, published in:
% a) Zhou Wang and Alan C. Bovik, “A Universal Image Quality Index”, IEEE 
% Signal Processing Letters, Vol. 9, No 3, pp. 81-84, March 2002 
% used to evaluate the quality of an image reconstructed exploiting a 
% stack of N slices. 
% The extension of the UQI (named UQIN) is inspired by the articles: 
% b) Gemma Piella and Henk Heijmans, "A new quality metric for image 
% fusion", Proc. of International Conference on Image Processing 2003 
% (ICIP 2003). 
% c) Mario A. Bueno and Josué Álvarez-Borrego and Leonardo Acho and María 
% Cristína Chávez-Sánchez, "Polychromatic image fusion algorithm and 
% fusion metric for automatized microscopes", Optical Engineering 449, 
% 093201 September 2005.
%
% USAGE: 
% UQIN_global = Metric_UQIN(Stack, Fused, 4);
%
% INPUT PARAMETERS:
% 	Stack           Matrix N x M x i where "[N, M] = size(Fused)" and i 
%                   is the number of images stored into the stack. 
%   Fused           Image reconstructed exploiting the stack of data.
%   version         Different formula's implementation of the UQIN. The
%                   formulas are reported into the article c.
%                   - version = 1 means the formula 17 for obtaining Q
%                   - version = 2 means the formula 19 for obtaining Qw
%                   - version = 3 means the formula 20 for obtaining Qe
%                   with alpha parameter equal to 1
%                   - version = 4 means the average standard UQI (Z. Wang 
%                   and A.C. Bovik) evaluated between the image Fused and 
%                   all the single slices stored into the Stack.
%   KernelSize      Dimension of the ROIs used to estimate the local 
%                   variance in the images.
%
% OUTPUT:
%   UQIN_global     Global value of the UQIN (mean of the local values 
%                   of the UQIN).
%
% See also Metric_SNR, Metric_MSE, Metric_UQI

% Depth From Focus Toolbox
% Copyright © 2011 Filippo Piccinini, Alessandro Bevilacqua, 
% Advanced Research Center on Electronic Systems (ARCES), University of
% Bologna, Italy. All rights reserved.
%
% This program is free software; you can redistribute it and/or modify it 
% under the terms of the GNU General Public License version 2 (or higher) 
% as published by the Free Software Foundation. This program is 
% distributed WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
% General Public License for more details.

if nargin < 4
    KernelSize = 9;
end

% PARAMETERS SET UP
if mod(KernelSize,2)==0
    error('KernelSize must be odd')
end
pad = (KernelSize-1)/2;
[rows columns stop_index] = size(Stack);

if version == 3
    Fused = FirstDerivativeXY(Fused);
    for nf = 1: stop_index
        Stack(:,:,nf) = FirstDerivativeXY(Stack(:,:,nf));
    end 
end

% PADDING OF THE IMAGES
Fused_pad = padarray(Fused, [pad pad], 'replicate', 'both');

Stack_pad = NaN(size(Fused_pad,1),size(Fused_pad,2),stop_index);
for nf = 1:stop_index
    Stack_pad(:,:,nf) = padarray(Stack(:,:,nf), [pad pad], 'replicate', 'both');
end

% UQIN EQUATION SELECTION
if version == 4
    % Global metric evaluation
    UQI = zeros(1, stop_index); %inizialized
    for nf = 1:stop_index
        UQI(nf) = Metric_UQI(Stack(:,:,nf),Fused);
    end
    NormFact = stop_index;
    UQIN_global = sum(UQI)/NormFact;
else
    % Local metric evaluation (SLOW IMPLEMENTATION)
    UQIN_local = zeros(rows, columns); %inizialized
    C = zeros(rows, columns); %inizialized
    for i = 1+pad:pad+rows
        for j = 1+pad:pad+columns  
            salienza = zeros(1, stop_index); %inizialized
            UQI = zeros(1, stop_index); %inizialized
            ROI_fused = Fused_pad(i-pad:i+pad,j-pad:j+pad);
            for nf = 1:stop_index
                ROI = Stack_pad(i-pad:i+pad,j-pad:j+pad,nf);
                salienza(nf) = var(ROI(:));
                UQI(nf) = Metric_UQI(ROI, ROI_fused);
                clear ROI
            end
            NormFact = sum(salienza); % variances normalization factor
            C(i-pad,j-pad) = max(salienza);
            
            UQIN_local(i-pad,j-pad) = sum(salienza.*UQI)/NormFact;
            clear ROI_fused variances UQI NormFact
        end
    end

    % Final metric evaluation
    if version == 1
        if sum(isnan(UQIN_local(:))) >= 1
            NotNumber = isnan(UQIN_local(:));
            posizione = NotNumber == 0;
            UQIN_global = mean(UQIN_local(posizione));
        else
            UQIN_global = mean(UQIN_local(:));
        end
    elseif version == 2 || version == 3
        if sum(isnan(UQIN_local(:))) >= 1
            NotNumber = isnan(UQIN_local(:));
            posizione = NotNumber == 0;
            C = C(posizione);
            c_denominator = sum(C);
            UQIN_global = sum(C.*UQIN_local(posizione))/c_denominator;
        else
            c_denominator = sum(C(:));
            UQIN_global = sum(sum((C.*UQIN_local)))/c_denominator;
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
