clear; close all; clc;
dataDir = fullfile(pwd,'DN2_23231071');
px = 0.403; py = 0.503;
fnN = fullfile(dataDir,'vozlisca_temperature_dn2_8.txt');
fnC = fullfile(dataDir,'celice_dn2_8.txt');
fnG = fullfile(dataDir,'velikost_Nx_Ny.txt');
if ~isfile(fnN)||~isfile(fnC), error('Manjkajo datoteke'); end

M = readmatrix(fnN); x=M(:,1); y=M(:,2); T=M(:,3);
C = readmatrix(fnC); C(C==0)=NaN; v=C(~isnan(C));
if ~isempty(v) && min(v)==0, C = C + 1; end
Nx=[]; Ny=[]; if isfile(fnG), t=readmatrix(fnG); t=t(~isnan(t)); if numel(t)>=2, Nx=round(t(1)); Ny=round(t(2)); end; end

res = struct('scattered',nan(1,2),'gridded',nan(1,2),'linear',nan(1,2));

try F = scatteredInterpolant(x,y,T,'linear','none'); tic; res.scattered(1)=F(px,py); res.scattered(2)=toc; end

validGrid=false;
if ~isempty(Nx)&&~isempty(Ny)&&numel(T)==Nx*Ny
    xv = unique(x,'stable'); yv = unique(y,'stable');
    if numel(xv)*numel(yv)==numel(T)
        ix = arrayfun(@(v)find(abs(xv-v)<1e-9,1), x);
        iy = arrayfun(@(v)find(abs(yv-v)<1e-9,1), y);
        if all(ix>0) && all(iy>0)
            V = nan(numel(xv),numel(yv));
            V(sub2ind(size(V),ix,iy)) = T;
            if ~any(isnan(V(:)))
                [Xg,Yg] = ndgrid(xv,yv);
                try Fg = griddedInterpolant(Xg,Yg,V,'linear','none'); tic; res.gridded(1)=Fg(px,py); res.gridded(2)=toc; validGrid=true; end
            end
        end
    end
end

cellIdx = [];
for ci=1:size(C,1)
    idx = C(ci,:); idx = idx(~isnan(idx));
    if isempty(idx), continue; end
    if inpolygon(px,py,x(idx),y(idx)), cellIdx = idx; break; end
end
if isempty(cellIdx)
    dmin=inf; best=0;
    for ci=1:size(C,1)
        idx=C(ci,:); idx=idx(~isnan(idx)); if isempty(idx), continue; end
        d=hypot(px-mean(x(idx)),py-mean(y(idx))); if d<dmin, dmin=d; best=ci; end
    end
    if best>0, cellIdx = C(best,:); cellIdx = cellIdx(~isnan(cellIdx)); end
end
if isempty(cellIdx), error('Ni mogoče določiti celice.'); end

tic;
if numel(cellIdx) < 3
    val = NaN;
else
    xv_c = x(cellIdx); yv_c = y(cellIdx); Tv = T(cellIdx);
    try
        DT = delaunayTriangulation(xv_c,yv_c);
        tri = pointLocation(DT,px,py);
        if isnan(tri)
            tris = DT.ConnectivityList; foundTri=0;
            for k=1:size(tris,1)
                verts = tris(k,:);
                P = [xv_c(verts), yv_c(verts)];
                A = [P(2,:)-P(1,:); P(3,:)-P(1,:)]';
                if abs(det(A))<eps, continue; end
                b = [px;py]-P(1,:)';
                ab = A\b; a=ab(1); b2=ab(2);
                w = [1-a-b2, a, b2];
                if all(w>=-1e-8), foundTri=k; break; end
            end
            if foundTri>0
                verts = tris(foundTri,:); vals = Tv(verts); val = w*vals;
            else
                [~,nn]=min(hypot(xv_c-px,yv_c-py)); val = Tv(nn);
            end
        else
            verts = DT.ConnectivityList(tri,:); P = [xv_c(verts), yv_c(verts)];
            A = [P(2,:)-P(1,:); P(3,:)-P(1,:)]';
            b = [px;py]-P(1,:)'; ab = A\b; a=ab(1); b2=ab(2);
            w = [1-a-b2, a, b2]; val = w * Tv(verts);
        end
    catch
        [~,nn]=min(hypot(xv_c-px,yv_c-py)); val = Tv(nn);
    end
end
res.linear(1)=val; res.linear(2)=toc;

fprintf('\n--- Povzetek ---\nTočka (%.6g, %.6g)\n',px,py);
fprintf('scatteredInterpolant: T = %.12g   čas = %.6f s\n',res.scattered(1),res.scattered(2));
fprintf('griddedInterpolant:   T = %.12g   čas = %.6f s\n',res.gridded(1),res.gridded(2));
fprintf('linear (po celici):    T = %.12g   čas = %.6f s\n',res.linear(1),res.linear(2));

[Tmax,imax]=max(T);
fprintf('\nNajvišja temperatura v vozliščih: T_max = %.12g pri (x,y) = (%.12g, %.12g) indeks %d\n',Tmax,x(imax),y(imax),imax);

outFile = fullfile(dataDir,'DN2_results.txt');
fid = fopen(outFile,'w');
if fid>0
    fprintf(fid,'DN2 results\nPoint: %.12g %.12g\n',px,py);
    fprintf(fid,'scattered: T = %.12g   time = %.12g\n',res.scattered(1),res.scattered(2));
    fprintf(fid,'gridded:   T = %.12g   time = %.12g\n',res.gridded(1),res.gridded(2));
    fprintf(fid,'linear:    T = %.12g   time = %.12g\n',res.linear(1),res.linear(2));
    fprintf(fid,'T_max = %.12g at (%.12g, %.12g) index %d\n',Tmax,x(imax),y(imax),imax);
    fclose(fid);
end
fprintf('\nBerem:\n  %s\n  %s\n',fnN,fnC); if isfile(fnG), fprintf('  (in %s)\n',fnG); end
fprintf('Rezultati shranjeni v %s\n',outFile);
