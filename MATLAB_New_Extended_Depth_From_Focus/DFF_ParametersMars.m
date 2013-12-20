function parameters = DFF_Parameters()
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 14 February 2012
% FILE NAME: DFF_Parameters.m
% 
% In this script are reported and explained all the parameters required by
% the function named: DFF_LocalAnalysis. The parameters must be set by
% changing the lines of this script.
%
% USAGE: 
% parameters = DFF_Parameters()
%
% See also DFF_LocalAnalysis 

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

parameters.ImageBaseName                    = 'mars';         % Description: name of the image, without the final cardinal number. E.g.: 'ImageMesenchymal_' for the image: ImageMesenchymal_001.tif
parameters.ImageFolder                      = 'C:\Users\Alex\Documents\GitHub\FYPMarsAnalysis\phoenix3\';     % Description: absolute path where the images that should be processed are stored (the last character must be the slash). E.g.: 'C:\TestFolder\'
parameters.ImageFormat                      = '.png';               % Description: format of the images. E.g.: '.jpg' or '.bmp' or '.tif' or etc.
parameters.ImageIndexes                     = [1, 2, 3,4,5,6,7,8,9,10,11,12,13,14,15,16];      % Description: cardinal numbers of the images that should be processed. E.g.: [001, 003, 004] to process the images named ImageMesenchymal_001.tif, ImageMesenchymal_003.tif and ImageMesenchymal_004.tif
parameters.MeanFilterSize                   = 15;                   % Description: size of the mean square filter applied to the masks of the first derivatives. E.g.: 15 means a square kernel of size 15x15. 
parameters.MajorityFilterSize               = 5;                    % Description: size of the majority filter applied to the DepthMap. E.g.: 5 means a square kernel of size 5x5. 

