package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl

import java.util.function.Consumer
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel
import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.CharacteristicTypeDictionary

class ABACTwoBranchesTestBase extends TestBase {
	
	val String folderName

	new(String folderName) {
		this.folderName = folderName;
	}

	protected def runTest(int expectedNumberOfSolutions) {
		runTest(expectedNumberOfSolutions, [])
	}

	protected def runTest(int expectedNumberOfSolutions, Consumer<UsageModel> usageModelModifier) {
		val solution = deriveSolution(usageModelModifier)
		assertNumberOfSolutions(solution, expectedNumberOfSolutions, #["A", "PIN", "SUBJ_LOC", "SUBJ_ROLE", "OBJ_LOC", "OBJ_STAT", "S"])
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
		
		val characteristicTypeDict = rs.resources.findFirst[r | r.URI.lastSegment == "CharacteristicTypes.characteristics"].contents.get(0) as CharacteristicTypeDictionary
		val rolesEnum = characteristicTypeDict.characteristicEnumerations.findFirst[name == "Roles"]
		val statusEnum = characteristicTypeDict.characteristicEnumerations.findFirst[name == "Status"]

		val ctLocation = trace.getFactId([ct|ct.name == "Location"]).findFirst[true]
		val ctOrigin = trace.getFactId([ct|ct.name == "Origin"]).findFirst[true]
		val ctRole = trace.getFactId([ct|ct.name == "Role"]).findFirst[true]
		val ctStatus = trace.getFactId([ct|ct.name == "Status"]).findFirst[true]
		val cManagerRole = trace.getLiteralFactIds(rolesEnum.literals.findFirst[name == "Manager"]).findFirst[true]
		val cCelebrityStatus = trace.getLiteralFactIds(statusEnum.literals.findFirst[name == "Celebrity"]).findFirst[true]

		prover.addTheory(resultingProgram.get)

		val queryString = '''
			CMANAGER = ?CMANAGER,
			(actor(A);actorProcess(A,_)),
			inputPin(A,PIN),
			nodeCharacteristic(A, ?CTLOCATION, SUBJ_LOC),
			nodeCharacteristic(A, ?CTROLE, SUBJ_ROLE),
			characteristic(A, PIN, ?CTORIGIN, OBJ_LOC, S),
			characteristic(A, PIN, ?CTSTATUS, OBJ_STAT, S),
			(
				SUBJ_LOC \= OBJ_LOC,
				SUBJ_ROLE \= CMANAGER;
				OBJ_STAT = ?CCELEBRITY,
				SUBJ_ROLE \= CMANAGER
			).
		'''
		
		var query = prover.query(queryString)
			.bind("CTLOCATION", ctLocation)
			.bind("CTROLE", ctRole)
			.bind("CTORIGIN", ctOrigin)
			.bind("CTSTATUS", ctStatus)
			.bind("CMANAGER", cManagerRole)
			.bind("CCELEBRITY", cCelebrityStatus)
			
		var solution = query.solve()
		solution
	}
	
}