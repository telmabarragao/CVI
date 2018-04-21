top = [ 50 55 60 65 70 75 80
        100 100 100 100 100 100 100];
L_side = [ 50 50
            105 110];
 R_side = [ 80 80
            105 110];
 troncoL = [ 60 60 60 60 60 60
            110 115 120 125 130 135];
 troncoR = [ 70 70 70 70 70 70
             110 115 120 125 130 135];
                                
SHAPE = 50 + [top R_side troncoR troncoL L_side];
                

plot(SHAPE(1,:),SHAPE(2,:),'r.');

pause;

T = [1 0 0
    0 1 0
    30 30 1];

Translacao = [SHAPE' ones(length(SHAPE),1)] * T;
plot(Translacao(:,1),Translacao(:,2),'g.');

teta(10*pi/180);

R = [ cos(teta) sin(teta) 0
    -sin(teta) cos(teta) 0
    0   0   1];

Rotacao = [SHAPE' ones(length(SHAPE),1)] * S;
plot(Scaling(:,1),Scaling(:,2), 'b.');

%sv = 0.6;
%sh = 0.8;
