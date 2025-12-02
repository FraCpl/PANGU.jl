using LinearAlgebra
using Quaternions
using GLMakie
using JTools
using ATLAS

function pos2azel(pos)
    x, y, z = pos
    r = norm(pos)
    return atan(y, x), asin(z/r)
end

res = runATLAS(plotResults = :none);

data, sol, ~, ~ = res;
sol = sol[1];
frames = ATLAS.ReferenceFrames(data)
pos_I = [u.pos_I for u in sol.u]
pos_M = q_transformVector.(ATLAS.q_IM.(Ref(frames), sol.t), pos_I)

azel = pos2azel.(pos_M)
lon = getindex.(azel, 1)
lat = getindex.(azel, 2)
R = 1737.4e3        # Planet radius

fig = Figure();
display(fig)
ax = LScene(fig[1, 1]; show_axis = false)
plotMoon!(ax, R)
lines!(ax, getindex.(pos_M, 1), getindex.(pos_M, 2), getindex.(pos_M, 3))

ax2 = GLMakie.Axis(fig[1, 2], aspect = DataAspect())#, limits=(-180, 180, -90, 90), xlabel="Azimuth [deg]", ylabel="Elevation [deg]")
xy = stereographicSouthProj.(lon, lat)
lines!(ax2, xy)

θ = range(0, 2π, 100)
ct = cos.(θ);
st = sin.(θ)
for i = 1:500:lastindex(pos_M)
    r = norm(pos_M[i])
    if r < R
        ;
        break;
    end
    z = pos_M[i] ./ r
    y = normalize(cross(randn(3), z))
    x = cross(z, y)
    T = dcm_fromAxes(x, y, z)
    α = asin(R/r)
    d = R*sin(α)
    ℓ = R*cos(α)
    posCirc = [T*[ℓ*ct[k]; ℓ*st[k]; d] for k in eachindex(ct)]
    azelc = pos2azel.(posCirc)
    lonc = getindex.(azelc, 1)
    latc = getindex.(azelc, 2)

    # lines!(ax2, azc, elc)
    xy = stereographicSouthProj.(lonc, latc)
    lines!(ax2, xy)
    lines!(ax, getindex.(posCirc, 1), getindex.(posCirc, 2), getindex.(posCirc, 3))
end
