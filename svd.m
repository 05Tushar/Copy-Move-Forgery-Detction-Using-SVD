clc          
clear all
close all

i1=imread('apples.jpeg');                               % Input your image
i2=rgb2gray(i1);                                      % rgb to gray conversion
figure,imshow(i2), title('Before Rclose esize');
i2=imresize(i2, [128 128]);                           % resize the image. more the size, more the computational complexity.
figure, imshow(i2); title('i2');
[row, col] = size(i2);
i2=im2double(i2);                                     % convert from uint8 to double.
  

V=zeros(8,1);                                        % Initialize null matrices for further use 
counti=0;countj=0;S=zeros(1,2);add2=zeros(size(S));   
Blocks2 = cell(121,121);                          % Divide the image into 8 x 8 blocks/ cells (overlapping manner)
for i=1:row-7
    counti = counti + 1;
   countj = 0;
    for j=1:col-7
         
        countj = countj + 1;
        Blocks2{i,j} = i2(i:i+7,j:j+7);
      
        %D = dctmtx(size(Blocks2{i,j},1));             % Subject each of 8x8 cell as follows
        %dct = D*Blocks2{i,j}*D';                      % Applying DCT to each of the 8x8 matrix
        K = svd(Blocks2{i,j});                         % divide quantization matrix element wise to the dct matrix
       
        %K1= round(K);       
        V= horzcat(V,K(:));                          % convert each 8x8 to a linear row, and create a new matrix with the formed rows
        S=[counti countj];
        add2= vertcat(add2,S);                        % The first pixel location of the block corresponding to the row in "V" is stored in S
    end
end
L= transpose(V);  
L(1,:)=[];      % The initial 0 0 null matrices declared are deleted. 1st row deleted
add2(1,:)=[];   % 1st row deleted
L=[L add2];     % concatenate both

L1=sortrows(L); % Lexicographically sort the rows (sorts based on elements only the first column, sorts rows without disrupting the order of elements in it)

S2= [L1(:,end-1) L1(:,end)];   


L1(:,end-1)=[];           
L1(:,end)=[];

count2=0;count3=0;
shiftvector=zeros(1,2); copy=zeros(1,6);     
for i=2:14641                                
    K2=0; J2=0;                             
    switch any(L1(i,:))
        case 0
            count2=count2+1;
        case 1     
        count3=count3+1;
        K2=S2(i,1); J2=S2(i,2);
        K3=S2(i-1,1); J3= S2(i-1,2);
        s1= K2-K3; s2=J2-J3;
        s=[s1 s2];
        shiftvector = vertcat(shiftvector,s);
        c= [K2 J2 K3 J3 s1 s2];
        copy= vertcat(copy,c);
    end
end
copy(1,:)=[];


shiftvector(1,:)=[];
shiftvector= abs(shiftvector);
matrix = unique(shiftvector, 'rows', 'stable');        % segregate all the unique, set of elements in shiftvector

[row2, col2]= size(shiftvector);
[row3, col3]= size(matrix);
cnt=0; repetition= zeros(row3,1);                      % Count the number of times each unique element occurs in shift vector
for i=1:row3
    for j=1:row2
    if (matrix(i,:)== shiftvector(j,:))
        cnt=cnt+1;
    end
    end
        repetition(i,1)=cnt;                           % The number of times repeated is stored in "Repetition" matrix
        cnt=0;
end

threshold = repetition > 20;                           % filtering highly repeated euclidean distance values.

V2 = zeros(128,128);
c6=0;c7=0;
for i=1:row3                                            % Finally checking the matrices with same distance.
    if(threshold(i,:)==1)
        rep1= matrix(i,1);
        rep2= matrix(i,2);
        c7=c7+1;
     for j=2:row2
         if(shiftvector(j,:)==[rep1 rep2])
             rep3= copy(j,1); rep4= copy(j,2);
             rep5=copy(j,3); rep6=copy(j,4);
             V2(rep3:rep3+7, rep4:rep4+7)= ones(8,8);
             V2(rep5:rep5+7, rep6:rep6+7)= ones(8,8);
             c6=c6+1;
         end
     end
    end
end
figure,imshow(V2); title('copy moved part');         % Mark the copy moved regions on a bnary image.
 
