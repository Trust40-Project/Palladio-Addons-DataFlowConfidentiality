package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl

import java.util.function.Consumer
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.EnumCharacteristicType
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI

class InformationFlowHighLow_TestBase extends TestBase {
	
	val String folderName
	
	new(String folderName) {
		this.folderName = folderName
	}
	
	protected def runTest(int expectedNumberOfSolutions) {
		runTest(expectedNumberOfSolutions, [])
	}
	
	protected def runTest(int expectedNumberOfSolutions, Consumer<UsageModel> usageModelModifier) {
		val solution = deriveSolution(usageModelModifier)
		assertNumberOfSolutions(solution, expectedNumberOfSolutions, #["P", "PIN", "S"])
	}
	
	def deriveSolution(Consumer<UsageModel> usageModelModifier) {
		val usageModelURI = getModelURI(folderName + "/newUsageModel.usagemodel")
		val usageModel = rs.getResource(usageModelURI, true).contents.get(0) as UsageModel
		val allocationModelURI = getModelURI(folderName + "/newAllocation.allocation")
		val allocationModel = rs.getResource(allocationModelURI, true).contents.get(0) as Allocation
		EcoreUtil.resolveAll(rs)
		
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
		val ctClassification = trace.getFactId([ct | ct.name == "Classification"]).findFirst[true]
		val highValue = trace.getPCMEntries(ctClassification).filter(PCMSingleTraceElement).map[element].filter(EnumCharacteristicType).findFirst[true].type.literals.findFirst[name == "High"]
		val cHigh = trace.getLiteralFactIds(highValue).findFirst[true]
		val ctZone = trace.getFactId([ct | ct.name == "Zone"]).findFirst[true]
		val attackValue = trace.getPCMEntries(ctZone).filter(PCMSingleTraceElement).map[element].filter(EnumCharacteristicType).findFirst[true].type.literals.findFirst[name == "Attack"]
		val cAttack = trace.getLiteralFactIds(attackValue).findFirst[true]

		prover.addTheory(resultingProgram.get)
		
		var queryString = '''
			inputPin(P, PIN),
			nodeCharacteristic(P, ?CTZONE, ?CZONE),
			characteristic(P, PIN, ?CTLEVEL, ?CLEVEL, S).
		'''
		var query = prover.query(queryString)
		query.bind("CTZONE", ctZone)
		query.bind("CZONE", cAttack)
		query.bind("CTLEVEL", ctClassification)
		query.bind("CLEVEL", cHigh)
		var solution = query.solve()
		solution
	}
	
}