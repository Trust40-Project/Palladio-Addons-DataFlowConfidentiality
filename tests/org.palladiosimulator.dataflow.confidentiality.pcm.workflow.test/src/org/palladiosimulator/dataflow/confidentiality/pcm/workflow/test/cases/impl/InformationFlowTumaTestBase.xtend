package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl

import java.util.function.Consumer
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI

class InformationFlowTumaTestBase extends TestBase {
	
	val String folderName
	
	new(String folderName) {
		this.folderName = folderName
	}
	
	protected def runTest(int expectedNumberOfSolutions) {
		runTest(expectedNumberOfSolutions, [])
	}
	
	protected def runTest(int expectedNumberOfSolutions, Consumer<UsageModel> usageModelModifier) {
		val solution = deriveSolution(usageModelModifier)
		assertNumberOfSolutions(solution, expectedNumberOfSolutions, #["P", "PIN", "V_LEVEL", "V_CLEAR", "S"])
	}
	
	def deriveSolution(Consumer<UsageModel> usageModelModifier) {
		val usageModelURI = getModelURI(folderName + "/newUsageModel.usagemodel")
		val usageModel = rs.getResource(usageModelURI, true).contents.get(0) as UsageModel
		val allocationModelURI = getModelURI(folderName + "/newAllocation.allocation")
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
		val ctClassification = trace.getFactId([ct | ct.name == "DataClassification"]).findFirst[true]
		val ctClearance = trace.getFactId([ct | ct.name == "NodeClearance"]).findFirst[true]

		prover.addTheory(resultingProgram.get)
		
		val query = prover.query('''
			CT_LEVEL = ?CTSECLEVEL,
			CT_CLEARANCE = ?CTCLEARANCE,
			nodeCharacteristic(P, CT_CLEARANCE, V_CLEAR),
			characteristicTypeValue(CT_CLEARANCE, V_CLEAR, N_CLEAR),
			inputPin(P, PIN),
			characteristic(P, PIN, CT_LEVEL, V_LEVEL, S),
			characteristicTypeValue(CT_LEVEL, V_LEVEL, N_LEVEL),
			N_LEVEL > N_CLEAR.
		''')
		query.bind("CTCLEARANCE", ctClearance)
		query.bind("CTSECLEVEL", ctClassification)
		query.solve()
	}
	
}