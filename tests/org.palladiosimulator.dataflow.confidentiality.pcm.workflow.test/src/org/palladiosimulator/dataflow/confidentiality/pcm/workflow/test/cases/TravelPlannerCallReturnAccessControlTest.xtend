package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import java.util.function.Consumer
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI

class TravelPlannerCallReturnAccessControlTest extends TestBase {

	@Test
	def void testNoIssueFound() {
		val solution = deriveSolution([])
		assertNumberOfSolutions(solution, 0, #["P", "PIN", "ROLES", "REQ", "S"])
	}
	
	@Test
	def void testIssueFound() {
		val solution = deriveSolution([ um |
			val elsc = um.usageScenario_UsageModel.get(1).scenarioBehaviour_UsageScenario.actions_ScenarioBehaviour.
				filter(EntryLevelSystemCall).findFirst[entityName.contains("User.bookFlight.bookFlight")]
			val outputCharacterisations = elsc.inputParameterUsages_EntryLevelSystemCall.get(0).
				variableCharacterisation_VariableUsage
			outputCharacterisations.remove(1)
		])
		assertNumberOfSolutions(solution, 4, #["P", "PIN", "ROLES", "REQ", "S"])
	}
	
	def deriveSolution(Consumer<UsageModel> usageModelModifier) {
		val usageModelURI = getModelURI("TravelPlanner-CallReturn-AC/newUsageModel.usagemodel")
		val usageModel = rs.getResource(usageModelURI, true).contents.get(0) as UsageModel
		val allocationModelURI = getModelURI("TravelPlanner-CallReturn-AC/newAllocation.allocation")
		val allocationModel = rs.getResource(allocationModelURI, true).contents.get(0) as Allocation
		
		usageModelModifier.accept(usageModel)
		
		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModels(usageModel).
			addAllocationModel(allocationModel).useDefaultCharacteristics(false).build
		val workflow = TransformPCMDFDToPrologWorkflowFactory.createWorkflow(job)
		workflow.run
		
		val resultingProgram = workflow.prologProgram
		assertTrue(resultingProgram.isPresent)
		
		val traceWrapper = workflow.trace
		assertTrue(traceWrapper.isPresent)
		val trace = traceWrapper.get
		val ctRights = trace.getFactId([ct | ct.name == "AllowedRoles"]).findFirst[true]
		val ctRoles = trace.getFactId([ct | ct.name == "OwnedRoles"]).findFirst[true]

		prover.addTheory(resultingProgram.get)
		
		val query = prover.query('''
			inputPin(P, PIN),
			setof(R, nodeCharacteristic(P, ?CTROLES, R), ROLES),
			setof_characteristics(P, PIN, ?CTRIGHTS, REQ, S),
			intersection(REQ, ROLES, []).
		''')
		query.bind("CTROLES", ctRoles)
		query.bind("CTRIGHTS", ctRights)
		query.solve()
	}

}
