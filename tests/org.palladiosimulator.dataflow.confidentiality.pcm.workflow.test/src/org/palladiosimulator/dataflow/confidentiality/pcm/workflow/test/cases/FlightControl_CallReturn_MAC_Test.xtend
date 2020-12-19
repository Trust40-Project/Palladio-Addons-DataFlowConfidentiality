package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.core.composition.AssemblyConnector
import org.palladiosimulator.pcm.repository.OperationProvidedRole
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHierarchicalLatices_TestBase

class FlightControl_CallReturn_MAC_Test extends InformationFlowHierarchicalLatices_TestBase {
	
	new() {
		super("FlightControl_CallReturn_MAC")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testWrongDBAccess() {
		runTest(7, [um |
			val system = um.eAllContents.filter(EntryLevelSystemCall).map[providedRole_EntryLevelSystemCall].filter(OperationProvidedRole).map[providingEntity_ProvidedRole].filter(System).findFirst[true]
			val connectorToChange = system.connectors__ComposedStructure.filter(AssemblyConnector).findFirst[connector | connector.requiredRole_AssemblyConnector.entityName == "CivilRouteCalculation.PlaneStore.OperationRequiredRole1"]
			val flightDBAC = system.assemblyContexts__ComposedStructure.findFirst[encapsulatedComponent__AssemblyContext.entityName == "FlightDB"]
			val newRole = flightDBAC.encapsulatedComponent__AssemblyContext.providedRoles_InterfaceProvidingEntity.filter(OperationProvidedRole).findFirst[entityName == "FlightDB.PlaneStore.Military"]
			connectorToChange.providedRole_AssemblyConnector = newRole
		])
	}
}
