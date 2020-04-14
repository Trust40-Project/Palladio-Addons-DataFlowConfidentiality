package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test

import java.util.Collection
import java.util.HashMap
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel
import org.prolog4j.Prover
import org.prolog4j.tuprolog.TuPrologProverFactory

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI
import java.util.ArrayList

class PrologWorkflowTests {

	Prover prover

	@BeforeAll
	static def init() {
		StandaloneUtil.init
	}

	@BeforeEach
	def void setup() {
		prover = new TuPrologProverFactory().createProver
	}

	@Test
	def void testActorProcessGeneration() {
		val usageModelUris = getModelURIs("LoyaltyCard", "MakeStorePurchaseOnline.bpusagemodel",
			"MakeStorePurchaseWithLoyaltyProgram.bpusagemodel", "MakeStorePurchaseWithoutLoyaltyProgram.bpusagemodel",
			"Prepare Advertisements and Discounts.bpusagemodel", "RegisterLoyaltyCustomer.usagemodel",
			"RegisterOnlineCustomer.usagemodel")

		val rs = new ResourceSetImpl
		val elscs = usageModelUris.map[uri|rs.getResource(uri, true).contents.head as UsageModel].flatMap [
			usageScenario_UsageModel
		].map[scenarioBehaviour_UsageScenario].toMap([sb|sb], [sb|sb.eAllContents.toList.filter(EntryLevelSystemCall)])

		initializeProver(usageModelUris)

		val query = prover.query('''
			actorProcess(P, A).
		''')
		val solution = query.solve()
		assertTrue(solution.isSuccess)

		val actorProcessMap = new HashMap<String, Collection<String>>
		for (var solutionIter = solution.iterator; solutionIter.hasNext; solutionIter.next) {
			val processName = solutionIter.get("P", String)
			val actor = solutionIter.get("A", String)
			val processNames = actorProcessMap.computeIfAbsent(actor, [k | new ArrayList])
			processNames.add(processName)
		}

		for (sb : elscs.keySet) {

			val key = actorProcessMap.keySet.findFirst[contains(sb.entityName)]
			val processNames = actorProcessMap.get(key)

			for (elsc : elscs.get(sb)) {
				var requiredProcesses = 2;
				if (elsc.operationSignature__EntryLevelSystemCall.returnType__OperationSignature === null) {
					requiredProcesses--
				}
				if (elsc.operationSignature__EntryLevelSystemCall.parameters__OperationSignature.isEmpty) {
					requiredProcesses--
				}

				val relatedElscs = processNames.filter[contains(elsc.entityName)]
				assertEquals(requiredProcesses, relatedElscs.size,
					"The required amount of processes is not met for " + elsc.id)
				processNames.removeAll(relatedElscs)
			}

			assertTrue(processNames.isEmpty)
			actorProcessMap.remove(key);

		}

		assertTrue(actorProcessMap.isEmpty)

		println(actorProcessMap)
	}

	protected def void initializeProver(List<URI> usageModelUris) {
		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModelsByURI(usageModelUris).
			build
		val workflow = TransformPCMDFDToPrologWorkflowFactory.createWorkflow(job)
		workflow.run

		val resultingProgram = workflow.prologProgram
		assertTrue(resultingProgram.isPresent)

		prover.addTheory(resultingProgram.get)
	}

	protected def getModelURIs(String modelFolder, String... fileNames) {
		fileNames.map[f|getModelURI(modelFolder + "/" + f)]
	}

}
