module IESoptAddon_ECPriceAllocationStatic

# Constraint on fixed share (same percentage for all participants) provided for static price allocation inside an Energy Community. Supposed to be used with template "Building".

# Necessary
# - loading the addon in the config 
#       addons: {energy_sharing: {equal_share: 0.1}}

# Tips
# - check out example 18_addons.iesopt.yaml for the use of addons and variables for addons

using IESopt
import JuMP

function initialize!(model::JuMP.Model, config::Dict)
    return true
end

function construct_constraints!(model::JuMP.Model, config::Dict)
    T = get_T(model)
    buildings = get_components(model; tagged = "Building")

    for t in T
        total_to_ec = sum(b.to_ec.var.flow[t] for b in buildings)

        for b in buildings
            JuMP.@constraint(
                model,
                b.from_ec.var.flow[t] <= total_to_ec * config["equal_share"]
            )
        end
    end

    return true
end

end