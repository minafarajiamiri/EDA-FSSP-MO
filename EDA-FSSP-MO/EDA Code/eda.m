clc
clear
close all
tic
%% parameter
npop=100; %number of population
maxit=100;
data=load('data.mat');
n=data.n; %number of jobs
m=data.m; %number of machine
%% initial population 
randsol.position=[];
randsol.value=[];
pop=repmat(randsol,npop,1);
for i=1:npop
    x=zeros(m+1,n);
    x(1,:)=randperm(n);
    for j=2:m+1
    x(j,:)=randi([1,3],1,n);
    end
    pop(i).position=x;
    [y1,y2]=senfit(pop(i).position,data);
    pop(i).value=[y1,y2];
end
%% pareto fronte
z.position=zeros(m+1,n);
z.value=zeros(npop,2);
p=repmat(z,npop,1);
for i=1:npop
    p(i).position=pop(i).position;
    p(i).value=pop(i).value;
end
for i=1:npop
    v(i)=[p(i).value(1)];
end
[vo vi]=sort(v);
p=p(vi);
a=1;
pp(a)=p(1); %pareto
for s=2:length(p)
	if p(s).value(2)>=pp(a).value(2)       
    else
	a=a+1;
    pp(a)=p(s);
	end
end
%% main loop
for iter=1:maxit
    %% probablistic model
    b=zeros(n,1); %number of time that job j is at position 1
    for c=1:n
        for l=1:length(pp)
            if pp(l).position(1,1)==c
                b(c)=b(c)+1;
            end
        end
    end
    bk=zeros(n,n); %number of times that job j is at position k, k~=1
    for k=2:n %positions
        for c=1:n %jobs
            for l=1:length(pp)
                if pp(l).position(1,k)==c
                    bk(c,k)=bk(c,k)+1;
                end
            end
        end
    end
    bk(:,1)=b; %number of times that job j is at position k
    o=zeros(n,n); %number of times that job j is at or before position k
    for k=2:n  
            o(:,k)=sum(bk(:,1:k),2);
    end
    bpr=zeros(n,n);
    for k=2:n
       for c=1:n
          bpr(c,k)=(bk(c,k)*o(c,k)); 
       end
    end
    bpr(:,1)=b;
    bpr=bpr+1;
    sumpr=sum(bpr);
    pr=zeros(n,n); %probability of job j at position k
    for kk=1:n
       for c=1:n
        pr(c,kk)=bpr(c,kk)/sumpr(kk);
       end
    end
    
    sp=repmat(z,size(pp,1),1);
    for l=1:length(pp)
        [w,wi]=sort(pp(l).position(1,:));
        sp(l).position=pp(l).position(:,wi);
    end
    ns=zeros(3,m); %number of time that speeds acure in machines
    for h=1:m %machines
        for c=1:n %jobs
            for l=1:size(pp,1)
                if sp(l).position(h+1,c)==1
                    ns(1,h)=ns(1,h)+1;
                elseif sp(l).position(h+1,c)==2
                    ns(2,h)=ns(2,h)+1;
                elseif sp(l).position(h+1,c)==3
                    ns(3,h)=ns(3,h)+1;
                end
            end
        end
    end
    ps=zeros(3,m); %probability of speeds in each machine
    ps=ns./(n*size(pp,1));
    %% population use probabilistic model
    for ip=1:npop
        g=zeros(m+1,n);
        e=1;
        while( e<=n)
            temp = sum(rand >= cumsum([0, pr(:,e)']));
            if length(find(g(1,:)==temp))==0
                g(1,e)=temp;
                e=e+1;
            end
        end
        for ee=1:n
            for f=2:m+1
                g(f,ee) = sum(rand >= cumsum([0, ps(:,f-1)']));
            end
        end
        pop(ip).position=g;
        [y1,y2]=senfit(pop(ip).position,data);
        pop(ip).value=[y1,y2];
    end
    %% pareto fronte
    p2=repmat(z,npop,1);
    for i2=1:npop
        p2(i2).position=pop(i2).position;
        p2(i2).value=pop(i2).value;
    end
    for i2=1:npop
        v2(i2)=[p2(i2).value(1)];
    end
    [v2o v2i]=sort(v2);
    p2=p2(v2i);
    aa=1;
    pp2=z;
    pp2(aa)=p2(1); %pareto
    for ss=2:length(p2)
            if p2(ss).value(2)>=pp2(aa).value(2)       
            else
                aa=aa+1;
                pp2(aa)=p2(ss);
            end
    end
    
    % combine    
    for cc=1:length(pp)
        cp(cc).position=pp(cc).position;
        cp(cc).value=pp(cc).value;
    end
    zohre(1:length(pp2))=pp2(1:length(pp2));
    zohre(length(pp2)+1:length(pp2)+cc)=cp(1:cc);
    for d=1:length(zohre)
        ppv(d)=[zohre(d).value(1)];
    end
    [vvo vvi]=sort(ppv);
    zohre=zohre(vvi);
    aaa=1;
    pp=z;
    pp(aaa)=zohre(1); %pareto
    for s2=2:length(zohre)
    	if zohre(s2).value(2)>=pp(aaa).value(2)       
        else
    	aaa=aaa+1;
    	pp(aaa)=zohre(s2);      
        end
    end
end
u=zeros(length(pp),2);
for q=1:length(pp)
	u(q,:)=pp(q).value; 
end
filename = 'simp217.xlsx';
xlswrite(filename,u);
disp([ ' Time = '  num2str(toc)])
