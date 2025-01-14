# Tests formulations in prob/opf
@testset "test opf" begin

@testset "c1 opf" begin

    opf_ac_objective = [14676.95, 27564.92]
    @testset "basic opf acp - $(i)" for (i,network) in enumerate(c1_networks)
        parse_c1_opf_files(c1_ini_file, scenario_id=c1_scenarios[i])
        result = run_opf(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_ac_objective[i]; atol = 1e0)
    end

    opf_shunt_ac_objective = [14676.95, 27545.01]
    @testset "opf shunt acp - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_shunt(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_shunt_ac_objective[i]; atol = 1e0)
    end

    @testset "opf shunt acr - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_shunt(network, ACRPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_shunt_ac_objective[i]; atol = 1e0)
    end

    opf_shunt_soc_objective = [14666.91, 27510.25]
    @testset "opf shunt soc - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_shunt(network, SOCWRPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_shunt_soc_objective[i]; atol = 1e0)
    end

    opf_shunt_dcp_objective = [14642.16, 26982.17]
    @testset "opf shunt dcp - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_shunt(network, DCPPowerModel, lp_solver)

        @test isapprox(result["termination_status"], OPTIMAL)
        @test isapprox(result["objective"], opf_shunt_dcp_objective[i]; atol = 1e0)
    end

    @testset "opf shunt dc - infeasible" begin
        result = run_c1_opf_shunt(c1_network_infeasible, DCPPowerModel, lp_solver)
        @test result["termination_status"] == INFEASIBLE || result["termination_status"] == INFEASIBLE_OR_UNBOUNDED
    end


    opf_cheap_ac_objective = [14676.95, 27542.05]
    @testset "opf cheap acp - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_cheap(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_cheap_ac_objective[i]; atol = 1e0)
    end

    @testset "opf cheap acr - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_cheap(network, ACRPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_cheap_ac_objective[i]; atol = 1e0)
    end

    opf_cheap_soc_objective = [14666.81, 27507.30]
    @testset "opf cheap soc - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_cheap(network, SOCWRPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_cheap_soc_objective[i]; atol = 1e0)
    end

    # not fully general
    # opf_cheap_dcp_objective = [14676.95, 27542.05]
    # @testset "opf cheap dcp - $(i)" for (i,network) in enumerate(c1_networks)

    #     result = run_c1_opf_cheap(network, ACPPowerModel, lp_solver)

    #     @test isapprox(result["termination_status"], OPTIMAL)
    #     @test isapprox(result["objective"], opf_cheap_ac_objective[i]; atol = 1e0)
    # end



    opf_cheap_dc_objective = [14642.16, 26982.17]
    @testset "opf cheap_dc dc - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_cheap(network, DCPPowerModel, lp_solver)

        @test isapprox(result["termination_status"], OPTIMAL)
        @test isapprox(result["objective"], opf_cheap_dc_objective[i]; atol = 1e0)
    end

    @testset "opf shunt dc - infeasible" begin
        result = run_c1_opf_cheap(c1_network_infeasible, DCPPowerModel, lp_solver)
        @test result["termination_status"] == INFEASIBLE || result["termination_status"] == INFEASIBLE_OR_UNBOUNDED
    end


    opf_pg_pf_polar_objective = [191950.48, 9.885375854285985e6]
    @testset "opf pg pf polar 5 - $(i)" for (i,network) in enumerate(c1_networks)
        result = run_c1_opf_cheap_target_acp(network, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_pg_pf_polar_objective[i]; atol = 1e0)
    end

    @testset "opf pg pf polar 5 - infeasible" begin
        result = run_c1_opf_cheap_target_acp(c1_network_infeasible, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_INFEASIBLE)
    end


    opf_pg_pf_rect_objective = [122981.99, 9.480588301784407e6]
    @testset "opf pg pf rect 5 - $(i)" for (i,network) in enumerate(c1_networks)
        network = deepcopy(network)

        deactivate_rate_a!(network)
        activate_rate_a_violations!(network)

        result = run_c1_opf_cheap_lazy_acr(network, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_pg_pf_rect_objective[i]; atol = 1e0)
    end

    @testset "opf pg pf rect 5 - infeasible" begin
        network = deepcopy(c1_network_infeasible)

        deactivate_rate_a!(network)
        activate_rate_a_violations!(network)

        result = run_c1_opf_cheap_lazy_acr(network, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_INFEASIBLE)
    end

end


@testset "c2 opf" begin

    opf_ac_objective = [3020.27, 11805.25, 25268.56]
    @testset "basic opf acp - $(i)" for (i,network) in enumerate(c2_networks)
        result = run_opf(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_ac_objective[i]; atol = 1e0)
    end

    opf_ac_objective = [593064.85, 379600.54, 543101.32]
    @testset "opf soft acp - $(i)" for (i,network) in enumerate(c2_networks)
        result = run_c2_opf_soft(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_ac_objective[i]; atol = 1e0)
    end

    opf_dc_objective = [593440.45, 379635.56, 549664.72]
    @testset "opf soft dcp - $(i)" for (i,network) in enumerate(c2_networks)
        result = run_c2_opf_soft(network, DCPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_dc_objective[i]; atol = 1e0)
    end

    opf_ac_objective = [593064.85, 389589.66, 543101.32]
    @testset "opf uc acp - $(i)" for (i,network) in enumerate(c2_networks)
        result = run_c2_opf_uc(network, ACPPowerModel, nlp_solver, relax_integrality=true)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_ac_objective[i]; atol = 1e0)
    end

    opf_ac_objective = [593064.85, 94900.13, 543101.32]
    @testset "opf soft ctg acp - $(i)" for (i,network) in enumerate(c2_networks)
        result = run_c2_opf_soft_ctg(network, ACPPowerModel, nlp_solver)

        @test isapprox(result["termination_status"], LOCALLY_SOLVED)
        @test isapprox(result["objective"], opf_ac_objective[i]; atol = 1e0)
    end



end

end # close test group

