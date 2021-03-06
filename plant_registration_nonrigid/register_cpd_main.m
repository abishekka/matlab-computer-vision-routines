addpath( '../third_party/gmmreg-read-only/' );
addpath( '../file_management/' );
addpath( genpath( '../third_party/CPD2' ) );
addpath( '../plant_registration' );
addpath( '../PointCloudGenerator/' );

filename_0 = sprintf( '~/Data/PlantDataPly/plants_converted82-%03d-clean-clear-reduced.ply', 0 );
[Elements_0,varargout_0] = plyread(filename_0);
X = [Elements_0.vertex.x';Elements_0.vertex.y';Elements_0.vertex.z']';
X = X(1:10:end,:)
rms_e_all = [];
R =  [ 0.9101   -0.4080    0.0724 ;
       0.4118    0.8710   -0.2681 ;
       0.0463    0.2738    0.9607 ];
t = [ 63.3043,  234.5963, -46.8392 ];
for q=1:11
filename_1 = sprintf( '~/Data/PlantDataPly/plants_converted82-%03d-clean-clear-reduced.ply', q );
[Elements_1,varargout_1] = plyread(filename_1);
Y = [Elements_1.vertex.x';Elements_1.vertex.y';Elements_1.vertex.z']';
for j=1:q
        Y_dash = R*Y' + repmat(t,size(Y,1),1)';
        Y = Y_dash';
end
Y = Y(1:10:end,:);

lambda = 4;
beta = 1;
Y_ = ones(size(Y));
iters_rigid = 10;
iters_nonrigid  = 30;
fgt=0;
scale=0;
[Y_(:,1),Y_(:,2),Y_(:,3)] = registerToReferenceRangeScan(X, Y, iters_rigid, ...                                                iters_rigid,...
                                                    iters_nonrigid,...
                                                    lambda,...
                                                    beta,...
                                                    fgt,scale);
[neighbour_id,neighbour_dist] = kNearestNeighbors(X, Y_, 1 );
% get nearest neighbour for each point in the original cloud in the
% matched cloud



X_reg = ones(size(X(neighbour_id,:)));
[X_reg(:,1),X_reg(:,2),X_reg(:,3)] = registerToReferenceRangeScan( ...
                                            Y,X(neighbour_id,:),...
                                          iters_rigid,iters_nonrigid,...
                                          lambda,beta,fgt,scale );
                                       
[neighbour_id_reg,neighbour_dist_reg] = kNearestNeighbors(X_reg,X,1 );
sprintf('RMS-E: ' )
rms_e = sqrt( sum(neighbour_dist_reg(:))/ length(neighbour_dist_reg(:)) )                      
rms_e_all = [rms_e_all rms_e];
end