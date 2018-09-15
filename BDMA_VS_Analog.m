%%%%%%%%%%----- Performance of Adaptive Channel Estimation of MmWave Channels-----%%%%%%%
% Author: Niu Guanchong
% Date: 2018/08/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes
% 
%--------------------------------------------------------------------------
clear;clc;
% ----------------------------- System Parameters -------------------------
for Num_users=20 % Number of users

for TX_ant=128 %Number of UPA TX antennas
TX_ant_w=TX_ant; % width
TX_ant_h=1; % hieght 
ind_TX_w=reshape(repmat([0:1:TX_ant_w-1],TX_ant_h,1),1,TX_ant_w*TX_ant_h);
ind_TX_h=repmat([0:1:TX_ant_h-1],1,TX_ant_w);

RX_ant=16; %Number of UPA RX antennas
RX_ant_w=16; % width 
RX_ant_h=1; % hieght
ind_RX_w=reshape(repmat([0:1:RX_ant_w-1],RX_ant_h,1),1,RX_ant_w*RX_ant_h);
ind_RX_h=repmat([0:1:RX_ant_h-1],1,RX_ant_w);
k_cluster = 5;
% ----------------------------- Channel Parameters ------------------------
for Num_paths=2 %Number of channel paths

% ----------------------------- Simulation Parameters ---------------------
SNR_dB_range=-20:3:30;  % SNR in dB
Rate_SU=zeros(1,length(SNR_dB_range)); % Will carry the single-user MIMO rate (without interference)
Rate_LB=zeros(1,length(SNR_dB_range));% Will carry the lower bound values
Rate_BS=zeros(1,length(SNR_dB_range));% Will carry the rate with analog-only beamsteering
Rate_HP=zeros(1,length(SNR_dB_range)); % Will carry the rate of the proposed algorithm (with analog 
% and zero-forcing digital precoding)
Rate_BS_BDMA = zeros(1,length(SNR_dB_range));
Rate_HP_cl = zeros(1,length(SNR_dB_range));
Rate_HP_fzf = zeros(1,length(SNR_dB_range));

ITER=500; % Number of iterations
    
% --------------- Simulation starts ---------------------------------------
for iter=1:1:ITER
    % Generate user channels 
    [H,a_TX,a_RX]=ULAMulPath(Num_users,TX_ant_w,RX_ant_w,Num_paths); 
    % H is a 3-dimensional matrix, with Num_users,RX_ant,TX_ant dimensions
    [a_TX_select, a_RX_select, a_TX_select_inf, a_RX_select_inf] = SelectBestBeam(Num_users,a_TX,a_RX,Num_paths,H);
    % Stage 1 of the proposed algorithm (Analog precoding)
    Frf=zeros(TX_ant,Num_users); % BS RF precoders 
    Wrf=zeros(RX_ant,Num_users); % MS RF precoders 
    
    for u=1:1:Num_users
        Frf(:,u)=a_TX(:,u,1);
        Wrf(:,u)=a_RX(:,u,1);
    end   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Frf_fzf=zeros(TX_ant,Num_users); % BS RF precoders 
    Wrf_fzf=zeros(RX_ant,Num_users); % MS RF precoders 
        for u=1:1:Num_users
            Frf_fzf(:,u)=a_TX_select(:,u);
            Wrf_fzf(:,u)=a_RX_select(:,u);
        end      
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     % Constructin the effective channels
     He_fzf = zeros(Num_users, Num_users);
    for u=1:1:Num_users
        Channel=zeros(RX_ant,TX_ant);
        Channel(:,:)= H(u,:,:);
        He_fzf(u,:)=Wrf_fzf(:,u)'*Channel*Frf_fzf ;    % Effective channels
    end
 
    % Baseband zero-forcing precoding
    Fbb_fzf=He_fzf'*(He_fzf*He_fzf')^(-1);   
    for u=1:1:Num_users % Normalization of the hybrid precoders
        Fbb_fzf(:,u)=Fbb_fzf(:,u)/sqrt((Frf_fzf*Fbb_fzf(:,u))'*(Frf_fzf*Fbb_fzf(:,u)));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     [Wrf_cl, Frf_cl, H_cl]= greedySelection(a_TX_select, a_RX_select,k_cluster,H);
        % Constructin the effective channels
        He_cl = zeros(Num_users,Num_users);
    for u=1:1:Num_users
        Channel_cl=zeros(RX_ant,TX_ant);
        Channel_cl(:,:)= H_cl(u,:,:);
        He_cl(u,:)=Wrf_cl(:,u)'*Channel_cl*Frf_cl ;    % Effective channels
    end
    
    % Baseband zero-forcing precoding
%   Fbb_cl = eye(Num_users);
    Fbb_cl=He_cl'*(He_cl*He_cl')^(-1);   
    for u=1:1:Num_users % Normalization of the hybrid precoders
        Fbb_cl(:,u)=Fbb_cl(:,u)/sqrt((Frf_cl*Fbb_cl(:,u))'*(Frf_cl*Fbb_cl(:,u)));
    end
    
%     for col = 1:Num_users
%         for row = 1:Num_users
%             if abs(row-col)>=Num_users/k_cluster
%                 Fbb_cl(col,row) = 0;
%             end
%         end
%     end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Frf_BDMA=zeros(TX_ant,Num_users); % BS RF precoders 
    Wrf_BDMA=zeros(RX_ant,Num_users); % MS RF precoders 
        for u=1:1:Num_users
            Frf_BDMA(:,u)=a_TX_select(:,u);
            Wrf_BDMA(:,u)=a_RX_select(:,u);
        end      
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     % Constructin the effective channels
     He_BDMA = zeros(Num_users, Num_users);
    for u=1:1:Num_users
        Channel=zeros(RX_ant,TX_ant);
        Channel(:,:)= H(u,:,:);
        He_BDMA(u,:)=Wrf_BDMA(:,u)'*Channel*Frf_BDMA ;    % Effective channels
    end
 
    % Baseband zero-forcing precoding
    Fbb_BDMA=He_BDMA'*(He_BDMA*He_BDMA')^(-1);   
    for u=1:1:Num_users % Normalization of the hybrid precoders
        Fbb_BDMA(:,u)=Fbb_BDMA(:,u)/sqrt((Frf_BDMA*Fbb_BDMA(:,u))'*(Frf_BDMA*Fbb_BDMA(:,u)));
    end
    
%     for col = 1:Num_users
%         for row = 1:Num_users
%             if abs(row-col)>=(Num_users/k_cluster)
%             Fbb_BDMA(col,row) = 0;
%             end
%         end
%     end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % For the lower bound 
        [Us Ss Vs]=svd(Frf);
        s_min=(min(diag(Ss)))^2;
        s_max=(max(diag(Ss)))^2;
        G_factor=4/(s_max/s_min+s_min/s_max+2);  
      
    % Spectral efficiency calculations
    count=0;
    for SNR_dB=SNR_dB_range
        count=count+1;
        SNR=10^(.1*SNR_dB)/Num_users; % SNR value
              
        for u=1:1:Num_users
            Int_set=[]; % interference index
            for i=1:1:Num_users
                if(i~=u)
                    Int_set=[Int_set i]; 
                end
            end
            Channel=zeros(RX_ant,TX_ant);
            Channel(:,:)= H(u,:,:);
            [U_channel S_channel V_channel]=svd(Channel);
            Channel_cl(:,:) =H_cl(u,:,:);
            
            % Single-user rate
            Rate_SU(count)=Rate_SU(count)+log2(1+SNR*S_channel(1,1)^2)/(Num_users*ITER);
            
            % Analog-only beamforming
            SINR_BS=(SNR*(abs(Wrf(:,u)'*Channel*Frf(:,u)).^2))/(SNR*sum((abs(Wrf(:,u)'*Channel*Frf(:,Int_set)).^2))+1);
            Rate_BS(count)=Rate_BS(count)+log2(1+SINR_BS)/(Num_users*ITER);
          
            %%%%%%%%%%%%%%BDMA
            SINR_BS_BDMA=(SNR*(abs(Wrf_BDMA(:,u)'*Channel*Frf_BDMA(:,u)).^2))/(SNR*sum((abs(Wrf_BDMA(:,u)'*Channel*Frf_BDMA(:,Int_set)).^2))+1);
            Rate_BS_BDMA(count)=Rate_BS_BDMA(count)+log2(1+SINR_BS_BDMA)/(Num_users*ITER);
            
            
            % Derived lower bound
            Rate_LB(count)=Rate_LB(count)+log2(1+SNR*S_channel(1,1)^2*G_factor)/(Num_users*ITER);
             
            % Hybrid Precoding with block diagonal matrix
            SINR_BS_select=(SNR*(abs(He_BDMA(u,:)*Fbb_BDMA(:,u)).^2))/(SNR*sum((abs(Wrf_BDMA(:,u)'*Channel*Frf_BDMA*Fbb_BDMA(:,Int_set)).^2))+1);
            Rate_HP(count)=Rate_HP(count)+log2(1+SINR_BS_select)/(Num_users*ITER);
            
           % Hybrid Precoding with clustering
            SINR_BS_cl=(SNR*(abs(He_cl(u,:)*Fbb_cl(:,u)).^2))/(SNR*sum((abs(Wrf_cl(:,u)'*Channel_cl*Frf_cl*Fbb_cl(:,Int_set)).^2))+1);
            Rate_HP_cl(count)=Rate_HP_cl(count)+log2(1+SINR_BS_cl)/(Num_users*ITER);
            
            %Hybrid Precoding with fully zero-forcing
            intf(:,:)=a_TX_select_inf;
            intf_all = sum(abs(Wrf_fzf(:,u)'*Channel*intf*Fbb_fzf).^2);
            SINR_BS_fzf=(SNR*(abs(Wrf_fzf(:,u)'*Channel*Frf_fzf*Fbb_fzf(:,u)).^2))/(SNR*sum((abs(Wrf_fzf(:,u)'*Channel*Frf_fzf*Fbb_fzf(:,Int_set)).^2)+intf_all)+1);
            Rate_HP_fzf(count)=Rate_HP_fzf(count)+log2(1+SINR_BS_fzf)/(Num_users*ITER);
        end
    
        % Hybrid Precoding
        % Rate_HP(count)=Rate_HP(count)+log2(det(eye(Num_users)+SNR*(He_BDMA*(Fbb_BDMA*Fbb_BDMA')*He_BDMA')))/(Num_users*ITER);
       
    end % End of SNR loop
end % End of ITER loop

%Plotting the spectral efficiencies
  %   plot(SNR_dB_range,Rate_SU,'-v','LineWidth',1.5);
 %       hold on; plot(SNR_dB_range,Rate_HP,'LineWidth',1.5);
 %  hold on; plot(SNR_dB_range,Rate_HP,'-s','LineWidth',1.5);
% if Num_paths==1
%     hold on; plot(SNR_dB_range,Rate_LB,'--k','LineWidth',1.5);
%     hold on; plot(SNR_dB_range,Rate_BS,'-ro','LineWidth',1.5);
%     legend('Single-user (No Interference)','Proposed Hybrid Precoding','Lower Bound (Theorem 1)','Analog-only Beamsteering');
% else
%     hold on; plot(SNR_dB_range,Rate_BS,'-ro','LineWidth',1.5);
 %  hold on;  plot(SNR_dB_range,Rate_BS_BDMA,'LineWidth',1.5);
   
%     legend('Single-user (No Interference)','Proposed Hybrid Precoding','Analog-only Beamsteering','BDMA');    
% end
end
end
% hold on; plot(SNR_dB_range,Rate_HP_cl,'-','LineWidth',1.5);
% hold on;  plot(SNR_dB_range,Rate_HP_fzf,'--o','LineWidth',1.5);

% hold on;  plot(SNR_dB_range,Rate_HP,'--','LineWidth',1.5);
end
hold on;  plot(SNR_dB_range,Rate_SU,'-v','LineWidth',1.5);
plot(SNR_dB_range,Rate_BS_BDMA,'LineWidth',1.5);
hold on; plot(SNR_dB_range,Rate_BS,'-ro','LineWidth',1.5);
hold on; plot(SNR_dB_range,Rate_HP,'LineWidth',1.5);
hold on;  plot(SNR_dB_range,Rate_HP_fzf,'--o','LineWidth',1.5);
%hold on; plot(SNR_dB_range,Rate_HP_cl,'--b','LineWidth',1.5);
%legend('2','4','6','8','Single-user','Analog','Hybrid')
% legend('128BDMA','Single-user','Analog Only','Hybrid','Hybrid cluster')
% legend('5zf','5group','5','10zf','10group','10','15zf','15group','15','20zf','20group','20')
legend('signal user','BDMA','analog only', 'ZF','Delay Profile')
% legend('full ZF 5 users','Delay profile 5 users', 'full ZF 10 users','Delay profile 10 users', 'full ZF 15 users','Delay profile 15 users', 'full ZF 20 users','Delay profile 20 users')
% legend('5','5B','10','10B','15','15B','20','20B')
xlabel('SNR (dB)','FontSize',12);
ylabel('Spectral Efficiency (bps/ Hz)','FontSize',12);
grid;