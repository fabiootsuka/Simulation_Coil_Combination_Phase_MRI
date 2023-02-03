function [J] = J_loop(radius,I,ori)

%ori = [1 1 1];
    Nx = 2*radius + 1;
    Ny = 2*radius + 1;
    Nz = 2*radius + 1;
    
    x_ori = ori(1);
    y_ori = ori(2);
    z_ori = ori(3);
    
    pos_x = round(Nx/2);
    pos_y = round(Ny/2);
    pos_z = round(Nz/2);
    
    a = round(pos_x-abs(y_ori)*(radius));
    b = round(pos_x+abs(y_ori)*(radius));
    c = round(pos_y-abs(x_ori)*(radius));
    d = round(pos_y+abs(x_ori)*(radius));
    e = pos_z-radius;
    f = pos_z+radius;

    [az,el,rr]=cart2sph(x_ori,y_ori,z_ori);
    if abs(az) <= 1e-15
        az = 0;
    end

    J = zeros(Nx,Ny,Nz,3);
        for x = a:b
            for y = c:d
                for z = e:f
                    [azimuth,elevation,r] = cart2sph((x-pos_x),(y-pos_y),(z-pos_z));
                    %r = sqrt( (x-pos_x)^2 + (y-pos_y)^2 + (z-pos_z)^2 );
                    if r <= radius
                        if r > radius - 1
                        %if azimuth == abs(az) - angle || abs(az) + angle
                        %if abs(azimuth) == abs(az) || abs(azimuth) == abs(az) + 2*angle
                        %if azimuth == abs(az)+2*angle || azimuth == abs(az) || azimuth == abs(az)-2*angle
                            %if elevation == el-pi/2 || elevation == el || elevation == -el
                            %if elevation == abs(el)-angle/2 || elevation == abs(el)+angle/2
                            %if abs(elevation) == abs(el) || abs(elevation) == abs(el) + 2*angle
                                %J(x,y,z,1) = y_ori*I*r*cos(elevation)*cos(azimuth);
                                %J(x,y,z,2) = x_ori*I*r*cos(elevation)*sin(azimuth);
                                %J(x,y,z,3) = I*r*sin(elevation);
                                J(x,y,z,1) = I*r*sin(elevation)*(sin(az)*y_ori + cos(az)*x_ori);
                                J(x,y,z,2) = I*r*sin(elevation)*(sin(az)*x_ori + cos(az)*y_ori);
                                %J(x,y,z,3) = I*r*cos(elevation)*((y_ori*cos(azimuth) + x_ori*sin(azimuth));
                                J(x,y,z,3) = I*r*cos(elevation)*( ( sin(az)*y_ori + sin(az)*x_ori )*cos(azimuth) + ( cos(az)*x_ori + cos(az)*y_ori )*sin(azimuth) );
                                %end
                        end
                    end
                end
            end
        end