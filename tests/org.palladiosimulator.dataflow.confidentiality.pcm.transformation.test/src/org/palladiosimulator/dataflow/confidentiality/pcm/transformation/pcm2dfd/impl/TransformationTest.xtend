package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import de.uka.ipd.sdq.identifier.Identifier
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneInitializer
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.URIHelper.*

class TransformationTest {
	
	var PcmToDfdTransformation subject;
	
	@BeforeAll
	static def void init() {
		StandaloneInitializer.init
	}

	@BeforeEach
	def void setup() {
		subject = new PcmToDfdTransformationImpl
	}
	
	@Test
	def testTravelPlanner() {
		val rs = new ResourceSetImpl
		val expectedDfd = rs.getResource(getModelURI("TravelPlanner/expected.xmi"), true).contents.head
		expectedDfd.normalizeIdentifiers
		val r = rs.getResource(getModelURI("TravelPlanner/newUsageModel.usagemodel"), true)
		val usageModel = r.contents.iterator.next as UsageModel

		val actual = subject.transform(usageModel)
		actual.diagram.normalizeIdentifiers
		
		val comparisonScope = new DefaultComparisonScope(expectedDfd, actual.diagram, null)
		val compare = EMFCompare.builder.build
		val result = compare.compare(comparisonScope)
		assertEquals(1, result.matches.size)
		assertTrue(result.differences.empty)
	}
	
	protected def normalizeIdentifiers(EObject diagram) {
		val identifiers = diagram.eAllContents.filter(Identifier).toList
		identifiers.add(0, diagram as Identifier)
		for (var i = 0; i < identifiers.size; i++) {
			identifiers.get(i).id = i.toString
		}
	}
	
}
