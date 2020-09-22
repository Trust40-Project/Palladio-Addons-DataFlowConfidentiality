package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test

import java.util.ArrayList
import java.util.Arrays
import java.util.Collection
import java.util.HashMap
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel
import org.prolog4j.Prover
import org.prolog4j.swicli.DefaultSWIPrologExecutableProvider
import org.prolog4j.swicli.SWIPrologCLIProverFactory
import org.prolog4j.swicli.SWIPrologCLIProverFactory.SWIPrologExecutableProviderStandalone
import org.prolog4j.swicli.enabler.SWIPrologEmbeddedFallbackExecutableProvider

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil.getModelURI

class PrologWorkflowTests {

	Prover prover
	static SWIPrologCLIProverFactory proverFactory

	@BeforeAll
	static def init() {
		StandaloneUtil.init
		var factory = new SWIPrologCLIProverFactory(
			Arrays.asList(new SWIPrologExecutableProviderStandalone(new DefaultSWIPrologExecutableProvider(), 2),
				new SWIPrologExecutableProviderStandalone(new SWIPrologEmbeddedFallbackExecutableProvider(), 1)));
		proverFactory = factory;
		return;
	}

	@BeforeEach
	def void setup() {
		prover = proverFactory.createProver
	}

	@Test
	def void testActorProcessGeneration() {
		val usageModelUris = getModelURIs("LoyaltyCard", "MakeStorePurchaseOnline.bpusagemodel",
			"MakeStorePurchaseWithLoyaltyProgram.bpusagemodel",
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
			val processNames = actorProcessMap.computeIfAbsent(actor, [k|new ArrayList])
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
	}

	@Test
	def void testTrace() {
		val usageModelUris = getModelURIs("LoyaltyCard", "MakeStorePurchaseOnline.bpusagemodel",
			"MakeStorePurchaseWithLoyaltyProgram.bpusagemodel",
			"Prepare Advertisements and Discounts.bpusagemodel", "RegisterLoyaltyCustomer.usagemodel",
			"RegisterOnlineCustomer.usagemodel")

		val rs = new ResourceSetImpl
		val usageModels = usageModelUris.map[uri|rs.getResource(uri, true).contents.head as UsageModel]
		val elscs = usageModels.flatMap[usageScenario_UsageModel].map[scenarioBehaviour_UsageScenario].
			toMap([sb|sb], [ sb |
				sb.eAllContents.toList.filter(EntryLevelSystemCall)
			])

		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModels(usageModels).build
		val workflow = TransformPCMDFDToPrologWorkflowFactory.createWorkflow(job)
		workflow.run

		val potentialTrace = workflow.trace
		assertTrue(potentialTrace.isPresent)

		val trace = potentialTrace.get
		for (elsc : elscs.values.flatten) {
			val factIds = trace.getFactIds(elsc)
			assertFalse(factIds.isEmpty)
			for (factId : factIds) {
				val pcmEntities = trace.getPCMEntries(factId)
				assertEquals(1, pcmEntities.size)
				assertTrue(pcmEntities.head instanceof PCMSingleTraceElement)
				assertEquals(elsc, (pcmEntities.head as PCMSingleTraceElement).element)
			}

		}
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
