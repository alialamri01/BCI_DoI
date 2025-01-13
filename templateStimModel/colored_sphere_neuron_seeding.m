clear all
clear all
close all

a=400; 
b=400; 

depth1=(27*2000)/100; 
depth2=(12*2000)/100; 
depth3=(19*2000)/100; 
depth4=(35*2000)/100; 
depth5=(7*2000)/100; 

v1=(a/1000)*(b/1000)*(depth1/1000);
v2=(a/1000)*(b/1000)*(depth2/1000);
v3=(a/1000)*(b/1000)*(depth3/1000);
v4=(a/1000)*(b/1000)*(depth4/1000);
v5=(a/1000)*(b/1000)*(depth5/1000);

nn_1=(v1*20000)+2;
nn_2=(v2*20000)+2;
nn_3=(v3*20000)+4;
nn_4=v4*20000;
nn_5=(v5*20000)+2;



tot_cell_count=[(nn_5/5)*ones(1,5) (nn_4/5)*ones(1,5) (nn_3/5)*ones(1,5) (nn_2/5)*ones(1,5) (nn_1/5)*ones(1,5)];

n1 = bsxfun(@times, [a, b, depth1], rand(round(nn_1),3) );
n2 = bsxfun(@times, [a, b, depth2], rand(round(nn_2),3) );
n3 = bsxfun(@times, [a, b, depth3], rand(round(nn_3),3) );
n4 = bsxfun(@times, [a, b, depth4], rand(round(nn_4),3) );
n5 = bsxfun(@times, [a, b, depth5], rand(round(nn_5),3) );

% 3555
% 1535
% 2480
% 4605
% 905

x1=n1(:,1);
z1=n1(:,2);
y1=n1(:,3);

x2=n2(:,1);
z2=n2(:,2);
y2=540+n2(:,3);

x3=n3(:,1);
z3=n3(:,2);
y3=540+240+n3(:,3);

x4=n4(:,1);
z4=n4(:,2);
y4=540+240+380+n4(:,3);

x5=n5(:,1);
z5=n5(:,2);
y5=540+240+380+700+n5(:,3);

realx=fliplr([x1' x2' x3' x4' x5']);
realy=fliplr([y1' y2' y3' y4' y5']);
realz=fliplr([z1' z2' z3' z4' z5']);

rot_ran=2*pi*rand(1,length(realx));


figure(1)
plot3(x1, z1, y1, '.b');
hold on
plot3(x2, z2, y2, '.g');
plot3(x3, z3, y3, '.r');
plot3(x4, z4, y4, '.c');
plot3(x5, z5, y5, '.m');
hold off
view(3)
axis equal