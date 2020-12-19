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

class PrivateTaxi_LG_TestBase extends TestBase {
	
	val String folderName
	
	new(String folderName) {
		this.folderName = folderName;
	}
	
	protected def runTest(int expectedNumberOfSolutions) {
		runTest(expectedNumberOfSolutions, [])
	}
	
	protected def runTest(int expectedNumberOfSolutions, Consumer<UsageModel> usageModelModifier) {
		val solution = deriveSolution(usageModelModifier)
		assertNumberOfSolutions(solution, expectedNumberOfSolutions, #["N", "PIN", "R", "D", "S"])
	}
	
	protected def deriveSolution(Consumer<UsageModel> usageModelModifier) {
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
		val characteristicTypesDictionary = rs.resources.findFirst[r | r.URI.lastSegment == "CharacteristicTypes.characteristics"].contents.get(0) as CharacteristicTypeDictionary
		val ownerEnum = characteristicTypesDictionary.characteristicEnumerations.findFirst[name == "Roles"]
		val dataTypesEnum = characteristicTypesDictionary.characteristicEnumerations.findFirst[name == "CriticalDataType"]
		val ctCriticalDataType = trace.getFactId([ct | ct.name == "CriticalDataType"]).findFirst[true]
		val cContact = trace.getLiteralFactIds(dataTypesEnum.literals.findFirst[name == "ContactData"]).findFirst[true]
		val cRoute = trace.getLiteralFactIds(dataTypesEnum.literals.findFirst[name == "Route"]).findFirst[true]
		val ctOwner = trace.getFactId([ct | ct.name == "Owner"]).findFirst[true]
		val cCalcDistance = trace.getLiteralFactIds(ownerEnum.literals.findFirst[name == "CalcDistance"]).findFirst[true]
		val cPrivateTaxi = trace.getLiteralFactIds(ownerEnum.literals.findFirst[name == "PrivateTaxi"]).findFirst[true]

		prover.addTheory(resultingProgram.get)
		
		val query = prover.query('''
		(
			R = ?CCALCDIST,
			D = ?CCONTACT
		; 
			R = ?CPRIVATETAXI,
			D = ?CROUTE
		),
		inputPin(N,PIN),
		nodeCharacteristic(N, ?CTOWNER, R),
		characteristic(N, PIN, ?CTCRITDT, D, S).
		''')
		query.bind("CCALCDIST", cCalcDistance)
		query.bind("CCONTACT", cContact)
		query.bind("CPRIVATETAXI", cPrivateTaxi)
		query.bind("CROUTE", cRoute)
		query.bind("CTOWNER", ctOwner)
		query.bind("CTCRITDT", ctCriticalDataType)
		query.solve()
	}
}