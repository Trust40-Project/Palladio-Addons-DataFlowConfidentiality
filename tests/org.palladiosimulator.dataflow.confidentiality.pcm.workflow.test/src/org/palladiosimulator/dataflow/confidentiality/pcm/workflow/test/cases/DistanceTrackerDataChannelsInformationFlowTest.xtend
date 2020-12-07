package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import java.util.function.Consumer
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.Behaviours
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI
import org.eclipse.emf.ecore.util.EcoreUtil
import java.nio.file.Files
import java.io.File

class DistanceTrackerDataChannelsInformationFlowTest extends TestBase {
	
	@Test
	def void testNoIssueFound() {
		val solution = deriveSolution([])
		assertNumberOfSolutions(solution, 0, #["P", "PIN", "V_LEVEL", "V_CLEAR", "S"])
	}
	
	@Test
	def void testMissingDistanceDeclassificationFound() {
		val solution = deriveSolution([um |
			val rs = um.eResource.resourceSet
			EcoreUtil.resolveAll(rs)
			val behaviorResource = rs.resources.findFirst[URI.lastSegment.contains(".behaviour")]
			val behaviors = (behaviorResource.contents.get(0) as Behaviours);
			val declassifyChannel = behaviors.dataChannelBehaviour.findFirst[entityName == "DistanceTracker.DeclassifyDistance"]
			val forwardBehavior = behaviors.reusableBehaviours.findFirst[entityName == "Forward1"]
			declassifyChannel.reusedBehaviours.get(0).reusedBehaviour = forwardBehavior
		])
		assertNumberOfSolutions(solution, 1, #["P", "PIN", "V_LEVEL", "V_CLEAR", "S"])
	}
	
	def deriveSolution(Consumer<UsageModel> usageModelModifier) {
		val usageModelURI = getModelURI("DistanceTracker-DC-InformationFlow/newUsageModel.usagemodel")
		val usageModel = rs.getResource(usageModelURI, true).contents.get(0) as UsageModel
		val allocationModelURI = getModelURI("DistanceTracker-DC-InformationFlow/newAllocation.allocation")
		val allocationModel = rs.getResource(allocationModelURI, true).contents.get(0) as Allocation
		
		usageModelModifier.accept(usageModel)
		
		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModels(usageModel).
			addAllocationModel(allocationModel).useDefaultCharacteristics(false).build
		val workflow = TransformPCMDFDToPrologWorkflowFactory.createWorkflow(job)
		workflow.run
		
		val resultingProgram = workflow.prologProgram
		assertTrue(resultingProgram.isPresent)
		Files.writeString(new File("/tmp/bla.pl").toPath, resultingProgram.get)
		
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