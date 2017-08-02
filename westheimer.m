%%  NOTE
%   This version of the Westheimer analysis script is compatible with the
%   following paradigms: whmSuperSet, whmHexCancellation, &
%   whmCancellation2Sz. whmMixed and whmHexFreq have been moved to a
%   separate script.

%% ADD CODE BASES TO PATH
addpath(genpath('~/code/git/rcaBase'));
addpath(genpath('~/code/git/mrC'));
addpath(genpath('~/code/git/sweepAnalysis'));
addpath(genpath('~/code/git/svndl'));

%% SET UP: DEFINE VARIABLES & LOAD DATA
clear all
close all

paradigm = 'whmSuperSet'; % 'whmSuperSet' | 'whmHexCancellation' | 'whmCancellation2Sz'
stimFrq = [30/11,3,3.75]; % 3 for whmHexCancellation, whmCancellation2Sz | [30/11,3,3.75] for whmSuperSet
nPol = 2; % 2 for whmSuperset | 1 for whmHexCancellation, whmCancellation2Sz
% cndLabels = {'UR,F,20' 'UR,F,14' 'LR,F,20' 'LR,F,14' 'UR,P1,20' 'UR,P1,14' 'LR,P1,20' 'LR,P1,14' 'UR,P2,20' 'UR,P2,14' 'LR,P2,20' 'LR,P2,14' 'UH,20' 'LH,20' ...
%     'UR,20' 'LR,20' 'UH,14' 'LH,14' 'UR,14' 'LR,14'};

parentDir = '/Users/babylab/Desktop/whm';
[dataFolder,dataSet,names,RCAfolder] = getInfo(parentDir,paradigm);

tic
for s = 1:length(dataSet)
    fprintf('Running subject %s\n', names{s});
    curDataFolder = sprintf('%s/%s', dataFolder,dataSet{s});   
    [data{s},avgedData{s}, nCnd] = loadData(curDataFolder,stimFrq); % data: nChan x nTimept x nTri x nCnd
end
toc

%% SORTING DATA FOR RCA
% FORMAT: cell array {cnd x subj}(samples x channels x trials)
for a = 1:length(dataSet)
    for c = 1:nCnd
        RCA{c,a} = squeeze(data{a}{c});
    end
end
switch paradigm    
    case 'whmSuperSet'
        % EFFECT OF FREQ: POOLING OVER ECC + POL
        frq1 = RCA([1:2,7:8,13:14,19:20,25:26,31:32],:);
        frq2 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+2,:);
        frq3 = RCA([1:2,7:8,13:14,19:20,25:26,31:32]+4,:);
        RCA_SuperSetFrq = {frq1 frq2 frq3};
        % EFFECT OF ECCENTRICITY: POOLING OVER TF + POL
        SF = RCA([1:6],:);
        SP1 = RCA([1:6]+6,:);
        SP2 = RCA([1:6]+12,:);
        IF = RCA([1:6]+18,:);
        IP1 = RCA([1:6]+24,:);
        IP2 = RCA([1:6]+30,:);        
    case 'whmHexCancellation'
        RCA_UR = RCA([1 5 9 13],:); 
        RCA_UL = RCA([1 5 9 13]+1,:);
        RCA_LL = RCA([1 5 9 13]+2,:);
        RCA_LR = RCA([1 5 9 13]+3,:);
        RCA_F = RCA([1:4],:);
        RCA_P1 = RCA([1:4]+1,:);
        RCA_P2 = RCA([1:4]+2,:);     
        RCA_HexCancellation = {RCA_UR RCA_UL RCA_LL RCA_LR RCA_F RCA_P1 RCA_P2};
    case 'whmCancellation2Sz'
        RCA_20 = RCA([1,3,5,7,9,11,13:16],:);
        RCA_14 = RCA([2,4,6,8,10,12,17:20],:);
        RCA_F = RCA([1:4],:);
        RCA_P1 = RCA([1:4]+4,:);
        RCA_P2 = RCA([1:4]+8,:);
        RCA_UR = RCA([1,2,5,6,9,10,15,19],:);
        RCA_LR = RCA([3,4,7,8,11,12,16,20],:);
        RCA_UH = RCA([13,17],:);
        RCA_LH = RCA([14,18],:);
        RCA_Cancellation2Sz = {RCA_20 RCA_14 RCA_F RCA_P1 RCA_P2 RCA_UR RCA_LR RCA_UH RCA_LH};
%         var2str = @(x) inputname(1);
%         for i = 1:length(RCA_Cancellation2Sz)
%             names(i) = var2str(RCA_20);
%         end
%         boo = struct('data',{{RCA_20 RCA_14 RCA_F RCA_P1 RCA_P2 RCA_UR RCA_LR RCA_UH RCA_LH}});
end

%% RUN RCA
% * is there a way to automate RCA subset name generation? 

time = 1000/3; % [1000/(30/11),1000/3,1000/3.75] 
cnds = RCA_Cancellation2Sz;
cndNames = {'20' '14' 'F' 'P1' 'P2' 'UR' 'LR' 'UH' 'LH' }; % {'allUL' 'allLL' 'allF' 'allP1' 'allP2'} | {'frq1' 'frq2' 'frq3'}
timeCourseLen = repmat(time,[1,length(cnds)]); 
tic
for i = 1:length(cnds)
%     [rcaDataALL, W, A] = rcaRunProject(cnds{i}, RCAfolder, timeCourseLen(i), cndNames{i}, nPol);
    [rcaDataALL, W, A] = rcaRunProject(RCA([15 19],:), RCAfolder, time, 'UR_20v14', nPol);
%     [rcaDataALL, W, A] = rcaRunProject(RCA(9:10,:), RCAfolder, 1000/3,
%     'cnd9v10', nPol); TEST
end
toc

%% MULTIPLE SUBPLOTS
tc1 = linspace(0, timeCourseLen(1), size(rcaDataALL{1, 1}, 1));

[mu12, s12] = prepData(rcaDataALL12);
[mu78, s78] = prepData(rcaDataALL78);
[mu1314, s1314] = prepData(rcaDataALL1314);
[mu1920, s1920] = prepData(rcaDataALL1920);
[mu2526, s2526] = prepData(rcaDataALL2526);
[mu3132, s3132] = prepData(rcaDataALL3132);
    
group_upper_27_mu = [mu12(:, 1) mu78(:, 1) mu1314(:, 1)];
group_lower_27_mu = [mu1920(:, 1) mu2526(:, 1) mu3132(:, 1)];   
group_upper_27_s = [s12(:, 1) s78(:, 1) s1314(:, 1)];
group_lower_27_s = [s1920(:, 1) s2526(:, 1) s3132(:, 1)];

[h1, h2] = subplotMultipleComponents(tc1, {group_upper_27_mu, group_upper_27_s}, ... % each group = 1 cnd
        {group_lower_27_mu, group_lower_27_s}, {'Lower 2.73 Hz', 'Upper 2.73Hz'});
    saveas(h1, 'Group  2.73 Hz _byGroup.fig');
    saveas(h2, 'Group  2.73 Hz _byRegion.fig');

%% COMPARE CONDITIONS VIA TIMECOURSE
chanROI = 71:76;
cndROI = [16 20];
subj = '0037'; % see names for options
yLim = [-500 500];
plotTimecourse(avgedData,subj,yLim,chanROI,cndROI,cndLabels,names,parentDir)

%% CODE CHECK: RAW TIMECOURSE PLOTS
subjROI = 1;
cndROI = 1;
numTimept = size(avgedData{subjROI}{cndROI},1);
yLim = [-175 175];
gcaOpts = {'XTick',linspace(0,numTimept,5),'XTickLabel',{'0','83.33','166.67','250','333.33'},...
    'XLim',[0 numTimept],'YLim',yLim,'box','off','tickdir','out',...
    'fontname','Helvetica','linewidth',1.5,'fontsize',10};

for i = 1:128
    subplot(16,8,i)
    plot(squeeze(avgedData{subjROI}{cndROI}(:,i)),'color','b')  
    title(sprintf('%s, Ch. %d',num2str(cndROI),i))
    set(gca,gcaOpts{:})
end