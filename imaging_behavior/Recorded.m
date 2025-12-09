%%%%%%%%%%%%%%%%%%%
%% Zicheng Yang  CCMU
%% Version: calcium imaging data analysis
%%%%%%%%%%%%%%%%%%%  
%%
clear all;
close all;

% load files
actfile ='file.xlsx';
cafile ='file.xlsx';

% parameters 
Fs = 100; 
Ts = 1/Fs;
correctCue =2; 
Vvoffset=42;
pre_time = 3; 
trial_time = 15;
    ntrialpersess = 20;
isoneodorcase = false;

aData = [];
[~,sheets] = xlsfinfo(actfile);
isheet = 1;
nsheet = length(sheets);
while(isheet<=nsheet)
    tmp = xlsread(actfile,isheet);
    if(isempty(tmp)) break; end;
    aData = [aData; tmp];
    isheet = isheet+1;
end;

cData = [];
[~,sheets] = xlsfinfo(cafile);
isheet = 1;
nsheet = length(sheets);
while(isheet<=nsheet)
    tmp = xlsread(cafile,isheet);
    if(isempty(tmp)) break; end;
    cData = [cData; tmp];
    isheet = isheet+1;
end;

odor1 = aData(:,1);
odor2 = aData(:,2);
lick = aData(:,3);
pump = aData(:,4);
action = aData(:,5);
odor = odor1+odor2; 
idx1 = find(diff(odor1)==1);
idx2 = find(diff(odor2)==1);
idx = find(diff(odor)==1)+1;

podor1 = cData(:,1);
podor2 = cData(:,2);
podor = podor1+podor2;
pidx = find(diff(podor)==1)+1;


ntrials =length(idx);
nsessions = floor(ntrials/ntrialpersess);
ncadatapnts = 18*Fs;
cas = zeros(ncadatapnts,ntrials);

lickdata = [];
lickdataadd = [];
lickrate = [];
for i=1:ntrials
    if(correctCue==1)
        cueids(i) = odor1(idx(i))==1;
    else
        cueids(i) = odor2(idx(i))==1;
    end;


    bidx = max(1,idx(i)-2*Fs); 
    atriallickadd = lick(bidx:bidx+(2+trial_time)*Fs-1); 
    lickdataadd=[lickdataadd; atriallickadd']; 
    
    islicked(i) = sum(atriallickadd(2*100:8*100))>0;
    islickedinwnd(i) = sum(lick(idx(i)+3*100:idx(i)+5*100))>0;
    
    bidx = max(1,pidx(i)-pre_time*Fs);
    cas(:,i) = cData(bidx:bidx+(pre_time+trial_time)*Fs-1,4);
end;

if correctCue==1
    cue1ids = cueids;
else
    cue1ids = ~cueids;
end;


Voffset =Vvoffset;  
F0 = squeeze(mean(cas(1*Fs+1:3*Fs,:)));
fca = zeros(size(cas));
for j=1:ntrials
    fca(:,j) = (cas(:,j)-F0(j))/(F0(j)-Voffset);
end;
fca = fca(1*Fs+1:end,:);
mca = mean(fca,2)';
vca = std(fca,0,2)';

% PLOT DATA
noc = 10;
if isoneodorcase
    noc = 20;
end;

% figure; 
shits = [];
suhits= [];
hits = islickedinwnd&cueids;
for i=1:nsessions
    shits(i) = sum(hits((i-1)*20+1:i*20));
    chitrate(i) = shits(i)/noc*100;
end;
suhits=sum(shits);
figure;
plot(crate,'color','b','LineWidth',2);
xlabel('session');
ylabel('Correct Rate');
ylim([0,1]);
title('Hit');

% figure; 
misses = (~islickedinwnd)&cueids;
smisses = [];
for i=1:nsessions
    smisses(i) = sum(misses((i-1)*20+1:i*20));
    cmisserate(i) = smisses(i)/noc*100;
end;
sumisses=sum(smisses);
plot(crate,'color','b','LineWidth',2);
xlabel('session');
ylabel('correct rate');
ylim([0,1]);
title('Miss');

% figure; 
screjects = [];
crejects = (~islicked)&(~cueids);
for i=1:nsessions
    screjects(i) = sum(crejects((i-1)*20+1:i*20));
    ccrejectrate(i) = screjects(i)/noc*100;
end
sucrejects=sum(screjects);
plot(crate*100,'color','b','LineWidth',3);
xlabel('session');
ylabel('correct rate(%)');
ylim([0,100]);
title('Correct reject');

% figure; 
sfalsealarms = [];
falsealarms = islicked&(~cueids);
for i=1:nsessions
    sfalsealarms(i) = sum(falsealarms((i-1)*20+1:i*20));
    cfalsealarmrate(i) = sfalsealarms(i)/noc*100;
end;
sufalsealarms=sum(sfalsealarms);
plot(crate,'color','b','LineWidth',2);
xlabel('session');
ylabel('correct rate(%)');
ylim([0,1]);
title('False alarm');

%FOUR CASES:hit, mis, CR,FA

tca = fca(:,hits);
tcahits=tca';
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcahits=mca;
vcahits=vca;
figure('color',[1 1 1]); imagesc(lickdataadd(hits,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',1:100:1700);
set(gca,'XTickLabel', -2:1:15);
title('Hit cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Hit cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(suhits-1)*100,'b');

xlabel('Time (s)');
ylabel('dF/F (%)');
title('Hit cases');

tca = fca(:,misses);
tcamisses=tca';
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcamisses=mca;
vcamisses=vca;
figure('color',[1 1 1]); imagesc(lickdataadd(misses,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',1:100:1700);
set(gca,'XTickLabel', -2:1:15);
title('Miss cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Miss cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sumisses-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');
title('Miss cases');

tca = fca(:,crejects);
tcacrejects=tca';
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcacrejects=mca;
vcacrejects=vca;
figure('color',[1 1 1]); imagesc(lickdataadd(crejects,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',1:100:1700);
set(gca,'XTickLabel', -2:1:15);
title('Correct reject cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Correct reject cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sucrejects-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');
title('Correct reject cases');

tca = fca(:,falsealarms);
tcafalsealarms=tca';
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcafalsealarms=mca;
vcafalsealarms=vca;
figure('color',[1 1 1]); imagesc(lickdataadd(falsealarms,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',1:100:1700);
set(gca,'XTickLabel', -2:1:15);
title('False alarm cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','False alarm cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sufalsealarms-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');
title('False alarm cases');

% correct rate

for i=1:nsessions
    scorrects(i) = screjects(i)+shits(i);
    scorrectrate(i) = scorrects(i)/20*100;
end;

avercr=mean(scorrectrate)

beep on;

numER=find(scorrectrate>=60,1)-1;
numP=find(chitrate>=40,1)-1;
numLR=nsessions-numER;
numR=nsessions-numP;
ans1=[numP,numR,numER,numLR,nsessions];
beep;
