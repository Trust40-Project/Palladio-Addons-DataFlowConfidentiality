package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl

import java.util.function.Consumer
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.CharacteristicTypeDictionary
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI

class TMACTestBase extends TestBase {
	
	val String folderName
	
	new(String folderName) {
		this.folderName = folderName;
	}
	
	protected def runTest(int expectedNumberOfSolutions) {
		runTest(expectedNumberOfSolutions, [])
	}
	
	protected def runTest(int expectedNumberOfSolutions, Consumer<UsageModel> usageModelModifier) {
		val solution = deriveSolution(usageModelModifier)
		assertNumberOfSolutions(solution, expectedNumberOfSolutions, #["P", "PIN", "ROLES", "REQ", "S"])
	}
	
	protected def deriveSolution(Consumer<UsageModel> usageModelModifier) {
		val usageModelURI = getModelURI(folderName + "/newUsageModel.usagemodel")
		val usageModel = rs.getResource(usageModelURI, true).contents.get(0) as UsageModel
		val allocationModelURI = getModelURI(folderName + "/newAllocation.allocation")
		val allocationModel = rs.getResource(allocationModelURI, true).contents.get(0) as Allocation
		EcoreUtil.resolveAll(rs)
		val ctDict = rs.resources.findFirst[r|r.URI.lastSegment == "CharacteristicTypeDictionary.xmi"].contents.get(0) as CharacteristicTypeDictionary
		
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
		val ctValidation = trace.getFactId([ct | ct.name == "ValidationStatus"]).findFirst[true]
		val literalValidated = ctDict.characteristicEnumerations.findFirst[name == "ValidationStatus"].literals.findFirst[name == "Validated"]
		val cValidated = trace.getLiteralFactIds(literalValidated).findFirst[true]
		val ctCriticality = trace.getFactId([ct | ct.name == "Criticality"]).findFirst[true]
		val literalHigh = ctDict.characteristicEnumerations.findFirst[name == "Criticality"].literals.findFirst[name == "High"]
		val cHigh = trace.getLiteralFactIds(literalHigh).findFirst[true]

		prover.addTheory(resultingProgram.get)
		
		val query = prover.query('''
			inputPin(P, PIN),
			setof(R, nodeCharacteristic(P, ?CTROLES, R), ROLES),
			setof_characteristics(P, PIN, ?CTRIGHTS, REQ, S),
			(intersection(REQ, ROLES, []);
			(nodeCharacteristic(P, ?CTCRITICAL, ?CHIGH),
			\+ characteristic(P, PIN, ?CTVALIDATION, ?CVALIDATED, S))).
		''')
		query.bind("CTROLES", ctRoles)
		query.bind("CTRIGHTS", ctRights)
		query.bind("CTCRITICAL", ctCriticality)
		query.bind("CHIGH", cHigh)
		query.bind("CTVALIDATION", ctValidation)
		query.bind("CVALIDATED", cValidated)
		query.solve()
	}
}