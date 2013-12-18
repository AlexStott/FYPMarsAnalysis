classdef Image
    %class for an image
    properties
        height
        Im
    end
    methods
        function obj = Image(ImNum,im)
            obj.height = ImNum*300*0.25-300*0.25;
            obj.Im = im;
        end
    end
end
