module IESoptAddon_XOR

# Constraint of using only one of two components at a time = exclusive operation of components.

# Necessary
# - loading the addon in the config 
#       addons: {XOR: {bigM: 1}} }
# - setting the parameter bigM to "the shared capacity"
# - specifying the components in this addon
#       lines 51 & 52
# - decision: switching to MILP or staying at LP

# Comments
# Shown here for storage charging and discharging units.
# LP: the components share 100% of operation in one timestep (variable is 0-1), an interpretation of 25% and 75% capacity over one timestep is: 15min and 45min full load operation of the components.
# MILP: the constraint is enforced fully for one timestep (variable is a bool, 0 or 1)


# Tips
# - check out example 18_addons.iesopt.yaml for the use of addons and variables for addons
# - check out example 31_exclusive_operation.iesopt.yaml for a full application (exclusive selling and buying) and more comments


using IESopt
import JuMP

function initialize!(model::JuMP.Model, config::Dict)
    @info "[IESoptAddon_XOR] Initializing"

    if !haskey(config, "bigM")
        @error "[IESoptAddon_XOR] Missing <bigM> parameter"
        return false
    end

    return true
end

function construct_variables!(model::JuMP.Model, config::Dict)
    # Create the variable controlling the "XOR exchange" as binary.
    JuMP.@variable(model, var_charging[get_T(model)], Bin)

    return true
end

function construct_constraints!(model::JuMP.Model, config::Dict)
    T = get_T(model)

    bigM = config["bigM"]

    # Components to access
    charge = get_component(model, "storage_sim.charge")
    discharge = get_component(model, "storage_sim.discharge")

    var_charging = model[:var_charging]

    JuMP.@constraint(model, [t in T], charge.var.conversion[t] <= var_charging[t] * bigM)
    JuMP.@constraint(model, [t in T], discharge.var.conversion[t] <= (1 - var_charging[t]) * bigM)

    return true
end

end
