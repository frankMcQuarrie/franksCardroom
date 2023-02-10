a=5; % horizontal radius
b=10; % vertical radius
x0=0; % x0,y0 ellipse centre coordinates
y0=0;
t=-pi:0.01:pi;
x=x0+a*cos(t);
y=y0+b*sin(t);
figure()
plot(x,y)
axis equal
hold on
scatter(x(471),y(471),'r','filled')
title('No Rotation')
% 
% %Plot the same ellipses, rotating by each calculated orientation angle.

radRot = deg2rad(-90);


[X Y] = rot(x,y,radRot)

figure()
plot(X,Y)
axis equal
hold on
scatter(X(471),Y(471),'r','filled')

for COUNT = 1:length(AnglesDeg) 
    [X Y] = rot(x,y,-AnglesDeg(COUNT))
    nameit = sprintf('Pairing Angle %d',COUNT);
    figure()
    plot(X,Y)
    axis equal
    title(nameit)
end