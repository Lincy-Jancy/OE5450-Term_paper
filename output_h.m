function output_h
    a=readmatrix('eta 1s.txt');
    b=readmatrix('eta 3s.txt');
    c=readmatrix('eta 5s.txt');
    d=readmatrix('eta 7s.txt');
%     e=readmatrix('eta4.0s.txt');
%     f=readmatrix('eta5.0s.txt');
%     g=readmatrix('eta6.0s.txt');
%     d=readmatrix('eta7.0s.txt');
    %plot(a)
    %h=surf(a,'EdgeColor','interp');
    %colormap('parula');
    %title(['Flow at 1s after dam break']);
    xlabel('X');
    ylabel('Y');
    axis([0, 41, 0, 41]);
    %plot(b)
    %h=surf(b,'EdgeColor','interp');
    %title(['Flow at 3s after dam break']);
     xlabel('X');
    ylabel('Y');
    axis([0, 41, 0, 41]);
   %plot(c)
    %h=surf(c,'EdgeColor','interp');
    %title(['Flow at 5s after dam break']);
     xlabel('X');
    ylabel('Y');
    axis([0, 41, 0, 41]);
    plot(d)
    h=surf(d,'EdgeColor','interp');
    title(['Flow at 7s after dam break']);
     xlabel('X');
    ylabel('Y');
    axis([0, 41, 0, 41]);
%     subplot(3,2,5)
%     h=surf(f,'EdgeColor','interp');
%     subplot(3,2,6)
%     h=surf(g,'EdgeColor','interp');
    
%     subplot(2,2,2)
%     j=surf(b,'EdgeColor','interp');
%    
%     subplot(2,2,3)
%     i=surf(c,'EdgeColor','interp');
    
end