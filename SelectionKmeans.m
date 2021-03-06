function [a_TX_select,a_RX_select, H_selected] = SelectionKmeans(Num_users,a_TX,a_RX,Num_paths,H)

%% find the first beam with largest channel gain
alpha_u = zeros(Num_users_all,Num_paths);
for u = 1:Num_users_all
    H_u(:,:) = H(u,:,:);
    for p = 1:Num_paths
        alpha_u(u,p) = abs(a_RX(:,u,p)'*H_u*a_TX(:,u,p));
    end
end
[max_u_all, max_u] = max(alpha_u,[],1);
[~, max_p] = max(max_u_all);
max_user = max_u(max_p);
%% The first user with largest channel gain is selected
a_TX_select(:,1) = a_TX(:,max_user,max_p);
a_RX_select(:,1) = a_RX(:,max_user,max_p);
H_selected(1,:,:) = H(max_user,:,:);

new_add = 1;
while new_add<Num_users
    new_add= new_add+1;
    a_TX(:,max_user,:) = [];
    H(max_user,:,:) =[]; 
    a_RX(:,max_user,:)=[];
    sinr = zeros(Num_users_all,Num_paths);
    for u_try= 1:(Num_users_all-new_add+1)
        for path = 1:Num_paths
            a_TX_select(:,new_add) = a_TX(:,u_try,path);
            a_RX_select(:,new_add) = a_RX(:,u_try,path);
            H_selected(new_add,:,:) = H(u_try,:,:);
            for user = 1:size(a_TX_select,2)
                H_u(:,:) = H_selected(user,:,:);
                user_int = [];
                for int = 1:size(a_TX_select,2)
                    if int ~=user
                        user_int = [user_int int];
                    end
                end
                sinr(u_try,path) =sinr(u_try,path) + (abs(a_RX_select(:,user)'*H_u*a_TX_select(:,user))^2)/sum(abs(a_RX_select(:,user)'*H_u*a_TX_select(:,user_int)).^2);
            end
        end
    end

    [max_user,max_p] = find(sinr == max(max(sinr)));
    a_TX_select(:,new_add) = a_TX(:,max_user,max_p);
    a_RX_select(:,new_add) = a_RX(:,max_user,max_p);
    H_selected(new_add,:,:) = H(max_user,:,:);
    
end


end