clc
clear
close all
tic
%% parameter
npop=100; %number of population
maxit=50;
mutep=0.2;
nmut=round(npop*mutep);
crosp=1-mutep;
ncrosp=2*round((npop*crosp)/2); 
pararchsize=10;
minsup=2;
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
z.value=zeros(1,2);
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
%u=zeros(length(pp),2);
%for q=1:length(pp)
%	u(q,:)=pp(q).value; 
%end
%filename = 'pareto1.xlsx';
%xlswrite(filename,u);
for iter=1:maxit
    if length(pp)<= pararchsize
        archive=pp;
    else
        d=[];
        dv=[];
        for e1=1:length(pp)
            for e2=1:length(pp)
                if e2==e1
                    d(e1,e2)=100;
                else
                    d(e1,e2)=((pp(e1).value(1)-pp(e2).value(1))^2+(pp(e1).value(2)-pp(e2).value(2))^2)^(1/2);
                end
            end
            dv(e1)=min(d(e1,:),[],2);
        end
        [dvv dvi]=sort(dv);
        pp=pp(dvi);
        archive(1:pararchsize)=pp(1:pararchsize);
    end
%% data minnimg
lcount=[];
for dm=1:length(archive)
    level(dm).position=archive(dm).position;
end
for litem=1:n-1
    
    for dm=1:length(archive)
        pos2=litem;
        pos1=1;
        row=1;
        while pos2<=n
            lc(row,dm).perm=level(dm).position(1,pos1:pos2);
            lc(row,dm).num=1;
            row=row+1;
            pos2=pos2+1;
            pos1=pos1+1;
        end
    end
    %lc2=lc;
    
	in=0;
    ll=[];
    for i1=1:row-1
        for i2=1:dm
            pl=lc(i1,i2).perm;
            npl=0;
            for ii1=1:row-1
                for ii2=1:dm
                    if lc(ii1,ii2).perm==pl
                        npl=npl+1;
                    end
                end
            end
            if npl>=minsup
                in=in+1;
                ll(in).perm=pl;
                ll(in).num=npl;
            end
            for ii1=1:row-1
                for ii2=1:dm
                    if lc(ii1,ii2).perm==pl
                        lc(ii1,ii2).perm=0;
                    end
                end
            end
        end
    end
   	in2=1;
	null=isempty(ll);
    if null==0
        for oo=1:length(ll)
            if ll(oo).perm~=0
                ll2(in2)=ll(oo);
                in2=in2+1;
            end
        end
    else
        ll2=[];
    end
    
	lcount(litem).com=ll2;
    clear ll2
end
%% artificial choromozom
artificial=[];
if length(pp)==1
        [artificial]=pp(1).position;
        loop=0;
    else
        loop=1;
    end
nn=n-1;
iter
while loop==1
    if isempty(lcount(nn).com)==0
        lmin=[];
        for lm=1:length(lcount(nn).com)
            lmin(lm)=lcount(nn).com(lm).num;
        end
        val=[];
        index=[];
        [val index]=sort(lmin,'descend');
        lmina=lcount(nn).com(index);
        [permu]=lmina(1).perm;
        nn2=n+1-length(permu);
        posf=permu(1);
        poss=permu(end);
        while nn2>nn
            nn2=nn2-1;
        end
            if nn2<=1
                [artificial]=[permu];
            else
                cm=1;
                permu2=[];
                if (isempty(lcount(nn2)))==0 
                    while cm<=length(lcount(nn2).com)
                        if lcount(nn2).com(cm).perm(1)==poss
                            permu2=lcount(nn2).com(cm).perm;
                            cm=100*n;
                        else
                            cm=cm+1;
                        end
                    end
                    cn=1;
                    permu1=[];
                    if (isempty(permu2))==0
                    else
                        while cn<=length(lcount(nn2).com)
                            if lcount(nn2).com(cn).perm(end)==posf
                            permu1=lcount(nn2).com(cn).perm;
                            cn=100*n;
                            else
                            cn=cn+1;
                            end
                        end
                    end
                    
                    if isempty(permu1)&isempty(permu2)
                        [artificial]=[permu];
                    else
                        if isempty(permu1)==1
                        permu2(1)=[];
                        [artificial]=[permu,permu2];
                        elseif isempty(permu2)==1
                        permu1(end)=[];
                        [artificial]=[permu1,permu];
                        else
                        permu2(1)=[];
                        [artificial]=[permu,permu2];
                        end                
                    end
                                      
                else
                    nn2=nn2-1;
                end
        
            end   
    loop=isempty(artificial);
    else
        nn=nn-1;
        loop=1;
    end
end

[art,iaar,icar]=unique(artificial,'stable');
random=randperm(n);
diff=setdiff(random,art,'stable');
artificial=[art,diff];
artchor=zeros(m+1,n);
artchor(1,:)=artificial;
for j=2:m+1
    artchor(j,:)=randi([1,3],1,n);
end
artchorom.position=artchor;
[y1,y2]=senfit(artchorom.position,data);
artchorom.value=[y1,y2];
%% vns
for t=1:5
	%swap
	swap=z;
	swap.position=artchor;
	si=randperm(n,2);
	o1=swap.position(:,si(1));
	o2=swap.position(:,si(2));
	swap.position(:,si(1))=o2;
	swap.position(:,si(2))=o1;
	[y1,y2]=senfit(swap.position,data);
	swap.value=[y1,y2];
	%insertion
	inser=z;
	inser.position=artchor;
	ini=randperm(n,2);
	inser2=inser;
	first=ini(1);
	secnd=ini(2);
	if first<secnd
        inser2.position(:,first)=inser.position(:,secnd);
        inser.position(:,secnd)=[];
        inser2.position(:,first+1:n)=inser.position(:,first:end);
    else
        inser2.position(:,secnd)=inser.position(:,first);
        inser.position(:,first)=[];
        inser2.position(:,secnd+1:n)=inser.position(:,secnd:end);
    end
	[y1,y2]=senfit(inser2.position,data);
	inser2.value=[y1,y2]; 
	[vns]=[swap,inser2];
	if t==1
        vns2(t:2)=vns;
    else
        vns2(t+(t-1):2*t)=vns;
    end
end
vnspop(1)=artchorom;
vnspop(2:11)=vns2(1:10);
vp=repmat(z,11,1);
for ivp=1:11
    vp(ivp).position=vnspop(ivp).position;
    vp(ivp).value=vnspop(ivp).value;
end
for ivp=1:11
    vvp(ivp)=[vp(ivp).value(1)];
end
[vpo vpi]=sort(vvp);
vp=vp(vpi);
ap=1;
vpp(ap)=vp(1); %pareto
for sp=2:length(vp)
	if vp(sp).value(2)>=vpp(ap).value(2)       
    else
	ap=ap+1;
    vpp(ap)=vp(sp);
	end
end
artchorom=vpp(1);
%% selection
F{1}=[];
npops=numel(pop);
for is=1:npops        
    ps=pop(is);
    ps.DominationSet=[];
    ps.DominatedCount=0;        
    for js=1:npops
        if js==is
            continue;
        end            
        qs=pop(js);
        if Dominates(ps,qs)
            ps.DominationSet=[ps.DominationSet js];
        elseif Dominates(qs,ps)
            ps.DominatedCount=ps.DominatedCount+1;
        end
    end        
    if ps.DominatedCount==0
        ps.Rank=1;
        F{1}=[F{1} is];
    end        
	select{is}=ps;        
end
f=1;
while true        
	Q=[];
	for is2=1:numel(F{f})
        ps=select{F{f}(is2)};             
        for js2=1:numel(ps.DominationSet)
            qs=select{ps.DominationSet(js2)};                
            qs.DominatedCount=qs.DominatedCount-1;
            if qs.DominatedCount==0
                qs.Rank=f+1;
                Q=[Q ps.DominationSet(js2)];
            end                
            select{ps.DominationSet(js2)}=qs;
        end
    end        
	if isempty(Q)
	break;
    end        
	F{f+1}=Q;
	f=f+1;        
    end
%% crossover & mutation
cpop=repmat(z,ncrosp,1);
for cr=1:ncrosp
    [mother father]=tournament(select);
    cpoint=randperm(n,2);
    
    girl=z;
    cpoint1=cpoint(1);
    girl.position(:,1:cpoint1)=mother.position(:,1:cpoint1);
    [dif1,idif1]=setdiff(artchorom.position(1,:),girl.position(1,:),'stable');
    girl.position(:,cpoint1+1:n)=artchorom.position(:,idif1);
    cpop(cr).position=girl.position;
    [yc1 yc2]=senfit(cpop(cr).position,data);
    cpop(cr).value=[yc1,yc2];
    
    boy=z;
    cpoint2=cpoint(2);
    boy.position(:,1:cpoint2)=father.position(:,1:cpoint2);
    [dif2,idif2]=setdiff(artchorom.position(1,:),boy.position(1,:),'stable');
    boy.position(:,cpoint2+1:n)=artchorom.position(:,idif2);
    cpop(cr+1).position=boy.position;
    [ycc1 ycc2]=senfit(cpop(cr+1).position,data);
    cpop(cr+1).value=[yc1,yc2];
end
cpop=cpop(1:80);
mpop=repmat(z,nmut,1);
for mr=1:nmut
    mpoint=randi([1 npop]);  
    pm=pop(mpoint).position;
    j1=randi([1 n-1]);
    j2=randi([j1+1 n]);
    nj1=pm(:,j1);
    nj2=pm(:,j2);
    pm(:,j1)=nj2;
    pm(:,j2)=nj1;
    mpop(mr).position=pm;
    [mc1,mc2]=senfit(mpop(mr).position,data);
    mpop(mr).value=[mc1,mc2];
end
%% pareto fronte
pop=[cpop;mpop];    
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
pp=z;
a=1;
pp(a)=p(1); %pareto
for s=2:length(p)
	if p(s).value(2)>=pp(a).value(2)       
    else
	a=a+1;
    pp(a)=p(s);
	end
end
end
u=zeros(length(pp),2);
for q=1:length(pp)
	u(q,:)=pp(q).value; 
end
filename = 'pareto100.xlsx';
xlswrite(filename,u);
disp([ ' Time = '  num2str(toc)])
    

        
        
     






        