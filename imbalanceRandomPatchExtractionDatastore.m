classdef imbalanceRandomPatchExtractionDatastore < randomPatchExtractionDatastore
    properties
        biasThreshold
        
        timeToLoop
    end
    
    methods
        function this = imbalanceRandomPatchExtractionDatastore(ds1,ds2,patchSize,biasThreshold,timeToLoop,varargin)
            this = this@randomPatchExtractionDatastore(ds1, ds2, patchSize, varargin{:});
            this.biasThreshold = biasThreshold;
            if ~exist('timeToLoop', 'var') || timeToLoop < 1
                this.timeToLoop = 100;
            else
                this.timeToLoop = timeToLoop;
            end
        end
        
        function [patchInput, patchResponse, patchLocation] = cropRandomPatchesFromImagePairs(this, img1, img2)
            for i = 1:this.timeToLoop
                [patchInput, patchResponse, patchLocation] = cropRandomPatchesFromImagePairs@randomPatchExtractionDatastore(this, img1, img2);
                if numel(this.PatchSize) == 2
                    labelProbabilities = histcounts(patchResponse(:), 'Normalization', 'probability');
                    m = min(labelProbabilities);
                    if numel(labelProbabilities) > 1 && (labelProbabilities(1, 1) == m || m >= this.biasThreshold)
                        return;
                    end
                else 
                    error('please implement threshold logic for 3 dimensions images');
                end
            end
        end
    end
end