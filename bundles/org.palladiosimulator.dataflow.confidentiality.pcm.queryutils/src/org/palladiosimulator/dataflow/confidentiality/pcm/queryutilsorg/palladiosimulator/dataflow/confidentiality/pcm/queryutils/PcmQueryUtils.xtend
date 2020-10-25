package org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import java.util.ArrayList
import java.util.Stack
import org.palladiosimulator.indirections.composition.AssemblyDataConnector
import org.palladiosimulator.indirections.composition.DataSourceDelegationConnector
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.pcm.core.composition.AssemblyConnector
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.composition.ComposedStructure
import org.palladiosimulator.pcm.core.composition.ProvidedDelegationConnector
import org.palladiosimulator.pcm.core.composition.RequiredDelegationConnector
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.ProvidedRole
import org.palladiosimulator.pcm.repository.RequiredRole
import org.palladiosimulator.pcm.repository.Signature
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.seff.StopAction
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.pcm.seff.AbstractAction
import org.palladiosimulator.indirections.actions.ConsumeDataAction
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.indirections.composition.DataSinkDelegationConnector
import org.palladiosimulator.pcm.repository.RepositoryComponent
import org.palladiosimulator.indirections.repository.DataSinkRole

class PcmQueryUtils {

	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * It requires the context of the resolution process to be specified as stack of assembly contexts.
	 * The resulting stack can be completely different to the stack from which the call originated
	 * because composite components do not provide SEFFs but only contribute to the stack.
	 * 
	 * @param requiredRole The required role that points to the required component.
	 * @param calledSignature The signature that the SEFF describes.
	 * @param context The stack of assembly contexts that identifies the point from which
	 *        the call shall be resolved. The list starts with the most outer assembly context.
	 * @return A tuple of the resolved SEFF and the assembly context stack.
	 */
	def SeffWithContext findCalledSeff(RequiredRole requiredRole, Signature calledSignature, Stack<AssemblyContext> contexts) {
		val composedStructure = contexts.last.parentStructure__AssemblyContext
		val newcontext = new Stack()
		newcontext += contexts
		
		// test if there is an assembly connector satisfying the required role
		val assemblyConnector = composedStructure.connectors__ComposedStructure
			.filter(AssemblyConnector)
			.findFirst[
				requiredRole_AssemblyConnector === requiredRole &&
				requiringAssemblyContext_AssemblyConnector === newcontext.last
			]
		if (assemblyConnector !== null) {
			newcontext.remove(newcontext.last)
			val newAssemblyContext = assemblyConnector.providingAssemblyContext_AssemblyConnector
			val providedRole = assemblyConnector.providedRole_AssemblyConnector
			newcontext += newAssemblyContext
			return providedRole.findCalledSeff(calledSignature, newcontext)
		}
		
		// go to the parent composed structure to satisfy the required role
		val outerRequiredRole = composedStructure.connectors__ComposedStructure
			.filter(RequiredDelegationConnector)
			.filter[innerRequiredRole_RequiredDelegationConnector == requiredRole]
			.map[outerRequiredRole_RequiredDelegationConnector]
			.head
		newcontext.remove(newcontext.last)
		findCalledSeff(outerRequiredRole, calledSignature, newcontext)
	}



	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * It requires the context of the resolution process to be specified as stack of assembly contexts.
	 * The resulting stack can be completely different to the stack from which the call originated
	 * because composite components do not provide SEFFs but only contribute to the stack.
	 * 
	 * @param providedRole The provided role that points to the identifying component.
	 * @param calledSignature The signature that the SEFF describes.
	 * @param context The stack of assembly contexts that identifies the point from which
	 *        the call shall be resolved. The list starts with the most outer assembly context.
	 * @return A tuple of the resolved SEFF and the assembly context stack. 
	 */
	def findCalledSeff(ProvidedRole providedRole, Signature calledSignature, Stack<AssemblyContext> context) {
		val newContexts = new Stack()
		newContexts += context
		var role = providedRole
		var providingComponent = role.providingEntity_ProvidedRole
		while (providingComponent instanceof ComposedStructure) {
			val connector = providingComponent.findProvidedDelegationConnector(role)
			val assemblyContext = connector.assemblyContext_ProvidedDelegationConnector
			newContexts += assemblyContext
			role = connector.innerProvidedRole_ProvidedDelegationConnector
			providingComponent = role.providingEntity_ProvidedRole
		}
		if (providingComponent instanceof BasicComponent) {
			val seff = providingComponent.serviceEffectSpecifications__BasicComponent.filter(ResourceDemandingSEFF).
				findFirst[describedService__SEFF == calledSignature]
			if (seff === null) {
				return null
			}
			return new SeffWithContext(seff, newContexts)
		}
	}
	
	private def findProvidedDelegationConnector(ComposedStructure component, ProvidedRole outerRole) {
		component.connectors__ComposedStructure.filter(ProvidedDelegationConnector).
				findFirst[outerProvidedRole_ProvidedDelegationConnector == outerRole]
	}
	
	def getStopAction(ResourceDemandingSEFF seff) {
		seff.steps_Behaviour.filter(StopAction).findFirst[true]
	}
	
	
	
	def Iterable<OutgoingDataDestination> findDestinations(DataSourceRole emittingRole, Stack<AssemblyContext> context) {		
		val result = new ArrayList<OutgoingDataDestination>
		val emittingAc = context.peek
		val parent = emittingAc.parentStructure__AssemblyContext
		val newStack = context.copy
		newStack.pop		
		
		// follow the delegation connectors
		val delegationConnectors = parent.connectors__ComposedStructure.filter(DataSourceDelegationConnector).filter [
			innerDataSourceRole === emittingRole && assemblyContext === emittingAc
		]
		for (delegationConnector : delegationConnectors) {
			result += findDestinations(delegationConnector.outerDataSourceRole, newStack)
		}

		// follow the assembly connectors
		val assemblyConnectors = parent.connectors__ComposedStructure.filter(AssemblyDataConnector).filter [
			dataSourceRole === emittingRole && sourceAssemblyContext === emittingAc
		]
		for (assemblyConnector : assemblyConnectors) {
			result += assemblyConnector.findDestinations(newStack)
		}

		result		
	}
	
	def findDestinations(AssemblyDataConnector connector, Stack<AssemblyContext> context) {
		val sinkAc = connector.sinkAssemblyContext
		val sinkRole = connector.dataSinkRole
		val sinkComponent = sinkAc.encapsulatedComponent__AssemblyContext
		val newStack = context.copy
		newStack += sinkAc
		return findDestinations(sinkComponent, sinkRole, newStack)
	}
	
	
	def Iterable<OutgoingDataDestination> findDestinations(RepositoryComponent sinkComponent, DataSinkRole sinkRole,
		Stack<AssemblyContext> context) {
		val result = new ArrayList<OutgoingDataDestination>
		if (sinkComponent instanceof CompositeComponent) {
			val delegationConnectors = sinkComponent.connectors__ComposedStructure.filter(DataSinkDelegationConnector).
				filter[outerDataSinkRole === sinkRole]
			for (delegationConnector : delegationConnectors) {
				val innerAc = delegationConnector.assemblyContext
				val innerComponent = innerAc.encapsulatedComponent__AssemblyContext
				val innerRole = delegationConnector.innerDataSinkRole
				val newStack = context.copy
				newStack += innerAc
				result += findDestinations(innerComponent, innerRole, newStack)
			}
		} else if (sinkComponent instanceof DataChannel) {
			result += new DataSinkRoleWithContext(sinkComponent, sinkRole, context)
		} else if (sinkComponent instanceof BasicComponent) {
			val actions = sinkComponent.findChildrenOfType(AbstractAction)
			val consumeActions = actions.filter(ConsumeDataAction).filter[dataSinkRole === sinkRole].map [ da |
				new DataActionWithContext(da, sinkRole, context)
			]
			result += consumeActions
		}
		result
	}
	
	def <T> Stack<T> copy(Stack<T> stack) {
		val copy = new Stack<T>
		copy.addAll(stack)
		copy
	}
	
	
//	def DataSinkRoleWithContext findDestinationRole(DataSourceRole requiredRole, Stack<AssemblyContext> contexts) {
//		val composedStructure = contexts.last.parentStructure__AssemblyContext
//		val newcontext = new Stack()
//		newcontext += contexts
//		
//		// test if there is an assembly connector satisfying the required role
//		val assemblyConnector = composedStructure.connectors__ComposedStructure
//			.filter(AssemblyDataConnector)
//			.findFirst[
//				dataSourceRole === requiredRole &&
//				sourceAssemblyContext === newcontext.last
//			]
//		if (assemblyConnector !== null) {
//			newcontext.remove(newcontext.last)
//			val newAssemblyContext = assemblyConnector.sinkAssemblyContext
//			val providedRole = assemblyConnector.dataSinkRole
//			newcontext += newAssemblyContext
//			return providedRole.findDestinationRole(newcontext)
//		}
//		
//		// go to the parent composed structure to satisfy the required role
//		val outerRequiredRole = composedStructure.connectors__ComposedStructure
//			.filter(DataSourceDelegationConnector)
//			.filter[innerDataSourceRole == requiredRole]
//			.map[outerDataSourceRole]
//			.head
//		newcontext.remove(newcontext.last)
//		findDestinationRole(outerRequiredRole, newcontext)
//	}
//	
//	
//	
//	def findCallingRoles(DataSinkRole providedRole, Stack<AssemblyContext> context) {
//		val newContexts = new Stack()
//		newContexts += context
//		var role = providedRole
//		var providingComponent = role.providingEntity_ProvidedRole
//		while (providingComponent instanceof ComposedStructure) {
//			val connector = providingComponent.findProvidedDelegationConnector(role)
//			val assemblyContext = connector.assemblyContext
//			newContexts += assemblyContext
//			role = connector.innerDataSinkRole
//			providingComponent = role.providingEntity_ProvidedRole
//		}
//	}
//	
//		
//	def findDestinationRole(DataSinkRole providedRole, Stack<AssemblyContext> context) {
//		val newContexts = new Stack()
//		newContexts += context
//		var role = providedRole
//		var providingComponent = role.providingEntity_ProvidedRole
//		while (providingComponent instanceof ComposedStructure) {
//			val connector = providingComponent.findProvidedDelegationConnector(role)
//			val assemblyContext = connector.assemblyContext
//			newContexts += assemblyContext
//			role = connector.innerDataSinkRole
//			providingComponent = role.providingEntity_ProvidedRole
//		}
//		return new DataSinkRoleWithContext(role, context)
//	}
//	
//	private def findProvidedDelegationConnector(ComposedStructure component, DataSinkRole outerRole) {
//		component.connectors__ComposedStructure.filter(DataSinkDelegationConnector).
//				findFirst[outerDataSinkRole == outerRole]
//	}
//	

}
