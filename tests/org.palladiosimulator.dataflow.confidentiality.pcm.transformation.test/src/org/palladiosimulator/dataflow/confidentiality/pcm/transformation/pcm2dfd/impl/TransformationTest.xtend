package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import de.uka.ipd.sdq.identifier.Identifier
import java.io.ByteArrayOutputStream
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Data
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneUtils
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneUtils.*
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

class TransformationTest {

	var PcmToDfdTransformation subject;

	@BeforeAll
	static def void init() {
		StandaloneUtils.init
	}

	@BeforeEach
	def void setup() {
		subject = new PcmToDfdTransformationImplementation
	}

	@Test
	def void testTravelPlanner() {
		createInput("TravelPlanner-DC/newUsageModel.usagemodel", "TravelPlanner-DC/newAllocation.allocation").
			assertSameAsReference("TravelPlanner-DC/expected_dd.xmi", "TravelPlanner-DC/expected_dfd.xmi", [input,result|
				val trace = result.trace
				assertNotNull(trace)
				
				// test trace of entry level system calls
				val elscs = input.getUsageModel.usageScenario_UsageModel.get(0).scenarioBehaviour_UsageScenario.actions_ScenarioBehaviour.filter(EntryLevelSystemCall)
				for (elsc : elscs) {
					val traceEntries = trace.getDFDEntries(elsc)
					var expectedEntries = 2
					if (elsc.operationSignature__EntryLevelSystemCall.returnType__OperationSignature === null) {
						expectedEntries--
					}
					if (elsc.operationSignature__EntryLevelSystemCall.parameters__OperationSignature.isEmpty) {
						expectedEntries--
					}
					assertEquals(expectedEntries, traceEntries.size)
				}

			])
	}

	@Data
	protected static class TransformationInput {
		val UsageModel usageModel
		val Allocation allocation 
	}

	protected def createInput(String usageModelPath, String allocationModelPath) {
		val inputRs = new ResourceSetImpl
		val usageModelResource = inputRs.getResource(getModelURI(usageModelPath), true)
		val usageModel = usageModelResource.contents.iterator.next as UsageModel
		val allocationModelResource = inputRs.getResource(getModelURI(allocationModelPath), true)
		val allocationModel = allocationModelResource.contents.iterator.next as Allocation
		EcoreUtil.resolveAll(inputRs)
		new TransformationInput(usageModel, allocationModel)
	}

	protected def assertSameAsReference(TransformationInput input, String expectedDdPath,
		String expectedDfdPath) {
			input.assertSameAsReference(expectedDdPath, expectedDfdPath, [])
	}

	interface CustomAssertions {
		def void doAssertions(TransformationInput input, TransformationResult result)
	}

	protected def assertSameAsReference(TransformationInput input, String expectedDdPath,
		String expectedDfdPath, CustomAssertions assertions) {
		// Uri calculation
		val ddUri = getModelURI(expectedDdPath)
		val dfdUri = getModelURI(expectedDfdPath)

		// loading of expected model
		val expectedRs = new ResourceSetImpl
		val expectedDd = expectedRs.getResource(ddUri, true).contents.head
		val expectedDfd = expectedRs.getResource(dfdUri, true).contents.head
		EcoreUtil.resolveAll(expectedRs)
		expectedDfd.normalizeIdentifiers
		expectedDd.normalizeIdentifiers

		// calculation of actual models
		val actual = subject.transform(#[input.usageModel], input.allocation)

		// saving of models into resources
		val actualRs = new ResourceSetImpl
		val actualDd = actualRs.createResource(ddUri)
		actualDd.contents += actual.dictionary
//		actualDd.save(#{})
		val actualDfd = actualRs.createResource(dfdUri)
		actualDfd.contents += actual.diagram
//		actualDfd.save(#{})
		actual.diagram.normalizeIdentifiers
		actual.dictionary.normalizeIdentifiers

		// assertions
		assertEquals(expectedDd.serializeToString, actualDd.serializeToString)
		assertEquals(expectedDfd.serializeToString, actualDfd.serializeToString)
		assertions.doAssertions(input, actual)
	}

	protected def getUsageModel(ResourceSet rs, String folderName, String... modelNames) {
		modelNames.map[modelName|rs.getUsageModel(folderName, modelName)]
	}

	protected def getUsageModel(ResourceSet rs, String folderName, String modelName) {
		val r = rs.getResource(getModelURI('''«folderName»/«modelName»'''), true)
		r.contents.iterator.next as UsageModel
	}

	protected def normalizeIdentifiers(EObject diagram) {
		val identifiers = diagram.eAllContents.filter(Identifier).toList
		identifiers.add(0, diagram as Identifier)
		for (var i = 0; i < identifiers.size; i++) {
			identifiers.get(i).id = i.toString
		}
	}

	protected def serializeToString(EObject o) {
		o.eResource.serializeToString
	}

	protected def serializeToString(Resource r) {
		try (var baos = new ByteArrayOutputStream) {
			r.save(baos, #{})
			return baos.toString
		}
	}

}
