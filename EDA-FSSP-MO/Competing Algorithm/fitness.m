function [obj1,obj2]=fitness(x,data,pt)
m=data.m;
n=data.n;
s=data.s;
v=data.v;
landa=data.landa;
fi=data.fi;
pi=data.pi;
p=pt;
%sim=100;
%obj1=zeros(sim,1);
%obj2=zeros(sim,1);
%for a=1:sim
%p=randi([10,15],m,n); %normal processing time
pr=0; %precedence restriction
c=zeros(m,n); %completion time of jobs on machines
vm=zeros(m,n); %speed of each machine
seq=x(1,:);
for i=2:m+1
    vm(i,:)=x(i,:);
end
for k=1:length(seq)
    j=seq(k);
    for mm=1:m
        s=vm(mm+1,k);
        if mm==1
            if pr==0
                c(1,j)=p(1,j)/v(s);
            else
                c(1,j)=c(1,pr)+p(1,j)/v(s);
            end
        else
            if pr==0
                c(mm,j)=c(mm-1,j)+p(mm,j)/v(s);
            else
                c(mm,j)=max(c(mm-1,j),c(mm,pr))+p(mm,j)/v(s);
            end
        end
    end
    pr=j;
end
f1=c(m,j); %cmax
ti=zeros(m,n);
for k=1:length(seq)
    j=seq(k);
    for mm=1:m
        s=vm(mm+1,k);
        ti(mm,j)=p(mm,j)/v(s); %processing time
    end
end
b=sum(ti,2);
teta=zeros(m,1);
for i=1:m
    teta(i,1)=f1-b(i); %idle time of machines
end
t=zeros(m,n);
for k=1:length(seq)
    j=seq(k);
    for mm=1:m
        s=vm(mm+1,k);
        t(mm,j)=(landa(s)*p(mm,j))/v(s); %processing time

    end
end
tec=((pi*sum(sum(t),2))/60)+((pi*fi*sum(teta))/60);
f2=tec; %energy consumption
obj1=f1;
obj2=f2;
%end
%fobj1=mean([obj1]);
%fobj2=mean([obj2]);
