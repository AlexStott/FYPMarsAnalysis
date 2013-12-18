function parameters = DFF_CUR_Parameters()
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 14 February 2012
% FILE NAME: DFF_CUR_Parameters.m
% 
% In this script are reported and explained all the parameters required by
% the function named: DFF_LocalAnalysis. The parameters must be set by
% changing the lines of this script.
%
% USAGE: 
% parameters = DFF_CUR_Parameters()
%
% See also DFF_CUR 

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

parameters.ImageBaseName                    = 'Dome1x40_0';         % Description: name of the image, without the final cardinal number. E.g.: 'ImageMesenchymal_' for the image: ImageMesenchymal_001.tif
parameters.ImageFolder                      = 'C:\TestFolder\';     % Description: absolute path where the images that should be processed are stored (the last character must be the slash). E.g.: 'C:\TestFolder\'
parameters.ImageFormat                      = '.tif';               % Description: format of the images. E.g.: '.jpg' or '.bmp' or '.tif' or etc.
parameters.ImageIndexes                     = [001, 003, 004];      % Description: cardinal numbers of the images that should be processed. E.g.: [001, 003, 004] to process the images named ImageMesenchymal_001.tif, ImageMesenchymal_003.tif and ImageMesenchymal_004.tif

