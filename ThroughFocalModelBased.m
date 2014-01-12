%Final year project - Through Focal combination section
%Model based 2.5D deconvolution for extended depth of field in brightfield
%microscopy - Francois Aguet


%Load image stack

load('camera_00/imdata.mat');
images = [];
stackheightint = 75;
StackNum = 16;
for i = 1:StackNum
    imstring = strcat('phoenix3/mars',num2str(i));%camera_00/sim_',num2str(i));
    imstring = strcat(imstring,'.png');
    images = [images Image((i-1)*stackheightint,double(imread(imstring)))];%(StackNum-1)*stackheightint - (i-1)*stackheightint
end

%PSF function creation

Xpixel = 256;
Ypixel = 512;

PixelSize = 4;
ro = 2;
zstart = 0;
zend = StackNum*stackheightint;
N0 = 0.5;
N1 = 0.5;

Normalise = (1/(2*pi*ro^2))*((1+2*exp(-1/2*ro^2)*(1+exp(-3/2*ro^2)))^2);

hofz = zeros(Ypixel,Xpixel,StackNum);
hx = [PixelSize*Xpixel/2:-PixelSize:0 PixelSize:PixelSize:PixelSize*(Xpixel-1)/2];
hy = [PixelSize*Ypixel/2:-PixelSize:0 PixelSize:PixelSize:PixelSize*(Ypixel-1)/2];
hz = [0:stackheightint:(StackNum-1)*stackheightint];

for i = 1:Xpixel
    for j = 1:Ypixel
        for k = 1:StackNum
            hofz(j,i,k) = (((hx(i)^2+hy(j)^2)*N1/(2*pi*(N0+N1*hz(k)))^5)-(N1/(pi*(N0+N1*hz(k)))^3))*exp(-1*((hx(i)^2)+(hy(j)^2))/(2*(N0+N1*hz(k))^2));
        end
    end
end

hfull = zeros(Ypixel,Xpixel,StackNum);

for i = 1:Xpixel
    for j = 1:Ypixel
        for k = 1:StackNum
            hfull(j,i,k) = (1/(2*pi*(N0+N1*hz(k)))^2)*exp(-1*((hx(i)^2)+(hy(j)^2))/(2*(N0+N1*hz(k))^2));
        end
    end
end

hfull = hfull/Normalise;
hofz = hofz/Normalise;
h=[];
h = (1./(2*pi*(N0+N1.*hz).^2));

h = h/Normalise;

h = ones(StackNum);
%Texture optimisation

p = zeros(Ypixel,Xpixel);
f = zeros(Ypixel,Xpixel);

numerator = zeros(Ypixel,Xpixel);
denominator = zeros(Ypixel,Xpixel);

for iter = 1:10;
for i = 1:Xpixel
    for j = 1:Ypixel
        for k = 1:StackNum
            numerator(j,i) = numerator(j,i) + images(k).Im(j,i)*h(k-round(p(j,i)));
            denominator(j,i) = denominator(j,i) + h(k-round(p(j,i)))^2;
        end
    end
end

f = numerator./denominator;

%Topology optimisation

alpha = 1;

sbar = zeros(Ypixel,Xpixel,StackNum);

for i = 1:StackNum
    sbar(:,:,i) = conv2(f,h(i));
end
e = zeros(Ypixel,Xpixel,StackNum);


for k = 1:StackNum
    e(:,:,k) = images(k).Im - sbar(:,:,k);
end

for k = 1:StackNum
    dJbydp = convn(e(:,:,k),h(k));
end

dJbydp = f.*dJbydp;

for i = 1:Xpixel
    for j = 1:Ypixel
        p(j,i) = p(j,i) - alpha*dJbydp(j,i);
    end
end

end

mesh(p',f')
colormap(gray)