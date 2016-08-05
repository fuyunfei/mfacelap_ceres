 % %function matchmulti(image1list)  %  输入 list.txt 输出 out 文件  用于ceres 输入 
close all ; clear all; 
filepath='/home/sun/Cloud/Git/data/images/faceresized/';
image_num=5; 
formatSpec = '%d %d %.8f %.8f\n';
cellsize=3;
gridspacing=1;

addpath(fullfile(pwd,'mexDenseSIFT'));
addpath(fullfile(pwd,'mexDiscreteFlow'));
SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;


matches=cell(image_num-1,2);
siftcell= cell(image_num,1); 

for i=1:image_num
    im=imread([filepath,num2str(i),'.jpg']);
    im=imresize(imfilter(im,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
    im=im2double(im);
    sift = mexDenseSIFT(im,cellsize,gridspacing);
    siftcell(i,1)={sift};
end

[height,width,~]=size(sift);
masks=zeros(height,width); 
for i=2:image_num
    [vx,vy,energylist]=SIFTflowc2f(cell2mat(siftcell(1,1)),cell2mat(siftcell(i,1)),SIFTflowpara);
    matches(i-1,1)= {vx};
    matches(i-1,2)= {vy};
    [xx,yy]=meshgrid(1:width,1:height);
    [XX,YY]=meshgrid(1:width,1:height);
    XX=XX+vx;
    YY=YY+vy;
    mask=XX<1 | XX>width | YY<1 | YY>height;
    masks= masks==1|mask==1;  
end

point_num=sum(masks(:)==0);
observation_num=point_num*image_num;

save sflow_face_5.mat  
clear all ; close all ; 
 load sflow_face_5.mat  

fileID = fopen('sflow_com_5.txt','w');
%读取颜色
 im1=imread([filepath,'1.jpg']);
% 写出 camara_num  point_num obeservation_num 
fprintf(fileID,'%d %d %d \n',image_num,point_num,observation_num);
xjyj=zeros(point_num,2);
point_index =0 ; 
    for i= 1:width
        for j= 1:height
            if masks(i,j)~=1 
                 fprintf(fileID,formatSpec,0,point_index,j*2-width,i*2-height);
               for mch_id= 1: image_num-1
                      xj=(matches{mch_id,1}(i,j)+j)*2;
                      yj=(matches{mch_id,2}(i,j)+i)*2; 
                     fprintf(fileID,formatSpec,mch_id,point_index,xj-width,yj-height);
                     xjyj(point_index+1,:)=[xj yj];
               end
               point_index=point_index+1;
            end 
        end 
    end
    
 % 写出９个相机参数　
 for i=1:image_num
  fprintf(fileID,'%d \n%d \n%d \n%d \n%d \n%d \n%d \n%d \n%d \n',0,0,0,0,0,0,2700,0,0);
 end
 % 写出　wj  　
w=ones(point_num,1);
fprintf(fileID,'%d\n', w);
 % 写出　color 　
color=ones(point_num,3)*200;
for i=1:point_num
 xj= xjyj(i,1); 
 yj= xjyj(i,2); 
fprintf(fileID,'%d  %d %d \n', im1(yj,xj,:));
end
fclose(fileID); 






















