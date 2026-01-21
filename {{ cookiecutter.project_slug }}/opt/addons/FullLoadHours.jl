module IESoptAddon_FLH

# Addon implementing the constraint of minimum full load hours of a ranged profile or a unit with capacity specified as out:heat (unit.exp.out_heat available).

# Necessary
# - loading the addon in the config 
#       addons: {FullLoadHours_Profile: {}}
# - giving the target the tag "FLH" in the config 
#       name: {tags: FLH}
# - giving the target the value for minimum full load hours in the config 
#       name: {config: {full_load_hours: 7000}}

# Tips
# - check out example 18_addons.iesopt.yaml for the use of addons and variables for addons


using IESopt
import JuMP

function initialize!(model::JuMP.Model, config::Dict)
    return true
end

function construct_constraints!(model::JuMP.Model, config::Dict)
    assets = get_components(model; tagged="FLH")

    for asset in assets
        if !enforce_full_load_hours(asset)
            return false
        end
    end

    return true
end

function enforce_full_load_hours(asset::Profile)
    p_max = maximum(access(asset.ub))
    flh = asset.config["full_load_hours"]

    JuMP.@constraint(asset.model, sum(asset.exp.value) >= p_max * flh)

    return true
end

function enforce_full_load_hours(asset::Unit)
    p_max = maximum(access(asset.capacity))
    flh = asset.config["full_load_hours"]

    JuMP.@constraint(asset.model, sum(asset.exp.out_heat) >= p_max * flh)

    return true
end

end