function ISI_Final (filename)
%this function could be used after ReorganisedData_Final
%it will look at the ISI, CV ands CV2

%Because previous studies have shown that the CV is sensitive to changes
% in the cell’s mean firing rate (a finding verified in the current results),
% Holt et al. (1996) developed an alternative method for determining a
% cell’s firing rate variability that was less sensitive to the cell’s mean
% firing rate. This alternative, referred to as CV2, is defined as
% as the difference in consecutive ISIs normalized by their mean to measure this variability in ISI 
% This provides a non-parametric measure of the regularity in spiking within a trial.


p1=[0.25 0.75];
p2=[0.1 0.9];
fid2= fopen(filename,'r');
while ~feof(fid2)    
fname = fgetl(fid2)

load (fname)

for i=1:length (Spontaneous.Accepted_Cells)
S_ISI=diff (Spontaneous.Accepted_Cells(i).Time_events);
TS_ISI=diff (TouchScreen.Accepted_Cells(i).Time_events);
% %% to calculate CV2
% for j=1:length (S_ISI)-1
%     S_CV2{j}=(2*(abs (S_ISI(j+1)-S_ISI(j))))/(S_ISI(j+1)+S_ISI(j));
% end
% for jj=1:length (TS_ISI)-1
%     TS_CV2{jj}=(2*(abs (TS_ISI(jj+1)-TS_ISI(jj))))/(TS_ISI(jj+1)+TS_ISI(jj));
% end    
%%    
Spontaneous.Accepted_Cells(i).ISI=S_ISI;
Spontaneous.Accepted_Cells(i).Mean_ISI=mean (S_ISI);
Spontaneous.Accepted_Cells(i).SD_ISI=std (S_ISI);
Spontaneous.Accepted_Cells(i).CV_ISI=Spontaneous.Accepted_Cells(i).SD_ISI/Spontaneous.Accepted_Cells(i).Mean_ISI*100;
Spontaneous.Accepted_Cells(i).Median_ISI=median (S_ISI);
Spontaneous.Accepted_Cells(i).Q_25=quantile(S_ISI,p1,"all");
Spontaneous.Accepted_Cells(i).Q_10=quantile(S_ISI,p2,"all");
% if length (S_ISI)>3
%     Spontaneous.Accepted_Cells(i).CV2=mean (cat (1, S_CV2{:}));
% else
%     S_CV2=[];;
% end

TouchScreen.Accepted_Cells(i).ISI=TS_ISI;
TouchScreen.Accepted_Cells(i).Mean_ISI=mean (TS_ISI);
TouchScreen.Accepted_Cells(i).SD_ISI=std (TS_ISI);
TouchScreen.Accepted_Cells(i).CV_ISI=TouchScreen.Accepted_Cells(i).SD_ISI/TouchScreen.Accepted_Cells(i).Mean_ISI*100;
TouchScreen.Accepted_Cells(i).Median_ISI=median (TS_ISI);
TouchScreen.Accepted_Cells(i).Q_25=quantile(TS_ISI,p1,"all");
TouchScreen.Accepted_Cells(i).Q_10=quantile(TS_ISI,p2,"all");
% if length (TS_ISI)>3
%     TouchScreen.Accepted_Cells(i).CV2=mean (cat (1, TS_CV2{:}));
% else
%     TS_CV2=[];;
% end
clear S_ISI TS_ISI
end
save ([fname '.mat'],'Spontaneous','TouchScreen','-append')
end