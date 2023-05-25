%%% 上下电极接上中心区，平衡的情况下，考虑能隙方程，来确定吸引势的大小
%%% 采取周期性边界条件更接近理论值
clearvars
tic
Sample = parameter();
delta = Sample.delta;
% eta = Sample.eta;
int=integral(@(EF) Gless21(EF),-4,0.,"ArrayValued",true,'RelTol',1e-3,'AbsTol',1e-13);
Ui = delta./(-int/(2*pi*1i))
toc
% tic
% EF = linspace(-4,4,200);
% GPN = zeros(30,length(EF));
% for ii = 1 : length(EF)
%     GPN(:,ii) = Gless21(EF(ii));
% end
% %%
% figure
% plot(EF,abs(GPN(3,:)), 'k',LineWidth=2)
% % ylim([0,1E-2])
% xlim([EF(1),EF(end)])
% toc
%%
function result = Gless21(EF)
Sample = parameter();
mu0=Sample.mu;
h = Sample.h;
delta = Sample.delta;
alphaR = Sample.alphaR;
periodcity = Sample.periodicity;
eta = Sample.eta;
sigma0 = eye(2);
sigmaX=[0,1;1,0];
sigmaY=[0,-1i;1i,0];
sigmaZ=[1,0;0,-1];
T_0 = (2-mu0)*kron(sigmaZ, eye(2)) + h*kron(sigmaZ,sigmaZ) - delta* kron(sigmaY, sigmaY);
T_x = -1*kron(sigmaZ, eye(2)) + alphaR/(2i)*kron(sigmaZ, sigmaY);

N_cen = 30;%中心区长度
%%%电极设置
%都是金属
A_mu_exU = Sample.A_mu_exU;%absolute value
A_mu_exD = Sample.A_mu_exD;
mu_exU = A_mu_exU - mu0;%relative value
mu_exD = A_mu_exD - mu0;
gammaU = Sample.gammaU;%上导线的gamma
gammaD = Sample.gammaD;%上导线的gamma
%wide-band limit of real leads
SigmaU = kron(speye(N_cen), -1i*gammaU/2*speye(4));%左导线耦合到中心区的自能
SigmaD = kron(speye(N_cen), -1i*gammaD/2*speye(4));%导线自能
GammaU= 1i*(SigmaU-SigmaU');%左导线的线宽函数
GammaD = 1i*(SigmaD-SigmaD');%右导线的线宽函数

H = kron(speye(N_cen), T_0) + kron(diag(ones(N_cen-1,1), 1), T_x) + kron(diag(ones(N_cen-1,1), -1), T_x');
if periodcity == 1
    H = H + kron( diag(1, N_cen-1), T_x ) + kron( diag(1, -N_cen+1), T_x' );
end
GR = inv(eye(4*N_cen)*(EF) - H - SigmaU - SigmaD);
SigmaUless = 1i*repmat([EF<=mu_exU; EF<=mu_exU;EF<=-mu_exU; EF<=-mu_exU], N_cen, 1).*GammaU;
SigmaDless = 1i*repmat([EF<=mu_exD; EF<=mu_exD;EF<=-mu_exD; EF<=-mu_exD], N_cen, 1).*GammaD;
Sigmaless= SigmaUless + SigmaDless;
Gless = GR * Sigmaless * GR';
% result=diag(kron(eye(N_cen),[0,0,0,1])*Gless);
result=diag( kron(eye(N_cen),[0,0,0,1])*Gless*kron(eye(N_cen),[1;0;0;0]) );
end