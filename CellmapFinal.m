function CellmapFinal (Monkey_Name,Sde,AlignedOn)
% This function will creat the heatmap for each monkey based on raw 
% data for the cells listed in the Metadata_all_Monkey data base
% created by AC and Damien. 
% the monkey name, the side and the alignment need to be specified in 
% the function calling

% this program will only analyze cells that were recorded with a
% corresponding GPIO file (for alignment with the behavioral task) and it
% will only analyze the first occurrence of the cells.

% Processing will be done on Raw data normalize to the inter-trial signal
% Data for each trials will be stored in the variable TT
% example Heatmap_Final ('Quartz', 'L (SMA)','RewardOn_withGPIOoffset')

%Depending on the Monkey the alignement option will be different:
%For Quartz: 'Start_withGPIOoffset', 'RewardOn_withGPIOoffset','TrialEnd_withGPIOoffset'
%For Ulrik:'CenterOn_withGPIOoffset','CenterOff_withGPIOoffset','CenterCapture_withGPIOoffset','CenterHold_withGPIOoffset','TargetOn_withGPIOoffset,TargetOff_withGPIOoffset,
%'CenterLeave_withGPIOoffset','TargetCapture_withGPIOoffset',RewardON_withGPIOffset','RewardOff_withGPIOoffset'


%% Variabes
%looking at x s before the start or reward and y second after center on bhv file
    x=1;
    y=2;
    S=10; %This is the sampling rate
    k=0;
    TT=[]; % variable where the data by trials will be stored

%%
[num, txt, raw] = xlsread('Z:\TWLab\share\ASAP 2022-2025 Cortical Calcium Imaging\Manuscript preparation-SMA and M1 normal animals\Metadata_all_monkeys');
Occurence=cell2mat (raw (2:end,9));
MonkeyName=(raw (2:end,1));
Side=(raw (2:end,2));
Loc=(raw (2:end,5));
fname=(raw (2:end,4));
Cells=replace((raw (2:end,7)),'C','');
GlobalCellsID=(raw (2:end,8));
GlobalCellsID=replace (GlobalCellsID,'_',' ');
GPIOfile_available=cell2mat (raw (2:end,41));
% This is needed for Ulrik because there is only one day for each condition
% but cells might have an higher occurence.
if strcmp(Monkey_Name,'Ulrik')==1;
Occurence (Occurence>1)=1;
end


for i=1:length (Occurence)
   if isequal(MonkeyName{i},Monkey_Name)==1 & Occurence(i)==1 & isequal(Side{i},Sde)==1  &  GPIOfile_available(i)==1

        k=k+1; 
        load([Loc{i} '\'  fname{i}]);
       iii=cell2mat(Cells(i)); %because the cell number will be differents for each file
        Raw=eval(['TouchScreen.Accepted_Cells(' iii ').Raw_data']);
        Raw_timing2=eval (['TouchScreen.Accepted_Cells(' iii ').Raw_timing2']);
        B=find(isnan(Raw));
        Raw(B)=0;
        GlobalID{k}=GlobalCellsID{i};

%% Depending on the Monkey Name the number of condition will be different
if strcmp(Monkey_Name,'Quartz')==1;
    cdt=3;
    %for Quartz there is 3 condition right center and left condition
end
if strcmp(Monkey_Name,'Ulrik')==1;
    cdt=2;
    %for Quartz there is 3 condition right center and left condition
end

        %Condition 
        for ii=1:cdt
            j=1;
            M_Norm=[];
            DataR=[];
            InterR=[];
            DataR_zs=[];
            Start=eval(['TS_results(' num2str(ii) ').' AlignedOn]);
            % for each animal the start and end of the trial have differemt name 
            % This is necessary to normalize the raw signal with the intertrial data
            if strcmp(Monkey_Name,'Quartz')==1; 
            StartTrial=eval(['TS_results(' num2str(ii) ').Start_withGPIOoffset']);
            end
            if strcmp(Monkey_Name,'Ulrik')==1;
            StartTrial=eval(['TS_results(' num2str(ii) ').CenterOn_withGPIOoffset']);
            end
            
            
            %for raw data
                while j<length (Start) 
                    g1=Start(j); % to create the window of interest in s
                    g2=StartTrial(j); % to select the intertrial signal for z scoring
                    if g1<3 
                        j=j+1;
                    else
                        if (length (find(Raw_timing2<g1)))+((y*S)-1)> length (Raw)
                        j=j+1;
                        else
                        DR=Raw((length (find (Raw_timing2<(g1))))-(x*S):(length (find(Raw_timing2<g1)))+((y*S)-1));
                        Inter_DR=Raw((length (find (Raw_timing2<(g2))))-(2*S):(length (find(Raw_timing2<g2)))-((1*S)-1));
                            if sum (DR)==0
                            j=j+1;
                            else
                            DataR=[DataR,DR];
                            InterR=[InterR,Inter_DR];
                            DataR_zs=[DataR_zs,((DR-mean(Inter_DR))/std (Inter_DR))];
                            test{k}=DataR_zs;
                            j=j+1;
                            end                 
                        end
                    end
                end
                
            %% zscoring on the average
            M_DataR=mean (DataR,2);
            M_InterR=mean (InterR,2);
            Cdt(ii).Raw{k}.MeanZs=(M_DataR -mean(M_InterR))/std (M_InterR);        
            % Mean of individual Zscoretrials needed to calculate SD for
            % plotting
            Cdt(ii).Raw{k}.IndividualTrial_Zs1=(DataR-mean(M_InterR))/std (M_InterR);
            Cdt(ii).Raw{k}.MeanZs_IndividualTrial1=mean (Cdt(ii).Raw{k}.IndividualTrial_Zs1,2);
            
            %This is an alternative Z-scoring method that can be tried.Here we z-score using the
            %preceding intertrial signal data not the average intertrial
            %signal
            %Z scoring with the inter of each trial
            Cdt(ii).Raw{k}.IndividualTrial_Zs2=DataR_zs;
            Cdt(ii).Raw{k}.MeanZs_IndividualTrial2=mean (DataR_zs,2);

            %% Calculate the standart deviation for ploting each cell
            [a,b]=size (test{k});
                if b>1
                Cdt(ii).Raw{k}.SdZs_IndividualTrial1=std ((DataR'-mean(M_InterR))/std (M_InterR))';
                Cdt(ii).Raw{k}.SdZs_IndividualTrial2=std (DataR_zs')';

                else
                Cdt(ii).Raw{k}.SdZs_IndividualTrial1=zeros(30,1);
                Cdt(ii).Raw{k}.SdZs_IndividualTrial2=zeros(30,1);
                end
             Cdt(ii).trialswithdata=b; %this is the number of succeful trial   
             
             %% stats to compare before and after for each cells if there is an increase or not 
             
             MDataStatBefore1=mean (Cdt(ii).Raw{k}.IndividualTrial_Zs1(1:10,:),1);
             MDataStatAfter1=mean (Cdt(ii).Raw{k}.IndividualTrial_Zs1(11:20,:),1);

             MDataStatBefore2=mean (Cdt(ii).Raw{k}.IndividualTrial_Zs2(1:10,:),1);
             MDataStatAfter2=mean (Cdt(ii).Raw{k}.IndividualTrial_Zs2(11:20,:),1);

             [Cdt(ii).Raw{k}.MeanBeforeAfter.p1,h]=signrank(MDataStatBefore1,MDataStatAfter1);
             [Cdt(ii).Raw{k}.MeanBeforeAfter.p2,h]=signrank(MDataStatBefore2,MDataStatAfter2);

             Cdt(ii).Raw{k}.Ratio1=mean (MDataStatAfter1-MDataStatBefore1);
             Cdt(ii).Raw{k}.Ratio2=mean (MDataStatAfter2-MDataStatBefore2);  
            

             %% for Data export
             for jjj=1:Cdt(ii).trialswithdata
             M_Name{jjj}=Monkey_Name;
             H{jjj}={GlobalID{k}};
             Trial_Number{jjj}=jjj;
             SideP{jjj}=ii;
             end
             T=table(M_Name',H',Trial_Number',SideP',Cdt(ii).Raw{k}.IndividualTrial_Zs1');
             TT=[TT;T];

             clear DataR InterR DataR_zs M_InterR M_DataR test a b M_Name H Trial_Number SideP T
        end
    end
end


%% Ploting Raw Data Z scored ordered based on left target using Z-scoring methode 1

if strcmp(Monkey_Name,'Quartz')==1;
%Quartz there is 3 condition right center and left condition
%reorder on left meaning condition 3
ratio3=[];
M_Norm3=[];
p3=[];
SD3=[];
for j=1:length (Cdt(3).Raw)
    M_Norm3=[M_Norm3,Cdt(3).Raw{j}.MeanZs_IndividualTrial1];
    p3=[p3,Cdt(3).Raw{j}.MeanBeforeAfter.p1];
    ratio3=[ratio3,Cdt(3).Raw{j}.Ratio1];
    SD3=[SD3,Cdt(3).Raw{j}.SdZs_IndividualTrial2];

end
    [temp, order] = sort(ratio3);    
    ReOrderedM_Norm3=M_Norm3(:,order);
    ReOrder_p3=p3(order);
    ReOrder_ratio3=ratio3(order);
    ReOrder_SD3=SD3(:,order);
    ReorderGlobalID=GlobalID(:,order);
 

ratio1=[];
M_Norm1=[];
p1=[];
SD1=[];
for j=1:length (Cdt(1).Raw)
    M_Norm1=[M_Norm1,Cdt(1).Raw{j}.MeanZs_IndividualTrial1];
    p1=[p1,Cdt(1).Raw{j}.MeanBeforeAfter.p1];
    ratio1=[ratio1,Cdt(1).Raw{j}.Ratio1];
    SD1=[SD1,Cdt(1).Raw{j}.SdZs_IndividualTrial2];

end

    ReOrderedM_Norm1=M_Norm1(:,order);
    ReOrder_p1=p1(order);
    ReOrder_ratio1=ratio1(order);
    ReOrder_SD1=SD1(:,order);

    
ratio2=[];
M_Norm2=[];
p2=[];
SD2=[];
for j=1:length (Cdt(2).Raw)
    M_Norm2=[M_Norm2,Cdt(2).Raw{j}.MeanZs_IndividualTrial1];
    p2=[p2,Cdt(2).Raw{j}.MeanBeforeAfter.p1];
    ratio2=[ratio2,Cdt(2).Raw{j}.Ratio1];
    SD2=[SD2,Cdt(2).Raw{j}.SdZs_IndividualTrial2];
end
  

    ReOrderedM_Norm2=M_Norm2(:,order);
    ReOrder_p2=p2(order);
    ReOrder_ratio2=ratio2(order);
    ReOrder_SD2=SD2(:,order);


  %% ploting
figure (1)
hold on 
subplot (1,3,2);
clims = [-2 2];
imagesc(ReOrderedM_Norm2',clims);
colorbar;
yticks=([]);
xticks=([1 10 20]);
xticklabels=({'-1','0','1'});
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'YTick', yticks, 'YTickLabel', yticklabels);
title([Monkey_Name ' Raw ' Sde ' centered on ' AlignedOn ' CenterTarget']);

xlabel ('Time');
ylabel ('Cells');

subplot (1,3,3);
clims = [-2 2];
imagesc(ReOrderedM_Norm1',clims);
%imagesc(M_Norm',clims);
colorbar;
yticks=([]);
xticks=([1 10 20]);
xticklabels=({'-1','0','1'});
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'YTick', yticks, 'YTickLabel', yticklabels);
title([Monkey_Name ' Raw ' Sde ' centered on ' AlignedOn ' RightTarget']);
xlabel ('Time');
ylabel ('Cells');

subplot (1,3,1);
clims = [-2 2];
imagesc(ReOrderedM_Norm3',clims);
%imagesc(M_Norm',clims);
colorbar;
yticks=([]);
xticks=([1 10 20]);
xticklabels=({'-1','0','1'});
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'YTick', yticks, 'YTickLabel', yticklabels);
title([Monkey_Name ' Raw ' Sde ' centered on ' AlignedOn ' LeftTarget']);
xlabel ('Time');
ylabel ('Cells');

[l,ll]=size (M_Norm1);
for i=1:ll
    figure (i+1)
    hold on
    x=1:1:30;
    y=ReOrderedM_Norm1(:,i)';
    y2=(ReOrderedM_Norm1(:,i)+ReOrder_SD1(:,i))';
    y3=(ReOrderedM_Norm1(:,i)-ReOrder_SD1(:,i))';
    plot (x,y,'b')
    plot (x,y2,'b')
    plot (x,y3,'b')
    x2=[x, fliplr(x)];
    inBetween1 = [y,fliplr(y2)];
    inBetween2 = [y,fliplr(y3)];
    fill(x2, inBetween1, 'b');
    fill(x2, inBetween2, 'b');
    
    y=ReOrderedM_Norm2(:,i)';
    y2=(ReOrderedM_Norm2(:,i)+ReOrder_SD2(:,i))';
    y3=(ReOrderedM_Norm2(:,i)-ReOrder_SD2(:,i))';
    plot (x,y,'r')
    plot (x,y2,'r')
    plot (x,y3,'r')
    x2=[x, fliplr(x)];
    inBetween1 = [y,fliplr(y2)];
    inBetween2 = [y,fliplr(y3)];
    fill(x2, inBetween1, 'r');
    fill(x2, inBetween2, 'r');
    
    y=ReOrderedM_Norm3(:,i)';
    y2=(ReOrderedM_Norm3(:,i)+ReOrder_SD3(:,i))';
    y3=(ReOrderedM_Norm3(:,i)-ReOrder_SD3(:,i))';
    plot (x,y,'g')
    plot (x,y2,'g')
    plot (x,y3,'g')
    x2=[x, fliplr(x)];
    inBetween1 = [y,fliplr(y2)];
    inBetween2 = [y,fliplr(y3)];
    fill(x2, inBetween1, 'g');
    fill(x2, inBetween2, 'g');
    title (ReorderGlobalID{i})
    
end
end

if strcmp(Monkey_Name,'Ulrik')==1;
%% Ploting Raw Data order centered on condition 1 (meaning left
%%target) Zscoring on mean

ratio1=[];
M_Norm1=[];
p1=[];
SD1=[];
for j=1:length (Cdt(1).Raw)
    M_Norm1=[M_Norm1,Cdt(1).Raw{j}.MeanZs_IndividualTrial1];
    p1=[p1,Cdt(1).Raw{j}.MeanBeforeAfter.p1];
    ratio1=[ratio1,Cdt(1).Raw{j}.Ratio1];
    SD1=[SD1,Cdt(1).Raw{j}.SdZs_IndividualTrial2];

end

   [temp, order] = sort(ratio1);    
   ReOrderedM_Norm1=M_Norm1(:,order);
   ReOrder_p1=p1(order);
   ReOrder_ratio1=ratio1(order);
   ReOrder_SD1=SD1(:,order);
   ReorderGlobalID=GlobalID(:,order);

    
ratio2=[];
M_Norm2=[];
p2=[];
SD2=[];
for j=1:length (Cdt(2).Raw)
    M_Norm2=[M_Norm2,Cdt(2).Raw{j}.MeanZs_IndividualTrial1];
    p2=[p2,Cdt(2).Raw{j}.MeanBeforeAfter.p1];
    ratio2=[ratio2,Cdt(2).Raw{j}.Ratio1];
    SD2=[SD2,Cdt(2).Raw{j}.SdZs_IndividualTrial2];
end
     [temp, order2] = sort(ratio2);    

    ReOrderedM_Norm2=M_Norm2(:,order);
    ReOrder_p2=p2(order);
    ReOrder_ratio2=ratio2(order);
    ReOrder_SD2=SD2(:,order);
 
ratio3=[];
M_Norm3=[];
p3=[];
SD3=[];

  %% ploting raw data center on left
figure (1)
hold on 
subplot (1,2,2);
clims = [-6 6];
imagesc(ReOrderedM_Norm2',clims);
%imagesc(M_Norm',clims);
colorbar;
yticks=([]);
xticks=([1 10 20]);
xticklabels=({'-1','0','1'});
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'YTick', yticks, 'YTickLabel', yticklabels);
title([Monkey_Name ' Raw ' Sde ' centered on ' AlignedOn ' RightTarget']);
xlabel ('Time');
ylabel ('Cells');


subplot (1,2,1);
clims = [-6 6];
imagesc(ReOrderedM_Norm1',clims);
%imagesc(M_Norm',clims);
colorbar;
yticks=([]);
xticks=([1 10 20]);
xticklabels=({'-1','0','1'});
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'YTick', yticks, 'YTickLabel', yticklabels);
title([Monkey_Name ' Raw ' Sde ' centered on ' AlignedOn ' LeftTarget']);
xlabel ('Time');
ylabel ('Cells');

[l,ll]=size (M_Norm1);
for i=1:ll
    figure (i+1)
    hold on
    x=1:1:30;
    y=ReOrderedM_Norm1(:,i)';
    y2=(ReOrderedM_Norm1(:,i)+ReOrder_SD1(:,i))';
    y3=(ReOrderedM_Norm1(:,i)-ReOrder_SD1(:,i))';
    plot (x,y,'g')
    plot (x,y2,'g')
    plot (x,y3,'g')
    x2=[x, fliplr(x)];
    inBetween1 = [y,fliplr(y2)];
    inBetween2 = [y,fliplr(y3)];
    fill(x2, inBetween1, 'g');
    fill(x2, inBetween2, 'g');
    
    y=ReOrderedM_Norm2(:,i)';
    y2=(ReOrderedM_Norm2(:,i)+ReOrder_SD2(:,i))';
    y3=(ReOrderedM_Norm2(:,i)-ReOrder_SD2(:,i))';
    plot (x,y,'b')
    plot (x,y2,'b')
    plot (x,y3,'b')
    x2=[x, fliplr(x)];
    inBetween1 = [y,fliplr(y2)];
    inBetween2 = [y,fliplr(y3)];
    fill(x2, inBetween1, 'b');
    fill(x2, inBetween2, 'b');
    
    title (ReorderGlobalID{i})
    
end
end

end

