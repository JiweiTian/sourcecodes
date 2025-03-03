clear
clc
close all
%%%%%%%%%%%%%%%%%%%%%%%%difinite variables
M=100;% numbrs of virtual machines
N=100;% workload numbers
M_vector=[50:5:100];
T_tot=5;% seconds
R_tot=10000;% Mega bite / seconds
PMR=1.25;
temp=0;
ALPHA=[0.1,0.5,0.9];
%k_e=[0.005*1000;0.05*1000;0.5*1000];% Joule/(Giga Hz)^2
k_e=[5];% Joule/(Mega Hz)^2 % scenario 1
%k_e=[0.005;0.05;0.5];% Joule/(Mega Hz)^2  scenario 1
%f_max=2.668*ones(M,1);% maximum frequencies for each VM
%f_zero=zeros(M,1);% starting frequncy of each VM
omega=1*ones(length(M_vector),1);% cost portion of VM consumption
E_max=60*ones(length(M_vector),1);% JOULE-maximum tolarated energy for each VM
Delta=3*ones(length(M_vector),1); %seconds-considered time of processing for each VM
W=1*ones(length(M_vector),1);% MHZ frequency needed for communication channel
Zeta=[0.2;0.5]; %milli Watt
%Omega=[0.2*10^(-3);0.5*10^(-3)]; %milli Watt
Omega1=5; %milli Watt
Omega2=50; %milli Watt
Omega3= [5:0.5:100]; %milli Watt for VM (increament and depend on VM) with slip 0.5
Omega4= [50:0.5:100]; %milli Watt for VM (increament and depend on VM) with slip 0.25
Omega=0.005;%milli Watt

Ceff=[1;100];% (Joule/ MHz^2) or (Joule/ (Mbit/s)^2);

%L_tot = 8 + PMR .* rand(1,N);
%load('workload1000');
%L_tot = 8 + PMR .* rand(1,N);
%L_tot=60 + (80-60).*rand(1,1000); %carico uniformemente distribuito   70+-10 with avg(L_{tot})=70 (PMR=1.14285) %UTILIZZATO PER Scenario 2
%save('workload1000M.mat','L_tot');
%L_tot_Vector = load('workload1000M','L_tot');
%L_tot_Vector = load('workload1000');
%L_tot=L_tot_Vector.workload1000;

mL_tot=900;
pmr=1.5;
a=mL_tot*(pmr-1);
%if pmr>1
%L_tot=(mL_tot-a) + 2.*(a).*rand(1,N);
%save('Ltot900PMR1.5.mat','L_tot');
L_tot=load('Ltot900PMR1.5.mat','L_tot');
L_tot=L_tot.L_tot;
%else
%    L_tot=(mL_tot-a).*ones(1,N);
%end
for i=1:N
    if (L_tot(i)>0)
        L_tot(i)=L_tot(i);
    else
        L_tot(i)=0;
    end
end
MM=[M_vector];
f_opt_wokloads=zeros(N,M); % optimal frequencies of M VMs for each workload
L_opt_wokloads=zeros(N,M); % optimal Load of M VMs for each workload
R_opt_wokloads=zeros(N,M); % optimal rate of M VMs for each workload

Opt_Comp_Energy=zeros(length(L_tot),M);

Opt_reconfig_Energy=zeros(length(L_tot),M);

Opt_reconfig_Energy1=zeros(length(L_tot),M);
Opt_reconfig_Energy2=zeros(length(L_tot),M);
Opt_reconfig_Energy3=zeros(length(L_tot),M);

Opt_Comm_Energy=zeros(length(L_tot),M);
Opt_Comm_Energy1=zeros(length(L_tot),M);
Opt_Comm_Energy2=zeros(length(L_tot),M);
Opt_Comm_Energy3=zeros(length(L_tot),M);
Opt_Comm_Energy4=zeros(length(L_tot),M);
Opt_Comm_Energy5=zeros(length(L_tot),M);
Opt_Comm_Energy6=zeros(length(L_tot),M);

total_energy=zeros(length(L_tot),M);
total_energy1=zeros(length(L_tot),M);
total_energy2=zeros(length(L_tot),M);
total_energy3=zeros(length(L_tot),M);
total_energy4=zeros(length(L_tot),M);
total_energy5=zeros(length(L_tot),M);
total_energy6=zeros(length(L_tot),M);
total_energy7=zeros(length(L_tot),M);



time=zeros(length(L_tot),M);
Q=4% numbers of Discrete ranges for Frequency of each VM
%tic
%%%%%%%%%% plots the results
%%%%%%% CVX solution
%MM=[20,30,40]; % VM numbesr for the second Scenario
for jj=1:length(M_vector),% Vm number
%tic
%for jj=1:3,
 %   j=MM(jj);
   %for j=1:M,
     j= M_vector(jj);
   temp=0;
    f_zero=0;
    f_max=11.6*ones(j,1);% maximum frequencies for each VM
    %f_max=2700*ones(j,1);% maximum frequencies for each VM
    P_Idle=0.005*ones(j,1);% Watt: Idle Power for each VM channel
    for i=1:length(L_tot),
        tic
        %test
        %L_tot=10;
%         fprintf(1, 'L_tot value: %8.4e\n', L_tot(i));
%         fprintf(1, 'Number of L_tot \n');
%         disp(i);
%         fprintf('VM number= \n');
%         disp(j);
        %*******************Feasibility condition************************************

        condizione_feas_workloadcomputation= (L_tot(i)<= sum(f_max(:).*Delta(1)));
        condizione_feas_channel=(L_tot(i)<= R_tot*(T_tot-Delta(1))/2);
        condizione_feas_background=(0<=sum(f_max(:).*Delta(1)));
        condizione_feas_IDle=(L_tot(i)>=0.3*j*Delta(1));
        
        feasibility=condizione_feas_workloadcomputation && condizione_feas_channel && condizione_feas_background && condizione_feas_IDle;
        
        if ~feasibility
            'VM='
            M
            error('Problem unfeasible')
                                else
        %     'Problem Feasibile!'
        end
        
    
    %**************************************************************************
        cvx_begin quiet
        cvx_solver sedumi
        %expression f_zero(j);% starting frequncy of each VM
        f_zero=temp;
        expression L_b(j);% background wokload for each VM before starting processing
        %L_b=zeros(1,M);
        %f_zero(:)=zeros(1,M);
        variable R(j); % optimum rate of channels for each VM
        variable f(j); % optimum frequency for each VM
        variable L(j); % optimum load for each VM
        dual variables A B C D E F G
        
        % objective optimization
        %minimize (sum(pow_p(f,3).*omega(1).*Delta(1))+k_e(2)*sum((f-f_zero).^2)+(T_tot-Delta(1))*((Zeta(2)*sum(power(2,2*L/(T_tot-Delta(1))*W(1))-1))+sum(P_Idle(:))));
        minimize (sum(pow_p(f,3).*omega(1).*Ceff(1).*Delta(1))+k_e(1)*sum((f-f_zero).^2)+((T_tot-Delta(1))*((Omega1*sum((2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)))));
        %s.t. constrainsts
        subject to
        
        A: sum(L)-L_tot(i)==0;
        %A: sum(L)-L_tot==0;
        B: sum(R)-R_tot<=0;
        C: -L<=0;
        D: -R<=0;
        E: 0<= f <= f_max(1);
        F: L+L_b<=f*Delta(1);
        G: 2*L-R*(T_tot-Delta(1))<=0;
        
        cvx_end
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%descrete range
        f_discrete=zeros(j,Q);
        for conta=1:j
            %f_discrete(conta,:)=[0:f_max(conta)./(Q-1):f_max(1)];
            %f_discrete(conta,:)=[0.15, 1.867, 2.133,2.533,2.668]; %Scenario one
            %f_discrete(conta,:)=[0.3, 0.533, 0.667, 0.800, 0.933]; %Scenario two
            %f_discrete(conta,:)=[1.3, 2.32, 2.94, 3.48, 4.06];%(Mbit/s)% for power-scalable real cluster Crusoe with CPU type TM-5800 in CLUSTER 2006 in http://dx.doi.org/10.1109/CLUSTR.2006.311839
            f_discrete(conta,:)=[8.12, 9.27, 11.01, 11.60];%(Mbit/s)% for Interl Nehalem Quad-core Processor in INFOCOM 2009 G.V. Laszewski et al
            
            %f_discrete(conta,:)=[300, 533, 667, 800, 933]; %ScenarionNew
            %f_discrete(conta,:)=[150, 1867, 2133,2533,2668];     %Mega hertz%Scenario one-type 2
            %f_discrete(conta,:)=[5, 10, 20, 30, 150];% test
            %f_discrete(conta,:)=[5, 300, 1500, 2000, 3000];% test2

        end
        f_precedente=zeros(j,1);
        f_successiva=zeros(j,1);
        x=zeros(j,1);
        f_opt=zeros(j,1);
        f_opt(:)=f(:);
        for conta=1:j
            
            delta_f_discrete=f_discrete(conta,:)-f_opt(conta);
            [ff,ind_ff]=min(abs(delta_f_discrete));
            if ff==0
                f_precedente(conta)=f_discrete(conta,ind_ff);
                f_successiva(conta)=f_discrete(conta,ind_ff);
                x(conta)=1; %any value is indifferent
            elseif ind_ff==1 &&(f_opt(conta)-f_precedente(conta)<0)
                 x(conta)=0;
            elseif ind_ff==1 &&(f_opt(conta)-f_precedente(conta)>=0)
                f_precedente(conta)=f_discrete(conta,1);
                f_successiva(conta)=f_discrete(conta,2);
                x(conta)=abs(f_opt(conta)-f_precedente(conta))./(f_successiva(conta)-f_precedente(conta));
            elseif ind_ff==Q
                f_precedente(conta)=f_discrete(conta,Q-1);
                f_successiva(conta)=f_discrete(conta,Q);
                x(conta)=abs(f_opt(conta)-f_precedente(conta))./(f_successiva(conta)-f_precedente(conta));
            elseif delta_f_discrete(ind_ff)>0
                f_precedente(conta)=f_discrete(conta,ind_ff-1);
                f_successiva(conta)=f_discrete(conta,ind_ff);
                x(conta)=abs(f_opt(conta)-f_precedente(conta))./(f_successiva(conta)-f_precedente(conta));
            else
                f_precedente(conta)=f_discrete(conta,ind_ff);
                f_successiva(conta)=f_discrete(conta,ind_ff+1);
                x(conta)=abs(f_opt(conta)-f_precedente(conta))./(f_successiva(conta)-f_precedente(conta));
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%descrete range
        
        % Ideal result (No DVFS)
%         Opt_Comp_Energy(i,j)=sum(((f).^3).*omega(1).*Delta(1));
%         Opt_reconfig_Energy(i,j)=k_e(1)*sum((f-f_zero).^2);
%        % Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Zeta(2)*sum(power(2,2*L/(T_tot-Delta(1))*W(1))-1))+sum(P_Idle(:)));
%         Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Omega(2)*sum((2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         total_energy(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy(i,j)+Opt_Comm_Energy(i,j);
%         temp=f;
        
        %Standard/Real  DVFS result
%         Opt_Comp_Energy(i,j)=sum(((f_successiva).^3).*omega(1).*Delta(1));
%         Opt_reconfig_Energy(i,j)=k_e(1)*sum((f_successiva-f_zero).^2);
%         %Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Zeta(2)*sum(power(2,2*L/(T_tot-Delta(1))*W(1))-1))+sum(P_Idle(:)));
%         Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Omega(2)*sum((2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         total_energy(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy(i,j)+Opt_Comm_Energy(i,j);
%         temp=f_successiva;
%         
        % Nicola-discrete result DVFS (NETDC)
        Opt_Comp_Energy(i,jj)=Ceff(1)*sum((((f_precedente).^3).*omega(1).*Delta(1)).*(1-x)+(((f_successiva).^3).*omega(1).*Delta(1)).*x);
        %Opt_reconfig_Energy(i,j)=(sum(k_e(2).*(f_successiva-f_precedente).^2))+(sum((k_e(2).*(f_precedente-f_zero).^2).*(1-x)+(k_e(2).*(f_successiva-f_zero).^2).*x));
        Opt_reconfig_Energy(i,jj)=(sum(k_e(1).*(f_successiva-f_precedente).^2))+(sum((k_e(1).*(f_precedente-f_zero).^2).*(1-x)+(k_e(1).*(f_successiva-f_zero).^2).*x));
        %Opt_reconfig_Energy2(i,jj)=(sum(k_e(2).*(f_successiva-f_precedente).^2))+(sum((k_e(2).*(f_precedente-f_zero).^2).*(1-x)+(k_e(2).*(f_successiva-f_zero).^2).*x));
        %Opt_reconfig_Energy3(i,jj)=(sum(k_e(3).*(f_successiva-f_precedente).^2))+(sum((k_e(3).*(f_precedente-f_zero).^2).*(1-x)+(k_e(3).*(f_successiva-f_zero).^2).*x));
        %Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Zeta(2)*sum(power(2,2*L/(T_tot-Delta(1))*W(1))-1))+sum(P_Idle(:)));
        RTT=7; %mili sec
        %Opt_Comm_Energy(i,j)=(T_tot-Delta(1))*((Omega(2)*sum((RTT*2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         Opt_Comm_Energy1(i,jj)=(T_tot-Delta(1))*((Omega1*sum((RTT*2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         Opt_Comm_Energy2(i,jj)=(T_tot-Delta(1))*((Omega2*sum((RTT*2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         Opt_Comm_Energy3(i,jj)=(T_tot-Delta(1))*((Omega3(j)*sum((RTT*2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
%         Opt_Comm_Energy4(i,jj)=(T_tot-Delta(1))*((Omega4(j)*sum((RTT*2*(L)/((T_tot-Delta(1))*W(1))).^(1/ALPHA(2))))+sum(P_Idle(:)));
       % Opt_Comm_Energy(i,jj)=(T_tot-Delta(1))*((Omega*sum((2*L/((T_tot-Delta(1))*W(1)*RTT)).^2)))+sum(P_Idle(:));% fixed max
        Opt_Comm_Energy(i,jj)=(T_tot-Delta(1))*(sum(Omega*(((sum(2.*RTT.*L/(T_tot-Delta(1)))).^2)))+sum(P_Idle));    

        %total_energy(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy(i,j)+Opt_Comm_Energy(i,j);
        total_energy1(i,jj)=Opt_Comp_Energy(i,jj)+Opt_reconfig_Energy(i,jj)+Opt_Comm_Energy(i,jj);
%         total_energy2(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy1(i,j)+Opt_Comm_Energy2(i,j);
%         total_energy3(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy1(i,j)+Opt_Comm_Energy3(i,j);
%         total_energy4(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy1(i,j)+Opt_Comm_Energy4(i,j);
%         
%         total_energy5(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy1(i,j)+Opt_Comm_Energy1(i,j);
%         total_energy6(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy2(i,j)+Opt_Comm_Energy1(i,j);
%         total_energy7(i,j)=Opt_Comp_Energy(i,j)+Opt_reconfig_Energy3(i,j)+Opt_Comm_Energy1(i,j);
        temp=(f_precedente.*(1-x))+(f_successiva.*(x));
        
        cvx_cputime1(i,j)=toc;
        %cvx_cputime_2(i,j)=cvx_cputime;
        %f_opt_wokloads(i,:)=f(1);
        %L_opt_wokloads(i,:)=L(1);
        %R_opt_wokloads(i,:)=R(1);
       
               
    end % for jobs (workloads)

end % for VMs
%save('IDEAL_energy1000M2.mat','total_energy','Opt_Comp_Energy','Opt_reconfig_Energy','Opt_Comm_Energy','cvx_cputime1');    
%save('STANDARD_energy1000M2.mat','total_energy','Opt_Comp_Energy','Opt_reconfig_Energy','Opt_Comm_Energy','cvx_cputime1');    
%save('Nicola_energy1000M2.mat','total_energy','Opt_Comp_Energy','Opt_reconfig_Energy','Opt_Comm_Energy','cvx_cputime1'); 
%time=toc;
MM=M_vector;
total_energyt1=zeros(1,length(MM));

Opt_Comp_Energyt1=zeros(1,length(MM));

Opt_Comm_Energyt1=zeros(1,length(MM));

tot_reconfig_Energy1=zeros(1,length(MM));

time_meanWL=zeros(length(MM),M,Q+1);
time_meanWL_M=zeros(length(MM),Q+1);
sum_time_meanWL_M=zeros(1,length(MM));

% for jj=1:length(MM)
%     for i=1:length(L_tot)
%         if (L_tot(i)==0)
%             Total_Time( ~any(Total_Time,2), : ) = []; % delete zero rows in matlab.
%             for j=1:M
%                 for qq=1:Q+1
%                     
%                 end
%             end
%         end
%         
%     end
% end
%Total_Time( ~any(Total_Time,2), : ) = []; % delete zero rows in matlab.

for jj=1:length(MM)
    Opt_Comp_Energyt1(jj)=mean(Opt_Comp_Energy(:,jj));
    Opt_Comm_Energyt1(jj)=mean(Opt_Comm_Energy(:,jj));
    tot_reconfig_Energy1(jj)=mean(Opt_reconfig_Energy(:,jj));
    total_energyt1(jj)=mean(total_energy1(:,jj));
end
   

% for jj=1:length(MM)
%     for j=1:M
%         for qq=1:Q+1
%             time_meanWL(jj,j,qq)=mean(Total_Time(jj,:,j,qq));
%         end
%     end
% end
% for jj=1:length(MM)
%     for  qq=1:Q+1
%         time_meanWL_M(jj,qq)=mean(time_meanWL(jj,:,qq));
%     end
% end
% for jj=1:length(MM)
%     sum_time_meanWL_M(jj)=sum(time_meanWL_M(jj,:));
% end
save('NetDC_ScnerioM50_5_100N100F1T3.mat','total_energyt1','tot_reconfig_Energy1',...
        'Opt_Comm_Energyt1','Opt_Comp_Energyt1','Total_Time','time_meanWL_M', 'time_meanWL');

    xlswrite('total_energy_PMR1.5.xlsx',total_energyt1);
    csvwrite('total_energy_PMR1.5.dat',total_energyt1);
    
    xlswrite('tot_reconfig_Energy_PMR1.5.xlsx',tot_reconfig_Energy1);
    csvwrite('tot_reconfig_Energy_PMR1.5.dat',tot_reconfig_Energy1);
    
    xlswrite('tot_Comm_Energy_PMR1.5.xlsx',Opt_Comm_Energyt1);
    csvwrite('tot_Comm_Energy_PMR1.5.dat',Opt_Comm_Energyt1);
    
    xlswrite('tot_Comp_Energy_PMR1.5.xlsx',Opt_Comp_Energyt1);
    csvwrite('tot_Comp_Energy_PMR1.5.dat',Opt_Comp_Energyt1);
    
    
xlswrite('time_T_T_tperQ.xlsx',time_meanWL_M);
csvwrite('time_T_T_tperQ.dat',time_meanWL_M);

%%
%%%%%%% simulation plotsfigure(1)
plot([1:1:N],f_opt_wokloads(:,2),'--+',[1:1:N],f_opt_wokloads(:,M),'--*');
xlabel('Workloads');
ylabel('optimum frequency for each VM');
legend('f-opt for VM=2','f-opt for VM=Last');
grid on

figure(2)
plot([1:1:M],f_opt_wokloads(1,:),'--+',[1:1:M],f_opt_wokloads(N,:),'--*');
xlabel('VMs');
ylabel('optimum frequency for each VM');
legend('f-opt:first workload','f-opt: last workload');
grid on

figure(3)
plot([1:1:N],R_opt_wokloads(:,2),'--+',[1:1:N],R_opt_wokloads(:,M),'--*');
xlabel('Workloads');
ylabel('optimum channel rate for each VM');
legend('R\_* for VM=2','R\_* for VM=Last');
grid on

figure(4)
plot([1:1:N],f_opt_wokloads(:,2),'--+',[1:1:N],f_opt_wokloads(:,M),'--*');
xlabel('Workloads');
ylabel('optimum frequency for each Workload');
legend('f-opt for VM=2','f-opt for VM=Last');
grid on

figure(5)
plot([1:1:N],Opt_Comp_Energy(:,M),'--+',[1:1:N],Opt_reconfig_Energy(:,M),'--o',[1:1:N],Opt_Comm_Energy(:,M),'--*')
xlabel('Workloads');
ylabel('optimum computation/reconfiguration/communication costs for each Workload');
legend('Computation Cost for M=last','reconfiguration Cost for M=last','Communication Cost for M=last');
grid on

figure(6)
plot([1:1:M],sum(total_energy(:,M))/N,'--+')
xlabel('VMs');
ylabel('Average total consumed energy for each VMs');
legend('Avarage total energy consumed');
grid on

