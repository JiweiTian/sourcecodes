function L_M_Q_N=OED(Q,N)
% clear;clc
% %Ŀ��
% Q=3;%������level
% N=5;%ά�ȣ����������أ�factor
J=1;
q=Q;
while ((q^J-1)/(q-1)<N)
    J=J+1;
end
n=(q^J-1)/(q-1);
q=Q;
j=J;
A=oa_permut(q,n,j);
L_M_Q_N=A(:,1:N);