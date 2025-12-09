%%%%%%%%%%%%%%%%%%%
%% Zicheng Yang CCMU
%% origin averaged calcium signal of several mice; heatmap
%% Version: 0.1-2024/07/08-YZC-initial version
%%%%%%%%%%%%%%%%%%%
clear all;
close all;

% parameters
nko=5;
nwt=5;
Ts=1/100;

mcako =xlsread('x');
mcawt =xlsread('x');

avmcak =mean(mcako,1); 
stmcak=std(mcako,0,1); 
avmcaw =mean(mcawt,1); 
stmcaw=std(mcawt,0,1); 

plotHeatmap(-1.99:Ts:15,1:size(mcawt',2),mcawt,'Time (s)','#Trial','WT',false); 
plotHeatmap(-1.99:Ts:15,1:size(mcako',2),mcako,'Time (s)','#Trial','KO',false); 

figure('color',[1 1 1]);
h1=drawErrorLine(-1.99:Ts:15,avmcak*100,stmcak/sqrt(nko-1)*100,'r');
h2=drawErrorLine(-1.99:Ts:15,avmcaw*100,stmcaw/sqrt(nwt-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');%'fontweight','bold'
xlim([-2,15]);
set(gca,'xtick',-2:5:15);
set(gca,'linewidth',2,'FontSize',10,'fontweight','bold');

