classdef imbalanceRandomPatchExtractionDatastore < randomPatchExtractionDatastore
    properties
        biasThreshold
    end
    
    methods
        function this = imbalanceRandomPatchExtractionDatastore(ds1,ds2,patchSize,biasThreshold,varargin)
            this = this@randomPatchExtractionDatastore(ds1, ds2, patchSize, varargin{:});
            this.biasThreshold = biasThreshold;
        end
        
        function [data, info] = read(this)
           loop = true;
%            while loop
               [data, info] = read@randomPatchExtractionDatastore(this);
               
               
%            end
        end
    end
end

% function 