%createUnet creates a deep learning network with the  U-net architecture.
%
%  lgraph = createUnet(inputTileSize) returns a U-net network which accepts
%  images of size inputTileSize.
%

% Copyright 2017 The MathWorks, Inc.

function lgraph = createUnet(inputTileSize, numOfClasses, pixelClassLayer)

% Network parameters taken from the publication
encoderDepth = 4;
initialEncoderNumChannels = 64;
inputNumchannels = inputTileSize(3);
convFilterSize = 2;
UpconvFilterSize = 2;

layers = imageInputLayer(inputTileSize,...
    'Name','ImageInputLayer');
layerIndex = 1;

% Create encoder layers
for sections = 1:encoderDepth
    
    encoderNumChannels = initialEncoderNumChannels * 2^(sections-1);
        
    if sections == 1
        conv1 = convolution2dLayer(convFilterSize,encoderNumChannels,...
            'Padding','same',...
            'NumChannels',inputNumchannels,...
            'BiasL2Factor',0,...
            'Name',['Encoder-Section-' num2str(sections) '-Conv-1']);
        
        conv1.Weights = sqrt(2/((convFilterSize^2)*inputNumchannels*encoderNumChannels)) ...
            * randn(convFilterSize,convFilterSize,inputNumchannels,encoderNumChannels);
    else
        conv1 = convolution2dLayer(convFilterSize,encoderNumChannels,...
            'Padding','same',...
            'BiasL2Factor',0,...
            'Name',['Encoder-Section-' num2str(sections) '-Conv-1']);
        
        conv1.Weights = sqrt(2/((convFilterSize^2)*encoderNumChannels/2*encoderNumChannels)) ...
            * randn(convFilterSize,convFilterSize,encoderNumChannels/2,encoderNumChannels);
    end
    
    conv1.Bias = randn(1,1,encoderNumChannels)*0.00001 + 1;
    
    relu1 = reluLayer('Name',['Encoder-Section-' num2str(sections) '-ReLU-1']);
    
    conv2 = convolution2dLayer(convFilterSize,encoderNumChannels,...
        'Padding','same',...
        'BiasL2Factor',0,...
        'Name',['Encoder-Section-' num2str(sections) '-Conv-2']);
    
    conv2.Weights = sqrt(2/((convFilterSize^2)*encoderNumChannels)) ...
        * randn(convFilterSize,convFilterSize,encoderNumChannels,encoderNumChannels);
    conv2.Bias = randn(1,1,encoderNumChannels)*0.00001 + 1;
    
    relu2 = reluLayer('Name',['Encoder-Section-' num2str(sections) '-ReLU-2']);
       
    layers = [layers; conv1;
%         groupNormalizationLayer(1,"Name",['Encoder-Section-' num2str(sections) '-GroupNormalization-1']);
        relu1; conv2; 
%         groupNormalizationLayer(1,"Name",['Encoder-Section-' num2str(sections) '-GroupNormalization-2']);
        relu2];     %#ok<*AGROW>
    layerIndex = layerIndex + 4;
    
    if sections == encoderDepth
        dropOutLayer = dropoutLayer(0.5,'Name',['Encoder-Section-' num2str(sections) '-DropOut']);
        layers = [layers; dropOutLayer];
        layerIndex = layerIndex +1;
    end
    
    maxPoolLayer = maxPooling2dLayer(2, 'Stride', 2, 'Name',['Encoder-Section-' num2str(sections) '-MaxPool']);
    
    layers = [layers; maxPoolLayer];
    layerIndex = layerIndex +1;
    
end
%Create mid layers
conv1 = convolution2dLayer(convFilterSize,2*encoderNumChannels,...
    'Padding','same',...
    'BiasL2Factor',0,...
    'Name','Mid-Conv-1');

conv1.Weights = sqrt(2/((convFilterSize^2)*2*encoderNumChannels)) ...
    * randn(convFilterSize,convFilterSize,encoderNumChannels,2*encoderNumChannels);
conv1.Bias = randn(1,1,2*encoderNumChannels)*0.00001 + 1;

relu1 = reluLayer('Name','Mid-ReLU-1');

conv2 = convolution2dLayer(convFilterSize,2*encoderNumChannels,...
    'Padding','same',...
    'BiasL2Factor',0,...
    'Name','Mid-Conv-2');

conv2.Weights = sqrt(2/((convFilterSize^2)*2*encoderNumChannels)) ...
    * randn(convFilterSize,convFilterSize,2*encoderNumChannels,2*encoderNumChannels);
conv2.Bias = zeros(1,1,2*encoderNumChannels)*0.00001 + 1;

relu2 = reluLayer('Name','Mid-ReLU-2');
layers = [layers; conv1;
%     groupNormalizationLayer(1,"Name",'Mid-GroupNormalization-1'); 
    relu1; conv2; relu2];
layerIndex = layerIndex + 4;

% Add drop out Layer
dropOutLayer = dropoutLayer(0.5,'Name','Mid-DropOut');

layers = [layers; dropOutLayer];
layerIndex = layerIndex + 1;

initialDecoderNumChannels = encoderNumChannels;

%Create decoder layers
for sections = 1:encoderDepth
    
    decoderNumChannels = initialDecoderNumChannels / 2^(sections-1);
    
    upConv = transposedConv2dLayer(UpconvFilterSize, decoderNumChannels,...
        'Stride',2,...
        'BiasL2Factor',0,...
        'Name',['Decoder-Section-' num2str(sections) '-UpConv']);

    upConv.Weights = sqrt(2/((UpconvFilterSize^2)*2*decoderNumChannels)) ...
        * randn(UpconvFilterSize,UpconvFilterSize,decoderNumChannels,2*decoderNumChannels);
    upConv.Bias = randn(1,1,decoderNumChannels)*0.00001 + 1;    
    
    upReLU = reluLayer('Name',['Decoder-Section-' num2str(sections) '-UpReLU']);
    
    depthConcatLayer = depthConcatenationLayer(2,'Name',...
        ['Decoder-Section-' num2str(sections) '-DepthConcatenation']);
    
    conv1 = convolution2dLayer(convFilterSize,decoderNumChannels,...
        'Padding','same',...
        'BiasL2Factor',0,...
        'Name',['Decoder-Section-' num2str(sections) '-Conv-1']);
    
    conv1.Weights = sqrt(2/((convFilterSize^2)*2*decoderNumChannels)) ...
        * randn(convFilterSize,convFilterSize,2*decoderNumChannels,decoderNumChannels);
    conv1.Bias = randn(1,1,decoderNumChannels)*0.00001 + 1;
    
    relu1 = reluLayer('Name',['Decoder-Section-' num2str(sections) '-ReLU-1']);
    
    conv2 = convolution2dLayer(convFilterSize,decoderNumChannels,...
        'Padding','same',...
        'BiasL2Factor',0,...
        'Name',['Decoder-Section-' num2str(sections) '-Conv-2']);
    
    conv2.Weights = sqrt(2/((convFilterSize^2)*decoderNumChannels)) ...
        * randn(convFilterSize,convFilterSize,decoderNumChannels,decoderNumChannels);
    conv2.Bias = randn(1,1,decoderNumChannels)*0.00001 + 1;
    
    relu2 = reluLayer('Name',['Decoder-Section-' num2str(sections) '-ReLU-2']);
    
    layers = [layers; upConv; upReLU; depthConcatLayer; conv1;
%         groupNormalizationLayer(1,"Name",['Decoder-Section-' num2str(sections) '-GroupNormalization-1']);
        relu1; conv2;
%         groupNormalizationLayer(1,"Name",['Decoder-Section-' num2str(sections) '-GroupNormalization-2']);
        relu2];
    
    layerIndex = layerIndex + 7;
end

finalConv = convolution2dLayer(1,numOfClasses,...
    'BiasL2Factor',0,...
    'Name','Final-ConvolutionLayer');

finalConv.Weights = randn(1,1,decoderNumChannels,numOfClasses);
finalConv.Bias = randn(1,1,numOfClasses)*0.00001 + 1;

smLayer = softmaxLayer('Name','Softmax-Layer');

if ~exist('pixelClassLayer', 'var')
    pixelClassLayer = pixelClassificationLayer('Name','Segmentation-Layer'); %, 'ClassNames', classesTbl.Name, 'ClassWeights', classWeights);
end
layers = [layers; finalConv; smLayer; pixelClassLayer];

% Create the layer graph and create connections in the graph
lgraph = layerGraph(layers);

% Connect concatenation layers
for sections = 1:encoderDepth
    if(sections < encoderDepth)
        lgraph = connectLayers(lgraph, strcat('Encoder-Section-', string(sections), '-ReLU-2'),...
            strcat('Decoder-Section-',string(encoderDepth - sections + 1),'-DepthConcatenation/in2'));
    else
        lgraph = connectLayers(lgraph, strcat('Encoder-Section-',string(sections),'-DropOut'),...
            strcat('Decoder-Section-',string(encoderDepth - sections + 1),'-DepthConcatenation/in2'));
    end
end
end