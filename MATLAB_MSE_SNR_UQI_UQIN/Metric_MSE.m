function [MSE] = Metric_MSE(Frame, Reference)
% AUTHOR: Filippo Piccinini (E-mail: f.piccinini@unibo.it,
% fpiccinini@arces.unibo.it, filippo.piccinini85@gmail.com)
%
% DATE: 18 January 2012
% FILE NAME: Metric_MSE.m
% 
% Implementation of the Mean Squared Error (MSE) for images evaluation.
% The NaN values are excluded.
%
% USAGE: 
% MSE = Metric_MSE(Frame, Reference);
%
% INPUT PARAMETERS:
% 	Frame           input image of size N x M  
%   Reference       input image of size N x M 
%
% OUTPUT:
%   MSE             evaluation of the MSE metric
%
% See also Metric_SNR, Metric_UQI, Metric_UQIN 

% Depth From Focus Toolbox
% Copyright � 2012 Filippo Piccinini, Alessandro Bevilacqua, 
% Advanced Research Center on Electronic Systems (ARCES), 
% University of Bologna, Italy. All rights reserved.
%
% This program is free software; you can redistribute it and/or modify it 
% under the terms of the GNU General Public License version 2 (or higher) 
% as published by the Free Software Foundation. This program is 
% distributed WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
% General Public License for more details.

if size(Frame,1)~=size(Reference,1) || size(Frame,2)~=size(Reference,2)
    error('The two input images must be of the same size')
end

Frame = double(Frame(:));
Reference = double(Reference(:));

% TO EXCLUDE THE NaN VALUES
F_noNaN = find(~isnan(Frame));
R_noNaN = find(~isnan(Reference));
Ind = intersect(F_noNaN, R_noNaN);
Cardinality = length(Ind);

SumSquareDifference = sum((Frame(Ind) - Reference(Ind)).^2);
    
MSE = SumSquareDifference/Cardinality;
