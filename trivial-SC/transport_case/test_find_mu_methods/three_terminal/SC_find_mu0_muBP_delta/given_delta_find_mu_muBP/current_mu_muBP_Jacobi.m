function [F, J] = current_mu_muBP_Jacobi(x)
mu0 = x(1);
mu_BP = x(2);%absolute value of mu_BP, not a relative one
Sample = parameter();
current_RelTol = Sample.current.RelTol;
current_AbsTol = Sample.current.AbsTol;
% int=integral(@(EF) i_E(Sample, EF, mu0, mu_BP),-inf,inf,"ArrayValued",true,'RelTol',current_RelTol,'AbsTol',current_AbsTol);
ub = max(abs(Sample.A_mu_exU-mu0),abs(Sample.A_mu_exD-mu0)); 
int=integral(@(EF) i_E(Sample, EF, mu0, mu_BP),-ub,ub,"ArrayValued",true,'RelTol',current_RelTol,'AbsTol',current_AbsTol);
fprintf('%6.2E  %6.2E  %6.2E\n',int(1:3))
% display(int(1:3))
F(1)=sum(int(1:3));
F(2)=int(3);
%%
TT_Ue = transmission(Sample, Sample.A_mu_exU-mu0 , mu0, mu_BP);
TT_Uh = transmission(Sample, -Sample.A_mu_exU+mu0 , mu0, mu_BP);
TT_De = transmission(Sample, Sample.A_mu_exD-mu0 , mu0,mu_BP);
TT_Dh = transmission(Sample, -Sample.A_mu_exD+mu0 , mu0,mu_BP);
TT_BPe = transmission(Sample, mu_BP-mu0 , mu0, mu_BP);
TT_BPh = transmission(Sample, -mu_BP+mu0 , mu0, mu_BP);
% J_iU2 = sum( (-TT_Ue(1,:).'-[-TT_Ue(1,1);TT_Uh(1,2);-TT_De(1,3);TT_Dh(1,4)])-(TT_Uh(2,:).'-[-TT_Ue(2,1);TT_Uh(2,2);-TT_De(2,3);TT_Dh(2,4)]) );
% J_iD2 = sum( (-TT_De(3,:).'-[-TT_Ue(3,1);TT_Uh(3,2);-TT_De(3,3);TT_Dh(3,4)])-(TT_Dh(4,:).'-[-TT_Ue(4,1);TT_Uh(4,2);-TT_De(4,3);TT_Dh(4,4)]) );
% J=J1+J_iU2+J_iD2;
Dmu2_1 = -sum(sum( [TT_Ue(1,:);TT_Uh(2,:);TT_De(3,:);TT_Dh(4,:);TT_BPe(5,:);TT_BPh(6,:)] ));
Dmu2_2 = sum(sum( kron(ones(3),[1,-1;-1,1]).*[TT_Ue(:,1),TT_Uh(:,2),TT_De(:,3),TT_Dh(:,4),TT_BPe(:,5),TT_BPh(:,6)] ));
J(1,1) = sum(int(4:6))+Dmu2_1+Dmu2_2;%DF(1)/Dmu0
J(1,2) = sum([TT_BPe(5,:),TT_BPh(6,:)])-sum(sum( kron(ones(3,1),[1,-1;-1,1]).*[TT_BPe(:,5),TT_BPh(:,6)] ));%DF(1)/Dmu_BP
J(2,1) = int(6) -sum( [TT_BPe(5,:),TT_BPh(6,:)] ) + sum(sum( kron(ones(1,3),[1,-1;-1,1]).*[TT_Ue([5,6],1),TT_Uh([5,6],2),TT_De([5,6],3),TT_Dh([5,6],4),TT_BPe([5,6],5),TT_BPh([5,6],6)] ));%DF(2)/Dmu0
J(2,2) = sum([TT_BPe(5,:),TT_BPh(6,:)])-sum(sum( [1,-1;-1,1].*[TT_BPe([5,6],5),TT_BPh([5,6],6)] ));
%%
    function [i_vec] = i_E(Sample, EF, mu0, A_mu_exBP)
        h = Sample.h;
        delta = Sample.delta;
        alphaR = Sample.alphaR;
        periodcity = Sample.periodicity;
        sigma0 = eye(2);
        sigmaX=[0,1;1,0];
        sigmaY=[0,-1i;1i,0];
        sigmaZ=[1,0;0,-1];
        T_0 = (2-mu0)*kron(sigmaZ, eye(2)) + h*kron(sigmaZ,sigmaZ) - kron( real(delta)*sigmaY+imag(delta)*sigmaX,sigmaY );
        T_x = -1*kron(sigmaZ, eye(2)) + alphaR/(2i)*kron(sigmaZ, sigmaY);
        %% transport
        N_cen = 30;
        %%%电极设置
        A_mu_exU = Sample.A_mu_exU;%absolute value
        A_mu_exD = Sample.A_mu_exD;
%         A_mu_exBP = Sample.A_mu_exBP;
        mu_exU = A_mu_exU - mu0;%relative value
        mu_exD = A_mu_exD - mu0;
        mu_exBP = A_mu_exBP - mu0;
        gammaU = Sample.gammaU;%上导线的gamma
        gammaD = Sample.gammaD;%上导线的gamma
        gammaBP = Sample.gammaBP;

%         TT = zeros(6,6);%不同能量对应的透射系数


        %%wide-band limit of real leads
        SigmaU = kron(speye(N_cen), -1i*gammaU/2*speye(4));%左导线耦合到中心区的自能
        SigmaD = kron(speye(N_cen), -1i*gammaD/2*speye(4));%导线自能
        SigmaBP = kron(speye(N_cen), -1i*gammaBP/2*speye(4));
        GammaU = 1i*(SigmaU-SigmaU');%左导线的线宽函数
        GammaD = 1i*(SigmaD-SigmaD');%右导线的线宽函数
        GammaBP = 1i*(SigmaBP - SigmaBP');

        H = kron(speye(N_cen), T_0) + kron(diag(ones(N_cen-1,1), 1), T_x) + kron(diag(ones(N_cen-1,1), -1), T_x');
        if periodcity == 1
            H = H + kron( diag(1, N_cen-1), T_x ) + kron( diag(1, -N_cen+1), T_x' );
        end
        H_partial_mu =kron( speye(N_cen), -kron(sigmaZ, eye(2)) );
        
        grlead_lead= (eye(4*N_cen)*EF - H-SigmaU - SigmaD - SigmaBP)\eye(4*N_cen);
        GR_partial_mu = grlead_lead * H_partial_mu * grlead_lead;
        %%% 计算transmission 矩阵
        GAMMA_T = [GammaU; GammaD; GammaBP];%for calculating transmission
        temT = GAMMA_T*grlead_lead*[GammaU, GammaD, GammaBP].*conj( kron(ones(3),grlead_lead) );%稀疏矩阵的写法提速10倍，非稀疏的就不用写成稀疏矩阵了
        temT_partial_mu = GAMMA_T*GR_partial_mu*[GammaU, GammaD, GammaBP].*conj( kron(ones(3),grlead_lead) );%稀疏矩阵的写法提速10倍，非稀疏的就不用写成稀疏矩阵了
        %         temT_partial_mu = temT_partial_mu+temT_partial_mu';
        % %保留自旋自由度
        % sumM=blkdiag(eye(8));
        % T = real(sumM*temT*sumM');
        %自旋缩并
        sumM=kron(speye(2*3*N_cen), ones(1,2));
        temTT = real(sumM*temT*sumM');
        temTT_partial_mu = real(sumM*temT_partial_mu*sumM');
        %缩并电极内部指标，只剩下up、down、BP以及各自的电子空穴指标
        sumM=kron(  speye(3), kron( ones(1, N_cen), speye(2) )  );
        TT= real(sumM*temTT*sumM');
        TT_partial_mu = 2*real(sumM*temTT_partial_mu*sumM');
        fUe = (EF<mu_exU);
        fUh = (EF<-mu_exU);
        fDe = (EF<mu_exD);
        fDh = (EF<-mu_exD);
        fBPe = (EF<mu_exBP);
        fBPh = (EF<-mu_exBP);
        i_vec(1) = sum( (fUe - [fUe,fUh, fDe, fDh, fBPe, fBPh]) *TT(:,1) ) ...
            -sum( (fUh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT(:,2) );%U
        i_vec(2) = sum( (fDe - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT(:,3) ) ...
            -sum( (fDh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT(:,4) );%D
        i_vec(3) = sum( (fBPe - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT(:,5) ) ...
            -sum( (fBPh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT(:,6) );%BP
        i_vec(4) = sum( (fUe - [fUe,fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,1) ) ...
            -sum( (fUh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,2) );
        i_vec(5) = sum( (fDe - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,3) ) ...
            -sum( (fDh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,4) );
        i_vec(6) = sum( (fBPe - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,5) ) ...
            -sum( (fBPh - [fUe, fUh, fDe, fDh, fBPe, fBPh]) *TT_partial_mu(:,6) );%BP
    end
%%
    function [trans] = transmission(Sample, EF, mu0, A_mu_exBP)
        h = Sample.h;
        delta = Sample.delta;
        alphaR = Sample.alphaR;
        periodcity = Sample.periodicity;
        sigma0 = eye(2);
        sigmaX=[0,1;1,0];
        sigmaY=[0,-1i;1i,0];
        sigmaZ=[1,0;0,-1];
        T_0 = (2-mu0)*kron(sigmaZ, eye(2)) + h*kron(sigmaZ,sigmaZ) - kron( real(delta)*sigmaY+imag(delta)*sigmaX,sigmaY );
        T_x = -1*kron(sigmaZ, eye(2)) + alphaR/(2i)*kron(sigmaZ, sigmaY);
        %% transport
        N_cen = 30;
        %%%电极设置
        A_mu_exU = Sample.A_mu_exU;%absolute value
        A_mu_exD = Sample.A_mu_exD;
%         A_mu_exBP = Sample.A_mu_exBP;
        mu_exU = A_mu_exU - mu0;%relative value
        mu_exD = A_mu_exD - mu0;
        mu_exBP = A_mu_exBP - mu0;
        gammaU = Sample.gammaU;%上导线的gamma
        gammaD = Sample.gammaD;%上导线的gamma
        gammaBP = Sample.gammaBP;

%         TT = zeros(6,6);%不同能量对应的透射系数


        %%wide-band limit of real leads
        SigmaU = kron(speye(N_cen), -1i*gammaU/2*speye(4));%左导线耦合到中心区的自能
        SigmaD = kron(speye(N_cen), -1i*gammaD/2*speye(4));%导线自能
        SigmaBP = kron(speye(N_cen), -1i*gammaBP/2*speye(4));
        GammaU = 1i*(SigmaU-SigmaU');%左导线的线宽函数
        GammaD = 1i*(SigmaD-SigmaD');%右导线的线宽函数
        GammaBP = 1i*(SigmaBP - SigmaBP');

        H = kron(speye(N_cen), T_0) + kron(diag(ones(N_cen-1,1), 1), T_x) + kron(diag(ones(N_cen-1,1), -1), T_x');
        if periodcity == 1
            H = H + kron( diag(1, N_cen-1), T_x ) + kron( diag(1, -N_cen+1), T_x' );
        end
        
        grlead_lead= inv(eye(4*N_cen)*EF - H-SigmaU - SigmaD - SigmaBP);
        %%% 计算transmission 矩阵
        GAMMA_T = [GammaU; GammaD; GammaBP];%for calculating transmission
        temT = GAMMA_T*grlead_lead*[GammaU, GammaD, GammaBP].*conj( kron(ones(3),grlead_lead) );%稀疏矩阵的写法提速10倍，非稀疏的就不用写成稀疏矩阵了
        % %保留自旋自由度
        % sumM=blkdiag(eye(8));
        % T = real(sumM*temT*sumM');
        %自旋缩并
        sumM=kron(speye(2*3*N_cen), ones(1,2));
        temTT = real(sumM*temT*sumM');
        %缩并电极内部指标，只剩下up、down、BP以及各自的电子空穴指标
        sumM=kron(  speye(3), kron( ones(1, N_cen), speye(2) )  );
        trans= real(sumM*temTT*sumM');
        end
end