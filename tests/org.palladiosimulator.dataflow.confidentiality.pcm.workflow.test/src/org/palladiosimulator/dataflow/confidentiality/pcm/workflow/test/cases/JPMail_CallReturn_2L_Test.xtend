package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.repository.Repository
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHighLow_TestBase

class JPMail_CallReturn_2L_Test extends InformationFlowHighLow_TestBase {

	new() {
		super("JPMail_CallReturn_2L")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testMissingEncryption() {
		runTest(4, [um |
			val rs = um.eResource.resourceSet
			EcoreUtil.resolveAll(rs)
			val repository = rs.resources.findFirst[URI.fileExtension == "repository"].contents.get(0) as Repository
			val sendingSEFF = repository.eAllContents.filter(ResourceDemandingSEFF).findFirst[describedService__SEFF.entityName == "sendMail"]
			sendingSEFF.steps_Behaviour.removeIf([entityName == "MailSendingFacade.sendMail.encryptBody"])
			val predecessor = sendingSEFF.steps_Behaviour.findFirst[entityName == "MailSendingFacade.sendMail.getPublicKey"]
			val successor = sendingSEFF.steps_Behaviour.findFirst[entityName == "MailSendingFacade.sendMail.splitHeader"]
			predecessor.successor_AbstractAction = successor
		])
	}
}
