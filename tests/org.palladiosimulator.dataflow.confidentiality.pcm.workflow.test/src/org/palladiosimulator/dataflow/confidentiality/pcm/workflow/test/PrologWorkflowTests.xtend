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
import org.eclipse.emf.ecore.resource.ResourceSet
import org.palladiosimulator.pcm.allocation.Allocation

class PrologWorkflowTests {

	Prover prover
	ResourceSet rs
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
		rs = new ResourceSetImpl
	}

	@Test
	def void testActorProcessGeneration() {
		val solution = initWithTravelPlanner("actorProcess(P, A).")
		val actorProcessMap = new HashMap<String, Collection<String>>
		for (var solutionIter = solution.iterator; solutionIter.hasNext; solutionIter.next) {
			val processName = solutionIter.get("P", String)
			val actor = solutionIter.get("A", String)
			val processNames = actorProcessMap.computeIfAbsent(actor, [k|new ArrayList])
			processNames.add(processName)
		}

		val userActorName = actorProcessMap.keySet.findFirst[contains("User")]
		val flightPlannerActorName = actorProcessMap.keySet.findFirst[contains("FlightPlanner")]
		assertEquals(2, actorProcessMap.keySet.size)
		assertEquals(5, actorProcessMap.get(userActorName).size)
		assertEquals(1, actorProcessMap.get(flightPlannerActorName).size)
	}


	@Test
	def void testTrace() {
		val modelURIs = getModelURIs("TravelPlanner-DC-AC", "newUsageModel.usagemodel", "newAllocation.allocation")
		val models = modelURIs.map[uri|rs.getResource(uri, true).contents.head]
		val usageModel = models.filter(UsageModel).findFirst[true]
		val allocationModel = models.filter(Allocation).findFirst[true]
		val elscs = usageModel.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].
			toMap([sb|sb], [ sb |
				sb.eAllContents.toList.filter(EntryLevelSystemCall)
			])

		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModels(usageModel).
			addAllocationModel(allocationModel).build
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
	
	
	protected def initWithTravelPlanner(String queryString) {
		val usageModelURIs = getModelURIs("TravelPlanner-DC-AC", "newUsageModel.usagemodel")
		val allocationModelURI = getModelURIs("TravelPlanner-DC-AC", "newAllocation.allocation").get(0)
		initializeProver(usageModelURIs, allocationModelURI)
		val query = prover.query(queryString)
		val solution = query.solve()
		assertTrue(solution.isSuccess)
		solution
	}

	protected def void initializeProver(List<URI> usageModelUris, URI allocationModelUri) {
		val job = new TransformPCMDFDToPrologJobBuilder().addSerializeModelToString.addUsageModelsByURI(usageModelUris).
			addAllocationModelByURI(allocationModelUri).build
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
