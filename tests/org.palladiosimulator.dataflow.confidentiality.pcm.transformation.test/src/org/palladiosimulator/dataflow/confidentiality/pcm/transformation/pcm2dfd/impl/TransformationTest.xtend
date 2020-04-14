package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import de.uka.ipd.sdq.identifier.Identifier
import java.io.ByteArrayOutputStream
import java.util.Collection
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneUtils
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneUtils.*

class TransformationTest {

	var PcmToDfdTransformation subject;

	@BeforeAll
	static def void init() {
		StandaloneUtils.init
	}

	@BeforeEach
	def void setup() {
		subject = new PcmToDfdTransformationImpl
	}

	@Test
	def testTravelPlanner() {
		"TravelPlanner/newUsageModel.usagemodel".assertSameAsReference("TravelPlanner/expected_dd.xmi",
			"TravelPlanner/expected_dfd.xmi")
	}

	@Test
	def testLoyaltyCard() {
		"TravelPlanner/newUsageModel.usagemodel".assertSameAsReference("TravelPlanner/expected_dd.xmi",
			"TravelPlanner/expected_dfd.xmi")
	}

	protected def assertSameAsReference(String usageModelPath, String expectedDdPath, String expectedDfdPath) {
		val inputRs = new ResourceSetImpl
		val usageModelResource = inputRs.getResource(getModelURI(usageModelPath), true)
		val usageModel = usageModelResource.contents.iterator.next as UsageModel
		#[usageModel].assertSameAsReference(expectedDdPath, expectedDfdPath)
	}

	protected def assertSameAsReference(Collection<UsageModel> usageModels, String expectedDdPath,
		String expectedDfdPath) {
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
		val actual = subject.transform(usageModels)

		// saving of models into resources
		val actualRs = new ResourceSetImpl
		val actualDd = actualRs.createResource(ddUri)
		actualDd.contents += actual.dictionary
		val actualDfd = actualRs.createResource(dfdUri)
		actualDfd.contents += actual.diagram
		actual.diagram.normalizeIdentifiers
		actual.dictionary.normalizeIdentifiers

		// assertions
		assertEquals(expectedDd.serializeToString, actualDd.serializeToString)
		assertEquals(expectedDfd.serializeToString, actualDfd.serializeToString)
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
