clear all
close all
clc
%%%%%%%%%%% get all images from database folder and generate the train
%%%%%%%%%%% dataset and the test dataset
folder='E:\Freelance\ProjectsMatlab\Project 22\code matlab\ORLimgs';
imds = imageDatastore(folder, 'IncludeSubfolders',false);
arr1=imds.Files;
arr2={};


imds.Labels=categorical(arr2);
for i= 1 :length(arr1)
    tmp=char(arr1(i));
    tmp=tmp(length(folder)+2:length(tmp));
    ii=strfind(tmp,'_');
    tmp=tmp(1:ii-1);
    arr2=cell([arr2;tmp]);
end

[imdsTrain,imdsTest] = splitEachLabel(imds,0.7,'randomized');
sizeimage=20;
%%%%%%%%%% READ IMAGES FROM TRAIN DATASET %%%%%%%%%%%%%%%%%%%%%%%%%
ouputdata1=[];
fileTrain = fopen('train.dat','w');
fileTrain = fopen('train.dat','a');
for k=1:length(imdsTrain.Files)
    FileNames=char(imdsTrain.Files(k));
    A= imread (FileNames);
    R = imresize(A,[sizeimage sizeimage]);
    D1 = reshape(R',1,[]);
    [aC,dC]=dwt(D1,'haar');
    
    fprintf(fileTrain, '%.6f ', aC)
    fprintf(fileTrain, '%s\n', '')
    t=char(imdsTrain.Labels(k));
    ouputdata1=[ouputdata1 str2num(t)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% READ IMAGES FROM Test DATASET %%%%%%%%%%%%%%%%%%%%%%%%%
ouputdata2=[];
fileTest = fopen('test.dat','w');
fileTest = fopen('test.dat','a');
for k=1:length(imdsTest.Files)
    FileNames=char(imdsTest.Files(k));
    A= imread (FileNames);
    R = imresize(A,[sizeimage sizeimage]);
    D1 = reshape(R',1,[]);
    [aC,dC]=dwt(D1,'haar');
    
    fprintf(fileTest, '%.6f ', aC)
    fprintf(fileTest, '%s\n', '')
    t=char(imdsTest.Labels(k));
    ouputdata2=[ouputdata2 str2num(t)];
end
%get input data from train.dat
fileTrain = fopen('train.dat','r');
p=[];
sizeP = [(sizeimage*sizeimage)/2 Inf];
p = fscanf(fileTrain,'%f',sizeP);
%get test data from test.dat
fileTest = fopen('test.dat','r');
p2=[];
sizeP = [(sizeimage*sizeimage)/2 Inf];
p2 = fscanf(fileTest,'%f',sizeP);
%output train dataset
bin = de2bi(ouputdata1);
t_train=bin';
%output test dataset
bin = de2bi(ouputdata2);
t_test=bin';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = input(['enter the number of layers (hidden+ouput) = '])
nbrlayers=x;
vectorLayr=[];
vectorFunctions={};
for i=1:nbrlayers-1
    x = input(['enter the number of neurons in the hidden layer ' num2str(i) ' = '])
    vectorLayr=[vectorLayr x];
    vectorFunctions{i}='tansig';
end
fprintf(['the number of neurons in the output layer is ' num2str(6) ' Press enter to continue.\n']);
pause;
vectorLayr=[vectorLayr 6];
vectorFunctions{nbrlayers}='logsig';

%create neural network
[pn,minp,maxp] = premnmx(p);
[pn2] = tramnmx(p2,minp,maxp);

net=newff(minmax(pn),vectorLayr,vectorFunctions,'traingdm');

%biases initialization
for i=1:nbrlayers
    net.b{i}=ones(vectorLayr(i),1)
end
biases = net.b; % Cell containing the biases
net.trainParam.show = 50;
net.trainParam.lr = 0.05;
net.trainParam.epochs = 20000;
net.trainParam.goal = 1e-20;
%train the NN
[net,tr]=train(net,pn,t_train);
%simulate NN
a = sim(net,pn);
%Prediction
PredictedLabels = sim(net,pn2);
error_rate = (1- mean(round(PredictedLabels) == t_test))*100; 
Accuracy=100-mean(error_rate)