close all
clear
clc 

n=3; %number of jobs
m=2; %number of machine
file='Book1.xlsx';
pt1=xlsread(file,1);
pt2=xlsread(file,2);
pt3=xlsread(file,3);
for s=1:3
    if s==1 %processing with high speed
        v(s)=1.2;
    elseif s==2 %processing with normal speed
        v(s)=1;
    else %processing with low speed
        v(s)=0.8;
    end
end
for s=1:3
    if s==1 %processing with high speed
        landa(s)=1.5;
    elseif s==2 %processing with normal speed
        landa(s)=1;
    else %processing with low speed
        landa(s)=0.6;
    end
end
fi=0.5; %converting factor
pi=60; %power of machine

save data