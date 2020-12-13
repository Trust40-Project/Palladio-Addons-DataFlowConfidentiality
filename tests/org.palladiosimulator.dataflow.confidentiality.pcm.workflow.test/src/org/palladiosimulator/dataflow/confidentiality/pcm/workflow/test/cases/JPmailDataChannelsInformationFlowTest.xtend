package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHighLowTestBase
import org.palladiosimulator.indirections.composition.DataSourceDelegationConnector
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.Repository
import org.eclipse.emf.ecore.util.EcoreUtil

class JPmailDataChannelsInformationFlowTest extends InformationFlowHighLowTestBase {
	
	new() {
		super("JPMail-DC-IF")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testMissingEncryption() {
		runTest(2, [um |
			val rs = um.eResource.resourceSet
			EcoreUtil.resolveAll(rs)
			val repository = rs.resources.findFirst[URI.fileExtension == "repository"].contents.get(0) as Repository
			val sendingComposite = repository.eAllContents.filter(CompositeComponent).findFirst[entityName == "MailSending"]
			val connectorToChange = sendingComposite.connectors__ComposedStructure.filter(DataSourceDelegationConnector).findFirst[c | c.outerDataSourceRole.entityName.toLowerCase.contains("body")]
			val splitMailAc = sendingComposite.assemblyContexts__ComposedStructure.findFirst[entityName.contains("splitMail")]
			val splitMailRole = (splitMailAc.encapsulatedComponent__AssemblyContext as DataChannel).dataSourceRoles.findFirst[entityName.toLowerCase.contains("body")]
			connectorToChange.assemblyContext = splitMailAc
			connectorToChange.innerDataSourceRole = splitMailRole
		])
	}
	
}