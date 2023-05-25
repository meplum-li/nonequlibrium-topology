function Sample = parameter()
Sample.mu=0.6;%进入哈密顿量中的化学势
Sample.h = 0.;%zeeman场
Sample.delta = 0.3;%超导配对势
Sample.alphaR = 0.;%自旋轨道耦合的强度
Sample.periodicity = 1;%1D case是否周期性边界条件
Sample.eta = 1E-2;%小量，在接点击的情况下，该参数不应该参加计算；仅仅在孤立中心区起作用，为了收敛

%%%电极化学势的设置
Sample.A_mu_exU = 0.6;%上电极的化学势，absolute value
Sample.A_mu_exD = 0.6;%下电极的化学势
Sample.A_mu_exBP = 0.6;%虚拟导线的化学势
Sample.gammaU = 2*pi*1E-4;%上导线的gamma
Sample.gammaD = 2*pi*1E-4;%上导线的gamma
% gammaSC = 2*pi*1E-1;%下导线的gamma
Sample.gammaBP = 2*pi*1E-4*0;%虚拟导线的gamma
end