%%%%%%%%%%%%%%%%%%%
%% Zicheng Yang @CCMU
%% Version1：Yzc 2023-07-28  plot hit, fal, correct rate
%%
%%%%%%%%%%%%%%%%%%%  

clear all;
close all; 
% load files-
actfile = '/.xlsx';

% parameters 
Fs = 100; 
Ts = 1/Fs;
correctCue = 2;
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


odor1 = aData(:,1);
odor2 = aData(:,2);
lick = aData(:,3);
pump = aData(:,4);
action = aData(:,5);
odor = odor1+odor2; 
idx1 = find(diff(odor1)==1);
idx2 = find(diff(odor2)==1);
idx = find(diff(odor)==1)+1;


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

end;

if correctCue==1
    cue1ids = cueids;
else
    cue1ids = ~cueids;
end;

hits = islickedinwnd&cueids;
falsealarms = islicked&(~cueids);
misses = (~islickedinwnd)&cueids;
crejects = (~islicked)&(~cueids);

% PLOT DATA

noc = 10;
if isoneodorcase
    noc = 20;
end;
shits = [];
suhits= [];
for i=1:nsessions
    shits(i) = sum(hits((i-1)*20+1:i*20));
    chitrate(i) = shits(i)/noc*100;
end;
figure;
plot(chitrate,'color','g','LineWidth',2);
xlabel('Sessions');
xlim([1,nsessions]);
ylabel('Correct rate(%)');
ylim([0,120]);
title('Hit');
set(gca,'FontSize',15);

figure; 
sfalsealarms = [];
for i=1:nsessions
    sfalsealarms(i) = sum(falsealarms((i-1)*20+1:i*20));
    cfalrate(i) = sfalsealarms(i)/noc*100;
end;
plot(cfalrate,'color','b','LineWidth',2);
xlabel('Sessions');
xlim([1,nsessions]);
ylim([0,120]);
title('False alarm');
set(gca,'FontSize',15);

screjects = [];
for i=1:nsessions
    screjects(i) = sum(crejects((i-1)*20+1:i*20));
    crate(i) = screjects(i)/noc;
end;

figure; 
scrates= [];
scrates =screjects+shits;
corate=scrates/20*100;
plot(corate,'color','m','LineWidth',2);
xlabel('Sessions');
xlim([1,nsessions]);
ylim([0,120]);
title('Correct rate(%)');
set(gca,'FontSize',15);

