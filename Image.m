classdef Image
    %class for an image
    properties
        height
        Im
    end
    methods
        function obj = Image(ImNum,im)
            obj.height = ImNum;
            obj.Im = im;
        end
    end
end
