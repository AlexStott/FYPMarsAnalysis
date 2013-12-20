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
% if size(Input,3)>1
%     PositionNaN = isnan(Input(:,:,1));
%     Input = double(rgb2gray(uint8(Input)));
%     Input(PositionNaN) = NaN;
% end
% 
% Input = double(Input);

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