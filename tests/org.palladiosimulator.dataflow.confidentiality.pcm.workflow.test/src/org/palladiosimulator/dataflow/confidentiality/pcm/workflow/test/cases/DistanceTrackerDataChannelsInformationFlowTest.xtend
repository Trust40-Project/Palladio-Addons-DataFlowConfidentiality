package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.Behaviours
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowTumaTestBase

class DistanceTrackerDataChannelsInformationFlowTest extends InformationFlowTumaTestBase {
	
	new() {
		super("DistanceTracker-DC-InformationFlow")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testMissingDistanceDeclassificationFound() {
		runTest(2, [um |
			val rs = um.eResource.resourceSet
			EcoreUtil.resolveAll(rs)
			val behaviorResource = rs.resources.findFirst[URI.lastSegment.contains(".behaviour")]
			val behaviors = (behaviorResource.contents.get(0) as Behaviours);
			val declassifyChannel = behaviors.dataChannelBehaviour.findFirst[entityName == "DistanceTracker.DeclassifyDistance"]
			val forwardBehavior = behaviors.reusableBehaviours.findFirst[entityName == "Forward1"]
			declassifyChannel.reusedBehaviours.get(0).reusedBehaviour = forwardBehavior
		])
	}
	
}