function varargout = FaceApp(varargin)
% FACEAPP MATLAB code for FaceApp.fig
%      FACEAPP, by itself, creates a new FACEAPP or raises the existing
%      singleton*.
%
%      H = FACEAPP returns the handle to a new FACEAPP or the handle to
%      the existing singleton*.
%
%      FACEAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACEAPP.M with the given input arguments.
%
%      FACEAPP('Property','Value',...) creates a new FACEAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FaceApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FaceApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FaceApp

% Last Modified by GUIDE v2.5 26-Mar-2019 16:56:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FaceApp_OpeningFcn, ...
    'gui_OutputFcn',  @FaceApp_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FaceApp is made visible.
function FaceApp_OpeningFcn(hObject, eventdata, handles, varargin)
global axis1
handles.output = hObject;
guidata(hObject, handles);
axes('Units','Normalized',...
    'Position',[0 0 1  1]);
[x,map]=imread('res/back.jpg','jpg');
image(x),colormap(map),axis off,hold on

[x,map]=imread('res/face.jpg','jpg');
axis1=axes('Units','Normalized',...
    'Position',[0.102 0.2 0.4  0.53]);

axes(axis1);
imshow(x),image(x),axis off,hold on

[x,map]=imread('res/b1.png','png');
x=imresize(x,[53 380 ]);
set(handles.pushbutton2,'CData',x);
set(handles.pushbutton5,'CData',x);
[x,map]=imread('res/b2.png','png');
x=imresize(x,[53 480 ]);
set(handles.pushbutton3,'CData',x);
[x,map]=imread('res/b3.png','png');
x=imresize(x,[53 480 ]);
set(handles.pushbutton4,'CData',x);


% --- Outputs from this function are returned to the command line.
function varargout = FaceApp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global net minp maxp imdsTest sizeimage

folder = fullfile(pwd, 'ORLimgs'); 
imds = imageDatastore(folder, 'IncludeSubfolders',false);
arr1=imds.Files;
arr2={};

for i= 1 :length(arr1)
    tmp=char(arr1(i));
    tmp=tmp(length(folder)+2:length(tmp));
    ii=strfind(tmp,'_');
    tmp=tmp(1:ii-1);
    arr2=cell([arr2;tmp]);
end
imds.Labels=categorical(arr2);


[imdsTrain,imdsTest] = splitEachLabel(imds,0.7,'randomized');

[status, msg, msgID] = rmdir('ORLTestimgs','s')
[status, msg, msgID] = mkdir('ORLTestimgs')
for i=1:size(imdsTest.Files,1)
    filename=imdsTest.Files{i,1};
      copyfile(filename, 'ORLTestimgs');
end

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
%get input data from train.dat
fileTrain = fopen('train.dat','r');
p=[];
sizeP = [(sizeimage*sizeimage)/2 Inf];
p = fscanf(fileTrain,'%f',sizeP);
%output train dataset
bin = de2bi(ouputdata1);
t_train=bin';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbrlayers=2; % number of all layers (hidden+output)
neurons=[50]; %number  of neurons in hidden layers
vectorLayr=[];
vectorFunctions={};
for i=1:nbrlayers-1
    vectorLayr=[vectorLayr neurons(i)];
    vectorFunctions{i}='tansig';
end

vectorLayr=[vectorLayr 6];
vectorFunctions{nbrlayers}='logsig';

%create neural network
[pn,minp,maxp] = premnmx(p);

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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global net minp maxp imdsTest sizeimage
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

fileTest = fopen('test.dat','r');
p2=[];
sizeP = [(sizeimage*sizeimage)/2 Inf];
p2 = fscanf(fileTest,'%f',sizeP);
%output test dataset
bin = de2bi(ouputdata2);
t_test=bin';
[pn2] = tramnmx(p2,minp,maxp);
%Prediction
PredictedLabels = sim(net,pn2);
error_rate = (1- mean(round(PredictedLabels) == t_test))*100;
Accuracy=100-mean(error_rate)
set(handles.text7,'string',[num2str(Accuracy) '%'])

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%when to press the New image button
global axis1 net sizeimage minp maxp
[filename, pathname] = uigetfile( ...
    {'*.jpg','JPEG (*.jpg)';'*.png','PNG (*.png)';...
    '*.bmp','Bitmap (*.bmp)';'*.*','All files (*.*)'},'open');
if(filename~=0)
    fName = fullfile(pathname,filename); %file name
    %read the image
    Im_original=imread(fName);
    axes(axis1);
    resizei=imresize(Im_original, [670 800]);
    imshow(resizei);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% READ IMAGES FROM Test DATASET %%%%%%%%%%%%%%%%%%%%%%%%%
    R = imresize(Im_original,[sizeimage sizeimage]);
    D1 = reshape(R',1,[]);
    [aC,dC]=dwt(D1,'haar');
    %output test dataset
    p2=aC';
    
    [pn2] = tramnmx(p2,minp,maxp);
    %Prediction
    PredictedLabels = sim(net,pn2);
%     error_rate = (1- mean(round(PredictedLabels) == t_test))*100;
%     Accuracy=100-mean(error_rate)
%     set(handles.text7,'string',[num2str(Accuracy) '%'])
    person=bi2de(round(PredictedLabels)');
    set(handles.edit1,'string',num2str(person))
    
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global net minp maxp  sizeimage
[filename, pathname] = uigetfile( ...
    {'*.mat','MAT (*.mat)'},'open');
if(filename~=0)
    fName = fullfile(pathname,filename); %file name
    config=load(fName);
    net=config.net;
    minp=config.minp;
    maxp=config.maxp;
end
sizeimage=20;
